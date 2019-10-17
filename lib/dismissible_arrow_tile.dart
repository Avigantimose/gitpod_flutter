import 'package:flutter/widgets.dart';
import 'dart:math' as Math;
import 'arrow_tile.dart';

typedef OnOverdragStart = void Function();
typedef OnOverdragUpdate = void Function(double drag);
typedef OnOverdragEnd = void Function();
typedef OnDismissed = void Function();

class DismissibleArrowTile extends StatefulWidget {
  final Key key;
  final bool isBackwards;
  final Alignment alignment;
  final double width;
  final double strokeWidth;
  final Color color;
  final Color strokeColor;
  final Color shadowColor;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final OnOverdragStart overdragStart;
  final OnOverdragUpdate overdragUpdate;
  final OnOverdragEnd overdragDone;
  final OnDismissed dismiss;
  final double height;
  final double elevation;
  final double arrowTipLength;
  final double backArrowTipLength;
  final double flingThreshold; // Velocity needed to be considered a fling
  final double flingDismiss; // From 0 to 1, relative drag distance to fling on release
  final Widget child;

  DismissibleArrowTile({
    @required this.key,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(8),
    this.isBackwards = false,
    this.alignment,
    @required this.color,
    @required this.strokeColor,
    @required this.shadowColor,
    @required this.strokeWidth,
    @required this.overdragStart,
    @required this.overdragUpdate,
    @required this.overdragDone,
    @required this.dismiss,
    this.height,
    this.width,
    @required this.arrowTipLength,
    @required this.backArrowTipLength,
    @required this.elevation,
    this.flingThreshold = 4.0,
    this.flingDismiss = 0.6,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DismissibleArrowTileState();
  }
}

class _DismissibleArrowTileState extends State<DismissibleArrowTile> with TickerProviderStateMixin {
  AnimationController _horizontalSlideController;
  Animation<Offset> _horizontalSlideAnimation;

  AnimationController _sizeController;
  Animation<double> _sizeAnimation;

  static const Duration _duration = const Duration(milliseconds: 100);

  bool _addedShrinkListener = false;
  bool _startedFling = false;
  bool _startedOverDragging = false;
  bool _isOverdragging = false;

  double _lastDelta = 0;
  double _totalOffset = 0;
  double _relativeOffset = 0;
  double get _relativeOffsetCapped {
    return widget.isBackwards ?
      Math.min(_relativeOffset, 0) :
      Math.max(_relativeOffset, 0);
  }

  @override
  void initState() {
    super.initState();
    _horizontalSlideController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _horizontalSlideAnimation = _horizontalSlideController.drive(Tween(begin: Offset.zero));

    _sizeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100)
    );
    _sizeAnimation = _sizeController.drive(Tween(begin: 1));
  }

  void _dragStart(DragStartDetails details) {
    _horizontalSlideController.reset();
  }

  void _dragUpdate(DragUpdateDetails details, BuildContext context) {
    double _newTotalOffset = _totalOffset + details.primaryDelta;
    double _newRelativeOffset = _newTotalOffset / MediaQuery.of(context).size.width;
    setState(() {
      _lastDelta = details.primaryDelta;
      _totalOffset = _newTotalOffset;
      _relativeOffset = _newRelativeOffset;
    });
    Animation<Offset> _newAnimation = _horizontalSlideController.drive(Tween(begin: Offset(_relativeOffsetCapped, 0)));
    setState(() {
      _horizontalSlideAnimation = _newAnimation;
    });

    if (!_isOverdragging && _relativeOffset != _relativeOffsetCapped) {
      setState(() {
        _isOverdragging = true;
      });
    }

    if (_isOverdragging && _relativeOffset == _relativeOffsetCapped) {
      setState(() {
        _isOverdragging = false;
      });
    }

    if (_isOverdragging){
      if(!_startedOverDragging) {
        widget.overdragStart();
        setState(() {
          _startedOverDragging = true;
        });
      }
      widget.overdragUpdate(_totalOffset);
    }
  }

  void _dragEnd(DragEndDetails details) {
    Animation<Offset> _newAnimation;

    // Check if moving fast enough on release;
    bool isFlinging = widget.isBackwards ?
      (_lastDelta < - widget.flingThreshold) :
      (_lastDelta > widget.flingThreshold);

    // Check if tile is close enough to the edge
    isFlinging |= _relativeOffset.abs() >= widget.flingDismiss;

    if ( isFlinging ) {
      // Fling
      _newAnimation = Tween(begin: Offset(_relativeOffsetCapped, 0), end: Offset(widget.isBackwards ? -1 : 1, 0)).animate(_horizontalSlideController);
    } else {
      // Back to default position
      _newAnimation = Tween(begin: Offset(_relativeOffsetCapped, 0), end: Offset.zero).animate(_horizontalSlideController);
    }
    setState(() {
      _lastDelta = 0;
      _totalOffset = 0;
      _relativeOffset = 0;
      _horizontalSlideAnimation = _newAnimation;
    });

    if (!_startedFling && isFlinging) {
      setState(() {
        _startedFling = true;
      });
      _horizontalSlideController.addStatusListener((AnimationStatus status) {
        if(!_addedShrinkListener && status == AnimationStatus.completed) {
          Animation<double> newSizeAnimation = Tween(begin: 1.0, end: 0.0).animate(_sizeController);
          newSizeAnimation.addStatusListener((AnimationStatus sizeStatus){
            if (sizeStatus == AnimationStatus.completed) {
              widget.dismiss();
            }
          });
          setState(() {
            _sizeAnimation = newSizeAnimation;
            _addedShrinkListener = true;
          });
          _sizeController.forward();
        }
      });
    }

    _horizontalSlideController.fling();

    if (_isOverdragging) {
      widget.overdragDone();
    }
    setState(() {
      _isOverdragging = false;
      _startedOverDragging = false;
    });
  }


  Widget _addHorizontalSlideTransition(Widget child) {
    return SlideTransition(
      position: _horizontalSlideAnimation,
      child: child,
    );
  }

  Widget _addSizeTransition(Widget child) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _gestureTile = GestureDetector(
      child: ArrowTile(
        color: widget.color,
        strokeColor: widget.strokeColor,
        arrowTipLength: widget.arrowTipLength,
        backArrowTipLength: widget.backArrowTipLength,
        margin: widget.margin,
        padding: widget.padding,
        isBackwards: widget.isBackwards,
        child: widget.child,
        strokeWidth: widget.strokeWidth,
      ),
      onHorizontalDragStart: _dragStart,
      onHorizontalDragUpdate: (d) => _dragUpdate(d, context),
      onHorizontalDragEnd: _dragEnd,
    );

    return  _addHorizontalSlideTransition(_addSizeTransition(_gestureTile));
  }

  @override
  void dispose() {
    _horizontalSlideController.dispose();
    _sizeController.dispose();
    super.dispose();
  }
}