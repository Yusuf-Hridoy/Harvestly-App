import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_routes.dart';
import 'app_snackbar.dart';

/// Shown for a moment when a route points at a field or crop that is gone.
///
/// It sends the user back to the Fields list with a snackbar, which is what
/// a deep link into deleted data should do.
class MissingItemScreen extends StatefulWidget {
  const MissingItemScreen({super.key, required this.message});

  /// "That field no longer exists." or "That crop no longer exists."
  final String message;

  @override
  State<MissingItemScreen> createState() => _MissingItemScreenState();
}

class _MissingItemScreenState extends State<MissingItemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(AppRoutes.fields);
      AppSnackbar.show(context, widget.message);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
