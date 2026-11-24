import 'package:material_ui/material_ui.dart';

/// Adds a Semantics identifier to a widget.
///
/// On Android the identifier becomes the element's `resource-id`, which is how
/// Appium finds it. Always pass a constant from `TestIds`, never a raw string.
///
/// Which setting to use:
/// - Buttons, links and anything else that is tapped: `merge: true`, so the
///   identifier sits on the same node as the tap, and the node stays
///   `clickable="true"` in the Android UI tree.
/// - Text fields and plain text: the default, which lets the identifier join
///   the node the widget already makes. Merging a text field would swallow the
///   buttons inside it, such as the show password eye.
/// - Screens and cards that only need to be found, not tapped:
///   `container: true`, which gives them a node of their own.
class TestId extends StatelessWidget {
  const TestId(
    this.id, {
    super.key,
    required this.child,
    this.container = false,
    this.merge = false,
  }) : assert(
         !(container && merge),
         'Use either container or merge, not both.',
       );

  /// The identifier, from `TestIds`.
  final String id;

  /// The widget that should carry the identifier.
  final Widget child;

  /// Whether to force a semantics node of its own.
  final bool container;

  /// Whether to squash the child's semantics into one node.
  final bool merge;

  @override
  Widget build(BuildContext context) {
    final Widget annotated = Semantics(
      identifier: id,
      container: container,
      child: child,
    );
    return merge ? MergeSemantics(child: annotated) : annotated;
  }
}
