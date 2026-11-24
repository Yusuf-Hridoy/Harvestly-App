import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';

/// One tab in the bottom bar.
class _TabSpec {
  const _TabSpec({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// The bottom tab bar around the five tabs.
///
/// Each tab keeps its own state while the user moves between tabs.
class MainTabsShell extends StatelessWidget {
  const MainTabsShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const List<_TabSpec> _tabs = <_TabSpec>[
    _TabSpec(
      id: TestIds.tabHomeButton,
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _TabSpec(
      id: TestIds.tabFieldsButton,
      label: 'Fields',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
    _TabSpec(
      id: TestIds.tabAnimalsButton,
      label: 'Animals',
      icon: Icons.egg_outlined,
      activeIcon: Icons.egg_rounded,
    ),
    _TabSpec(
      id: TestIds.tabTasksButton,
      label: 'Tasks',
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt_rounded,
    ),
    _TabSpec(
      id: TestIds.tabMoreButton,
      label: 'More',
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz_rounded,
    ),
  ];

  void _openTab(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final bool onHomeTab = shell.currentIndex == 0;

    return PopScope<Object?>(
      // On Home the app closes, which is normal Android behavior.
      // On any other tab the back button goes to the Home tab instead.
      canPop: onHomeTab,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _openTab(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(
                color: colors.border,
                width: AppSizes.borderWidth,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _TabButton(
                      spec: _tabs[i],
                      selected: i == shell.currentIndex,
                      colors: colors,
                      onTap: () => _openTab(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.spec,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final AppColorSet colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? colors.link : colors.textMuted;

    return TestId(
      spec.id,
      merge: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(selected ? spec.activeIcon : spec.icon, color: color),
              const SizedBox(height: 4),
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
