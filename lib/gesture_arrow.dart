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
  final Duration duration;
  final void Function(double elevation, AnimationStatus status) updateElevationStatus;
  final void Function(double elevation)           updateElevation;
  final void Function()                           onTap;
  final void Function()                           onHorizontalDragStart;
  final void Function(DragUpdateDetails)          onHorizontalDragUpdate;
  final void Function(DragEndDetails)             onHorizontalDragEnd;
  final void Function()                           onVerticalDragStart;
  final void Function(DragUpdateDetails)          onVerticalDragUpdate;
  final void Function(DragEndDetails)             onVerticalDragEnd;
  final void Function()                           onLongPress;
  final void Function(LongPressMoveUpdateDetails) onLongPressMoveUpdate;
  final void Function(LongPressEndDetails)        onLongPressEnd;
  final void Function()                           onLongHorizontalDragStart;
  final void Function(LongPressMoveUpdateDetails) onLongHorizontalDragUpdate;
  final void Function(LongPressEndDetails)        onLongHorizontalDragEnd;
  final void Function()                           onLongVerticalDragStart;
  final void Function(LongPressMoveUpdateDetails) onLongVerticalDragUpdate;
  final void Function(LongPressEndDetails)        onLongVerticalDragEnd;

  GestureArrow({
    @required this.isBackwards,
    this.updateElevation,
    this.updateElevationStatus,
    this.onTap,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    this.onLongHorizontalDragStart,
    this.onLongHorizontalDragUpdate,
    this.onLongHorizontalDragEnd,
    this.onLongVerticalDragStart,
    this.onLongVerticalDragUpdate,
    this.onLongVerticalDragEnd,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.color = FlipColor.white1,
    this.strokeColor = FlipColor.black1,
    this.strokeWidth = 1,
    this.arrowTipLength = 32,
    this.backArrowTipLength = 0,
    this.duration = const Duration(milliseconds: 300),
  });
  @override
  State<GestureArrow> createState() {
    return _GestureArrowState();
  }
}

class _GestureArrowState extends State<GestureArrow> with SingleTickerProviderStateMixin {
  static const double _slop = 8;

  bool isHorizontalLongDrag = false;
  bool isVerticalLongDrag = false;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.addListener(() {
      if (widget.updateElevation != null) {
        widget.updateElevation(_controller.value);
      }
    });
    _controller.addStatusListener((AnimationStatus status) {
      if (widget.updateElevationStatus != null) {
        widget.updateElevationStatus(_controller.value, status);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      onTap: widget.onTap,
      onLongPress: _onLongPress,
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

  void _onLongPress() {
    if (widget.onLongPress != null) widget.onLongPress();
    _controller.forward();
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (widget.onLongPressMoveUpdate != null) widget.onLongPressMoveUpdate(details);
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

    if (widget.onLongPressEnd != null) widget.onLongPressEnd(details);
    _controller.reverse();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (widget.onVerticalDragStart != null) widget.onVerticalDragStart();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (widget.onVerticalDragUpdate != null) widget.onVerticalDragUpdate(details);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (widget.onVerticalDragEnd != null) widget.onVerticalDragEnd(details);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (widget.onHorizontalDragStart != null) widget.onHorizontalDragStart();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.onHorizontalDragUpdate != null) widget.onHorizontalDragUpdate(details);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.onHorizontalDragEnd != null) widget.onHorizontalDragEnd(details);
  }

  void _onLongHorizontalDragStart() {
    if (widget.onLongHorizontalDragStart != null) widget.onLongHorizontalDragStart();
  }

  void _onLongHorizontalDragUpdate(LongPressMoveUpdateDetails details) {
    if (widget.onLongVerticalDragUpdate != null) widget.onLongHorizontalDragUpdate(details);
  }

  void _onLongHorizontalDragEnd(LongPressEndDetails details) {
    setState(() {
      isHorizontalLongDrag = false;
    });
    if (widget.onLongVerticalDragEnd != null) widget.onLongHorizontalDragEnd(details);
  }

  void _onLongVerticalDragStart() {
    if (widget.onLongVerticalDragStart != null) widget.onLongVerticalDragStart();
  }

  void _onLongVerticalDragUpdate(LongPressMoveUpdateDetails details) {
    if (widget.onLongVerticalDragUpdate != null) widget.onLongVerticalDragUpdate(details);
  }

  void _onLongVerticalDragEnd(LongPressEndDetails details) {
    setState((){
      isVerticalLongDrag = false;
    });
    if (widget.onLongVerticalDragEnd != null) widget.onLongVerticalDragEnd(details);
  }
}