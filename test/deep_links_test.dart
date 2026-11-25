import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harvestly/app/app_routes.dart';
import 'package:harvestly/app/deep_links.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/login/login_controller.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

/// Today for every test here: Wednesday 25 November 2026, 9:00.
final DateTime _today = DateTime(2026, 11, 25, 9);

/// Opens a path the way an outside link does.
Future<void> _open(WidgetTester tester, String path) async {
  final BuildContext context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(path);
  await tester.pumpAndSettle();
}

/// Fills the login form with the farmer account and waits for the app.
Future<void> _logIn(WidgetTester tester) async {
  await tester.tap(byTestId(TestIds.loginDemoUseFarmerButton));
  await tester.pumpAndSettle();
  await tester.tap(byTestId(TestIds.loginSubmitButton));
  await tester.pump();
  await tester.pump(LoginController.fakeNetworkWait);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => AppClock.useFixed(_today));
  tearDown(AppClock.useRealClock);

  group('which links are ours', () {
    test('every supported link turns into its route', () {
      expect(DeepLinks.safePath('harvestly://app/home'), '/home');
      expect(DeepLinks.safePath('harvestly://app/fields'), '/fields');
      expect(
        DeepLinks.safePath('harvestly://app/fields/field-2'),
        '/fields/field-2',
      );
      expect(DeepLinks.safePath('harvestly://app/animals'), '/animals');
      expect(
        DeepLinks.safePath('harvestly://app/animals/group-1'),
        '/animals/group-1',
      );
      expect(DeepLinks.safePath('harvestly://app/tasks'), '/tasks');
      expect(
        DeepLinks.safePath('harvestly://app/tasks/task-4'),
        '/tasks/task-4',
      );
    });

    test('the Animals tab name is kept', () {
      expect(
        DeepLinks.safePath('harvestly://app/animals/group-1?tab=health'),
        '/animals/group-1?tab=health',
      );
    });

    test('a tab name on anything else is dropped', () {
      expect(
        DeepLinks.safePath('harvestly://app/tasks/task-4?tab=health'),
        '/tasks/task-4',
      );
    });

    test('a bare path is read the same way', () {
      expect(DeepLinks.safePath('/tasks/task-4'), '/tasks/task-4');
      expect(
        DeepLinks.safePath('/animals/group-1?tab=health'),
        '/animals/group-1?tab=health',
      );
    });

    test('a path Harvestly does not have is refused', () {
      expect(DeepLinks.safePath('harvestly://app/money'), isNull);
      expect(DeepLinks.safePath('harvestly://app/'), isNull);
      expect(DeepLinks.safePath('harvestly://app'), isNull);
      expect(
        DeepLinks.safePath('harvestly://app/fields/field-2/crops/crop-1'),
        isNull,
      );
      expect(DeepLinks.safePath('harvestly://app/home/extra'), isNull);
    });

    test('another app, another host or the web is refused', () {
      expect(DeepLinks.safePath('other://app/tasks'), isNull);
      expect(DeepLinks.safePath('harvestly://tasks/task-4'), isNull);
      expect(DeepLinks.safePath('https://example.com/tasks'), isNull);
      expect(DeepLinks.safePath('tasks/task-4'), isNull);
      expect(DeepLinks.safePath(''), isNull);
      expect(DeepLinks.safePath(null), isNull);
    });

    test('a form is not an item, so a link cannot open one', () {
      expect(DeepLinks.safePath('harvestly://app/tasks/new'), isNull);
      expect(DeepLinks.safePath('harvestly://app/fields/new'), isNull);
    });
  });

  group('links in the running app', () {
    testWidgets('a link to a task opens that task', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      await _open(tester, '/tasks/task-4');

      expect(byTestId(TestIds.taskDetailScreen), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.taskDetailTitleText),
        'Clean water pots',
      );
    });

    testWidgets('a link to a group opens it on the tab asked for', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      await _open(tester, '/animals/group-1?tab=health');

      expect(byTestId(TestIds.healthTab), findsOneWidget);
    });

    testWidgets('a link to a field opens it', (WidgetTester tester) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      await _open(tester, '/fields/field-2');

      expect(byTestId(TestIds.fieldDetailScreen), findsOneWidget);
    });

    testWidgets('a task id that is gone goes back to the list', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      await _open(tester, '/tasks/task-does-not-exist');

      expect(byTestId(TestIds.tasksScreen), findsOneWidget);
      expect(find.text('That task no longer exists.'), findsOneWidget);
    });

    testWidgets('a path Harvestly does not have opens Home and says so', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      await _open(tester, '/money');

      expect(byTestId(TestIds.homeScreen), findsOneWidget);
      expect(find.text(DeepLinks.badLinkMessage), findsOneWidget);
    });
  });

  group('login, then carry on', () {
    test('the login path carries where to go next', () {
      expect(
        AppRoutes.loginFrom('/tasks/task-4'),
        '/login?from=%2Ftasks%2Ftask-4',
      );
    });

    testWidgets('a link opened while logged out waits at login', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester);

      await _open(tester, '/tasks/task-4');

      expect(byTestId(TestIds.loginScreen), findsOneWidget);
    });

    testWidgets('logging in then opens the task the link pointed at', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester);
      await _open(tester, '/tasks/task-4');

      await _logIn(tester);

      expect(byTestId(TestIds.taskDetailScreen), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.taskDetailTitleText),
        'Clean water pots',
      );
    });

    testWidgets('an unsafe from is ignored and Home opens', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester);

      await _open(
        tester,
        '${AppRoutes.login}?from=https%3A%2F%2Fexample.com%2Fsteal',
      );
      await _logIn(tester);

      expect(byTestId(TestIds.homeScreen), findsOneWidget);
    });

    testWidgets('logging in with no from opens Home', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester);

      await _logIn(tester);

      expect(byTestId(TestIds.homeScreen), findsOneWidget);
    });
  });
}
