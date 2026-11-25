import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Where the release key comes from.
//
// 1. android/key.properties, if that file is there. It is git-ignored, so it
//    only exists on a machine where someone put it.
// 2. Otherwise the four HARVESTLY_* environment variables, which is how the
//    GitHub Actions build gets the key.
// 3. Otherwise nothing, and the build falls back to the debug key with a
//    warning. That keeps `flutter run --release` working on a fresh clone,
//    but such an APK can never be installed over a real release.
val keyPropertiesFile = rootProject.file("key.properties")

val releaseKey: Map<String, String>? = if (keyPropertiesFile.exists()) {
    val loaded = Properties()
    keyPropertiesFile.inputStream().use { loaded.load(it) }
    val fromFile = mapOf(
        "storeFile" to loaded.getProperty("storeFile"),
        "storePassword" to loaded.getProperty("storePassword"),
        "keyAlias" to loaded.getProperty("keyAlias"),
        "keyPassword" to loaded.getProperty("keyPassword"),
    )
    if (fromFile.values.any { it.isNullOrBlank() }) {
        throw GradleException(
            "android/key.properties is missing one of storeFile, storePassword, " +
                "keyAlias or keyPassword."
        )
    }
    @Suppress("UNCHECKED_CAST")
    (fromFile as Map<String, String>)
} else {
    val fromEnv = mapOf(
        "storeFile" to System.getenv("HARVESTLY_KEYSTORE_PATH"),
        "storePassword" to System.getenv("HARVESTLY_KEYSTORE_PASSWORD"),
        "keyAlias" to System.getenv("HARVESTLY_KEY_ALIAS"),
        "keyPassword" to System.getenv("HARVESTLY_KEY_PASSWORD"),
    )
    @Suppress("UNCHECKED_CAST")
    if (fromEnv.values.all { !it.isNullOrBlank() }) fromEnv as Map<String, String> else null
}

if (releaseKey == null) {
    logger.warn(
        "Harvestly signing: no release key found, so a release build is signed with " +
            "the debug key. Such an APK cannot be installed over a real release and " +
            "must not be published. Add android/key.properties, or set " +
            "HARVESTLY_KEYSTORE_PATH, HARVESTLY_KEYSTORE_PASSWORD, HARVESTLY_KEY_ALIAS " +
            "and HARVESTLY_KEY_PASSWORD."
    )
}

android {
    namespace = "com.harvestly.app"
    // flutter_local_notifications 23 is built against SDK 37, so the app has
    // to compile against it too. The target SDK stays on Flutter default.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Needed by flutter_local_notifications so scheduled reminders work
        // on older Android versions.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.harvestly.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseKey != null) {
            create("release") {
                storeFile = file(releaseKey["storeFile"]!!)
                storePassword = releaseKey["storePassword"]
                keyAlias = releaseKey["keyAlias"]
                keyPassword = releaseKey["keyPassword"]
            }
        }
    }

    buildTypes {
        release {
            // The real key when there is one, the debug key otherwise. The
            // warning above says so when it falls back.
            signingConfig = if (releaseKey != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
