package com.harvestly.app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The one Android activity Harvestly runs in.
 *
 * It adds a small channel the Settings screen uses to open Android's own
 * notification page for this app. The notification plugin cannot do that on
 * every Android version, and Harvestly adds no package just for it.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "harvestly/settings"
        const val OPEN_NOTIFICATION_SETTINGS = "openNotificationSettings"
        const val ANDROID_SDK_INT = "androidSdkInt"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    OPEN_NOTIFICATION_SETTINGS -> result.success(openNotificationSettings())
                    // Harvestly needs this to tell "never asked yet" from
                    // "turned off", which only differ on Android 13 and up.
                    ANDROID_SDK_INT -> result.success(Build.VERSION.SDK_INT)
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Opens the app's notification settings, and returns whether that worked.
     *
     * Android 8 and newer have a page for one app's notifications. Older
     * versions only have the app's details page, so that is used instead.
     */
    private fun openNotificationSettings(): Boolean {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.fromParts("package", packageName, null))
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        return try {
            startActivity(intent)
            true
        } catch (error: android.content.ActivityNotFoundException) {
            false
        }
    }
}
