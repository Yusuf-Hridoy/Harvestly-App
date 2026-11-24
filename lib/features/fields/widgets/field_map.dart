import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/farm_models.dart';
import '../../../shared/logic/field_area.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The drawn field shape: four corners you can drag, and pinch to zoom.
///
/// The shape is only a picture. It never changes the size the user typed in
/// the field form.
class FieldMap extends StatefulWidget {
  const FieldMap({
    super.key,
    required this.corners,
    required this.onCornerMoved,
  });

  /// The four corners, clockwise from the top left. Each one is 0.0 to 1.0.
  final List<MapPoint> corners;

  /// Called while a corner is being dragged, with its index and new place.
  final void Function(int index, MapPoint point) onCornerMoved;

  /// How wide the map box is compared to its height.
  static const double boxRatio = 300 / 190;

  /// The smallest and largest zoom.
  static const double minZoom = 1;
  static const double maxZoom = 3;

  /// How big a corner handle's tap area is.
  static const double handleSize = AppSizes.minTapTarget;

  @override
  State<FieldMap> createState() => _FieldMapState();
}

class _FieldMapState extends State<FieldMap> {
  final TransformationController _zoom = TransformationController();
  final GlobalKey _canvasKey = GlobalKey();

  /// Where inside the handle the finger grabbed it, so the corner does not
  /// jump to the finger when the drag starts.
  Offset _grabOffset = Offset.zero;

