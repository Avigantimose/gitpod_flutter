import 'package:flutter/widgets.dart';
import 'arrow_tile.dart';
import 'colors.dart';

class GestureArrow extends StatefulWidget {
  final bool isBackwards;
  final Color color;
  final Color strokeColor;
  final double strokeWidth;
  final double arrowTipLength;
  final double backArrowTipLength;
  final void Function(double elevation) updateElevation;

  GestureArrow({
    @required this.isBackwards,
    @required this.updateElevation,
    this.color = FlipColor.white1,
    this.strokeColor = FlipColor.black1,
    this.strokeWidth = 1,
    this.arrowTipLength = 32,
    this.backArrowTipLength = 0,
  });
  @override
  State<GestureArrow> createState() {
    return _GestureArrowState();
  }
}

class _GestureArrowState extends State<GestureArrow> {
  static const double _slop = 8;

  bool isHorizontalLongDrag = false;
  bool isVerticalLongDrag = false;

  @override
  Widget build(BuildContext context) {
    ArrowTile arrowTile = ArrowTile(
      color: widget.color,
      strokeColor: widget.strokeColor,
      strokeWidth: widget.strokeWidth,
      isBackwards: widget.isBackwards,
      arrowTipLength: widget.arrowTipLength,
      backArrowTipLength: widget.backArrowTipLength,
    );

    GestureDetector detector = GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: arrowTile,
    );

    return detector;
  }

  void _onLongPressStart(LongPressStartDetails details) {

  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (isVerticalLongDrag && isHorizontalLongDrag) throw FlutterError('GestureArrow is both vertical long dragging and horizontal long dragging');
    else if (isVerticalLongDrag) _onLongVerticalDragUpdate(details);
    else if (isHorizontalLongDrag) _onLongHorizontalDragUpdate(details);
    else {
      double dxAbs = details.localOffsetFromOrigin.dx.abs();
      double dyAbs = details.localOffsetFromOrigin.dy.abs();
      bool horizontalDrag = dxAbs > _slop;
      bool verticalDrag = dyAbs > _slop;

      void _startLongHorizontalDrag() {
        setState(() {
          isHorizontalLongDrag = true;
        });
        _onLongHorizontalDragStart();
        _onLongHorizontalDragUpdate(details);
      }
      void _startLongVerticalDrag() {
        setState(() {
          isVerticalLongDrag = true;
        });
        _onLongVerticalDragStart();
        _onLongVerticalDragUpdate(details);
      }

      if (horizontalDrag && verticalDrag) {
        if (dxAbs > dyAbs) {
          _startLongHorizontalDrag();
        } else {
          _startLongVerticalDrag();
        }
      } else if (horizontalDrag) {
        _startLongHorizontalDrag();
      } else if (verticalDrag) {
        _startLongVerticalDrag();
      }
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (isHorizontalLongDrag) _onLongHorizontalDragEnd(details);
    else if (isVerticalLongDrag) _onLongVerticalDragEnd(details);
    
  }

  void _onVerticalDragStart(DragStartDetails details) {

  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {

  }

  void _onVerticalDragEnd(DragEndDetails details) {

  }

  void _onHorizontalDragStart(DragStartDetails details) {

  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {

  }

  void _onHorizontalDragEnd(DragEndDetails details) {

  }

  void _onLongHorizontalDragStart() {

  }

  void _onLongHorizontalDragUpdate(LongPressMoveUpdateDetails details) {

  }

  void _onLongHorizontalDragEnd(LongPressEndDetails details) {

  }

  void _onLongVerticalDragStart() {

  }

  void _onLongVerticalDragUpdate(LongPressMoveUpdateDetails details) {

  }

  void _onLongVerticalDragEnd(LongPressEndDetails details) {

  }
}