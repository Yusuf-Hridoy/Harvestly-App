import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_routes.dart';
import 'app_snackbar.dart';

/// Shown for a moment when a route points at a field or crop that is gone.
///
/// It sends the user back to the Fields list with a snackbar, which is what
/// a deep link into deleted data should do.
class MissingItemScreen extends StatefulWidget {
  const MissingItemScreen({
    super.key,
    required this.message,
    this.goTo = AppRoutes.fields,
  });

  /// "That field no longer exists.", "That crop no longer exists." or
  /// "That animal group no longer exists."
  final String message;

  /// The list to send the user back to. Fields by default, Animals for a
  /// group that is gone.
  final String goTo;

  @override
  State<MissingItemScreen> createState() => _MissingItemScreenState();
}

class _MissingItemScreenState extends State<MissingItemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The messenger is read before leaving, because by the time the new
      // screen is up this one's context is on its way out and a snackbar
      // asked for through it never appears on a real phone.
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      context.go(widget.goTo);
      AppSnackbar.showOn(messenger, widget.message);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