  int? _activeCorner;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(_onZoomChanged);
  }

  @override
  void dispose() {
    _zoom.removeListener(_onZoomChanged);
    _zoom.dispose();
    super.dispose();
  }

  void _onZoomChanged() {
    final double next = _zoom.value.getMaxScaleOnAxis();
    if ((next - _scale).abs() < 0.01) return;
    setState(() => _scale = next);
  }

  void _resetZoom() {
    _zoom.value = Matrix4.identity();
    setState(() => _scale = 1);
  }

  /// Turns a point on the screen into a 0.0 to 1.0 place inside the map box.
  ///
  /// `globalToLocal` walks back through the zoom and pan, so this is right at
  /// every zoom level.
  MapPoint? _toMapPoint(Offset globalPosition, {Offset grab = Offset.zero}) {
    final RenderObject? object = _canvasKey.currentContext?.findRenderObject();
    if (object is! RenderBox || !object.hasSize) return null;
    final Offset local = object.globalToLocal(globalPosition) - grab;
    return MapPoint(
      x: (local.dx / object.size.width).clamp(0.0, 1.0),
      y: (local.dy / object.size.height).clamp(0.0, 1.0),
    );
  }

  void _onHandleDragStart(int index, Offset globalPosition) {
    final RenderObject? object = _canvasKey.currentContext?.findRenderObject();
    if (object is! RenderBox || !object.hasSize) return;
    final Offset local = object.globalToLocal(globalPosition);
    final MapPoint corner = widget.corners[index];
    _grabOffset =
        local -
        Offset(corner.x * object.size.width, corner.y * object.size.height);
    setState(() => _activeCorner = index);
  }

  void _onHandleDragUpdate(int index, Offset globalPosition) {
    final MapPoint? point = _toMapPoint(globalPosition, grab: _grabOffset);
    if (point == null) return;
    widget.onCornerMoved(index, point);
  }

  void _onHandleDragEnd() {
    _grabOffset = Offset.zero;
    setState(() => _activeCorner = null);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TestId(
          TestIds.fieldMapCanvas,
          container: true,
          child: AspectRatio(
            aspectRatio: FieldMap.boxRatio,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(
                          color: colors.border,
                          width: AppSizes.borderWidth,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadius,
                        ),
                      ),
                      child: InteractiveViewer(
                        transformationController: _zoom,
                        minScale: FieldMap.minZoom,
                        maxScale: FieldMap.maxZoom,
                        child: LayoutBuilder(
                          builder:
                              (BuildContext context, BoxConstraints limits) {
                                return _buildCanvas(limits, colors);
                              },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 8,
                  child: IgnorePointer(
                    child: Text(
                      'Drag corners · Pinch to zoom',
                      style: textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: TestId(
                TestIds.fieldMapAreaText,
                child: Text(
                  FieldArea.label(widget.corners),
                  style: textTheme.titleSmall,
                ),
              ),
            ),
            TestId(
              TestIds.fieldMapZoomText,
              child: Text(
                '${_scale.toStringAsFixed(1)}×',
                style: textTheme.labelMedium,
              ),
            ),
            if (_scale > FieldMap.minZoom) ...<Widget>[
              const SizedBox(width: 8),
              TestId(
                TestIds.fieldMapResetZoomButton,
                merge: true,
                child: TextButton(
                  onPressed: _resetZoom,
                  child: const Text('Reset zoom'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCanvas(BoxConstraints limits, AppColorSet colors) {
    final double width = limits.maxWidth;
    final double height = limits.maxHeight;
    const double half = FieldMap.handleSize / 2;

    return SizedBox(
      key: _canvasKey,
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _FieldShapePainter(
                corners: widget.corners,
                grid: colors.border,
                fill: colors.secondarySoft,
                outline: colors.secondary,
              ),
            ),
          ),
          for (int i = 0; i < widget.corners.length; i++)
            Positioned(
              left: widget.corners[i].x * width - half,
              top: widget.corners[i].y * height - half,
              width: FieldMap.handleSize,
              height: FieldMap.handleSize,
              child: _CornerHandle(
                number: i + 1,
                active: _activeCorner == i,
                colors: colors,
                onDragStart: (Offset global) => _onHandleDragStart(i, global),
                onDragUpdate: (Offset global) => _onHandleDragUpdate(i, global),
                onDragEnd: _onHandleDragEnd,
              ),
            ),
        ],
      ),
    );
  }
}

/// One round corner handle. Its tap area is 44 x 44 so a test can drag from
/// the middle of its bounds.
class _CornerHandle extends StatelessWidget {
  const _CornerHandle({
    required this.number,
    required this.active,
    required this.colors,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final int number;
  final bool active;
  final AppColorSet colors;
  final void Function(Offset globalPosition) onDragStart;
  final void Function(Offset globalPosition) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return TestId(
      TestIds.fieldMapCorner(number),
      merge: true,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: <Type, GestureRecognizerFactory>{
          _CornerDragRecognizer:
              GestureRecognizerFactoryWithHandlers<_CornerDragRecognizer>(
                _CornerDragRecognizer.new,
                (_CornerDragRecognizer recognizer) {
                  recognizer.onStart = (DragStartDetails d) {
                    onDragStart(d.globalPosition);
                  };
                  recognizer.onUpdate = (DragUpdateDetails d) {
                    onDragUpdate(d.globalPosition);
                  };
                  recognizer.onEnd = (DragEndDetails d) => onDragEnd();
                  recognizer.onCancel = onDragEnd;
                },
              ),
        },
        child: Semantics(
          button: true,
          label: 'Corner $number',
          // A tap action does nothing but mark the corner. It is here so the
          // handle is a clickable node in the Android UI tree.
          onTap: onDragEnd,
          child: Center(
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                color: active ? colors.secondary : colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.secondary, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the light grid and the field shape on top of it.
class _FieldShapePainter extends CustomPainter {
  const _FieldShapePainter({
    required this.corners,
    required this.grid,
    required this.fill,
    required this.outline,
  });

  final List<MapPoint> corners;
  final Color grid;
  final Color fill;
  final Color outline;

  static const int _gridLines = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;

    for (int i = 1; i < _gridLines; i++) {
      final double x = size.width * i / _gridLines;
      final double y = size.height * i / _gridLines;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (corners.length < 3) return;

    final Path path = Path()
      ..moveTo(corners.first.x * size.width, corners.first.y * size.height);
    for (final MapPoint point in corners.skip(1)) {
      path.lineTo(point.x * size.width, point.y * size.height);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_FieldShapePainter old) =>
      !listEquals(old.corners, corners) ||
      old.grid != grid ||
      old.fill != fill ||
      old.outline != outline;
}

/// A drag that wins the gesture fight as soon as the finger goes down.
///
/// A plain pan recognizer only wins after the finger has moved about 36
/// pixels, by which time the scrolling list or the InteractiveViewer has
/// already claimed the touch and the corner never moves. Claiming at touch
/// down means a finger on a handle always drags that corner, while a finger
/// anywhere else still scrolls and zooms as normal.
class _CornerDragRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
