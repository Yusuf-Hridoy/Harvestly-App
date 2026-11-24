import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';
import '../../data/demo_accounts.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import 'login_controller.dart';

/// The login screen. It is the only way into the app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _rememberMe = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailField.dispose();
    _passwordField.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final LoginController controller = context.read<LoginController>();
    FocusScope.of(context).unfocus();
    await controller.submit(
      email: _emailField.text,
      password: _passwordField.text,
      rememberMe: _rememberMe,
    );
  }

  void _useDemoAccount(DemoAccount account) {
    _emailField.text = account.email;
    _passwordField.text = DemoAccounts.password;
    context.read<LoginController>().clearErrors();
  }

  String _demoButtonId(DemoAccount account) {
    switch (account.id) {
      case 'farmer':
        return TestIds.loginDemoUseFarmerButton;
      case 'poultry':
        return TestIds.loginDemoUsePoultryButton;
      default:
        return TestIds.loginDemoUseNewButton;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginController controller = context.watch<LoginController>();
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: TestId(
        TestIds.loginScreen,
        container: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _LogoTile(colors: colors),
                const SizedBox(height: 20),
                Text(
                  'Harvestly',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Your whole farm, in one place.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 32),
                _FieldLabel(text: 'Email', colors: colors),
                const SizedBox(height: 6),
                TestId(
                  TestIds.loginEmailInput,
                  child: TextField(
                    controller: _emailField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enabled: !controller.busy,
                    decoration: const InputDecoration(
                      hintText: 'you@farm.test',
                    ),
                    onChanged: (_) => controller.onEmailChanged(),
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                ),
                if (controller.emailError != null)
                  _ErrorLine(
                    id: TestIds.loginEmailErrorText,
                    message: controller.emailError!,
                    colors: colors,
                  ),
                const SizedBox(height: 16),
                _FieldLabel(text: 'Password', colors: colors),
                const SizedBox(height: 6),
                TestId(
                  TestIds.loginPasswordInput,
                  child: TextField(
                    controller: _passwordField,
                    focusNode: _passwordFocus,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    enabled: !controller.busy,
                    decoration: InputDecoration(
                      hintText: 'Your password',
                      suffixIcon: TestId(
                        TestIds.loginPasswordToggleButton,
                        merge: true,
                        child: IconButton(
                          tooltip: _showPassword
                              ? 'Hide password'
                              : 'Show password',
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colors.textMuted,
                          ),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                      ),
                    ),
                    onChanged: (_) => controller.onPasswordChanged(),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                if (controller.passwordError != null)
                  _ErrorLine(
                    id: TestIds.loginPasswordErrorText,
                    message: controller.passwordError!,
                    colors: colors,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    TestId(
                      TestIds.loginRememberMeCheckbox,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: controller.busy
                            ? null
                            : (bool? value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Remember me',
                        style: textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TestId(
                      TestIds.loginForgotPasswordLink,
                      merge: true,
                      child: TextButton(
                        onPressed: () => AppSnackbar.show(
                          context,
                          'Password reset comes in a later phase.',
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  ],
                ),
                if (controller.bannerError != null) ...<Widget>[
                  const SizedBox(height: 8),
                  _ErrorBanner(
                    message: controller.bannerError!,
                    colors: colors,
                  ),
                ],
                const SizedBox(height: 16),
                TestId(
                  TestIds.loginSubmitButton,
                  // While the spinner shows, the button must not swallow the
                  // loading indicator's own ID.
                  merge: !controller.busy,
                  child: FilledButton(
                    onPressed: controller.busy ? null : _submit,
                    child: controller.busy
                        ? TestId(
                            TestIds.loginLoadingIndicator,
                            container: true,
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.onPrimary,
                              ),
                            ),
                          )
                        : const Text('Log in'),
                  ),
                ),
                const SizedBox(height: 28),
                _DemoAccountsBox(
                  colors: colors,
                  enabled: !controller.busy,
                  buttonIdOf: _demoButtonId,
                  onUse: _useDemoAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({required this.colors});

  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Icon(Icons.eco_outlined, color: colors.onPrimary, size: 34),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.colors});

  final String text;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: colors.textMuted),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({
    required this.id,
    required this.message,
    required this.colors,
  });

  final String id;
  final String message;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TestId(
        id,
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.error),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.colors});

  final String message;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.controlRadius),
        border: Border.all(color: colors.error, width: AppSizes.borderWidth),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, size: 20, color: colors.error),
          const SizedBox(width: 10),
          Expanded(
            child: TestId(
              TestIds.loginErrorBanner,
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountsBox extends StatelessWidget {
  const _DemoAccountsBox({
    required this.colors,
    required this.enabled,
    required this.buttonIdOf,
    required this.onUse,
  });

  final AppColorSet colors;
  final bool enabled;
  final String Function(DemoAccount) buttonIdOf;
  final void Function(DemoAccount) onUse;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Demo accounts', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Password for all: ${DemoAccounts.password}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final DemoAccount account in DemoAccounts.all) ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(account.email, style: textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text(account.note, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  TestId(
                    buttonIdOf(account),
                    merge: true,
                    child: OutlinedButton(
                      onPressed: enabled ? () => onUse(account) : null,
                      child: const Text('Use'),
                    ),
                  ),
                ],
              ),
              if (account != DemoAccounts.all.last)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
