import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/demo_accounts.dart';
import '../data/farm_repository.dart';
import '../features/login/login_controller.dart';
import '../features/settings/theme_controller.dart';
import '../shared/app_info/app_version_reader.dart';
import 'app_router.dart';
import 'app_theme.dart';

/// The root widget: themes, providers and the router.
class HarvestlyApp extends StatefulWidget {
  const HarvestlyApp({
    super.key,
    required this.loginController,
    required this.themeController,
    required this.farmRepository,
    required this.appVersion,
  });

  final LoginController loginController;
  final ThemeController themeController;
  final FarmRepository farmRepository;
  final AppVersion appVersion;

  @override
  State<HarvestlyApp> createState() => _HarvestlyAppState();
}

class _HarvestlyAppState extends State<HarvestlyApp> {
  late final GoRouter _router = createAppRouter(
    loginController: widget.loginController,
  );

  @override
  void initState() {
    super.initState();
    _syncFarmData();
    widget.loginController.addListener(_syncFarmData);
  }

  @override
  void dispose() {
    widget.loginController.removeListener(_syncFarmData);
    super.dispose();
  }

  /// Keeps the loaded farm data on the account that is logged in.
  void _syncFarmData() {
    final DemoAccount? account = widget.loginController.account;
    if (account == null) {
      widget.farmRepository.closeAccount();
    } else {
      widget.farmRepository.openAccount(
        email: account.email,
        accountId: account.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginController>.value(
          value: widget.loginController,
        ),
        ChangeNotifierProvider<ThemeController>.value(
          value: widget.themeController,
        ),
        ChangeNotifierProvider<FarmRepository>.value(
          value: widget.farmRepository,
        ),
        Provider<AppVersion>.value(value: widget.appVersion),
      ],
      child: Consumer<ThemeController>(
        builder: (BuildContext context, ThemeController theme, Widget? _) {
          return MaterialApp.router(
            title: 'Harvestly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            routerConfig: _router,
            builder: (BuildContext context, Widget? child) {
              // Keeps the status bar icons readable in both themes.
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppTheme.overlayStyle(Theme.of(context).brightness),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
