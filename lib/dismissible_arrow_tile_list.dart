import 'dart:developer';
import 'arrow_tile.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'colors.dart';
import 'dismissible_arrow_tile.dart';
import 'gesture_arrow.dart';
import 'models.dart';

typedef OnDragChange = void Function({int direction, String entryId, double height});
typedef UpdateOffsets = void Function(Map<String, double> offsets);
typedef UpdateHeights = void Function(Map<String, double> heights);

typedef OnLongHoldStart = void Function();
typedef OnLongHoldUpdate = void Function();
typedef OnLongHoldEnd = void Function();
typedef OnVerticalLongDragStart = void Function();
typedef OnVerticalLongDragUpdate = void Function(double delta);
typedef OnVerticalLongDragEnd = void Function();
typedef OnHorizontalLongDragStart = void Function();
typedef OnHorizontalLongDragUpdate = void Function(double delta);
typedef OnHorizontalLongDragEnd = void Function();

class DismissibleArrowTileList extends StatefulWidget {
  final String listId;
  final SetEntryStatus setEntryStatus;
  final CreateNewEntry createNewEntry;
  final DeleteEntry deleteEntry;
  final MoveEntry moveEntry;
  final OnOverdragStart onOverdragStart;
  final OnOverdragUpdate onOverdragUpdate;
  final OnOverdragEnd onOverdragEnd;
  final List<EntryModel> entries;
  final bool isActive;

  DismissibleArrowTileList({
    Key key,
    @required this.listId,
    @required this.setEntryStatus,
    @required this.createNewEntry,
    @required this.deleteEntry,
    @required this.moveEntry,
    @required this.onOverdragStart,
    @required this.onOverdragUpdate,
    @required this.onOverdragEnd,
    @required this.entries,
    @required this.isActive,
  }) : super(key: key);

  @override
  State<DismissibleArrowTileList> createState() {
    return _DismissibleArrowTileListState();
  }
}

class _GestureDismissibleArrowTile extends StatefulWidget {
  final String entryId;
  final String entryName;
  final bool isActive;
  final bool isDragged;
  final bool isReleased;
  final double arrowLength;
  final double backArrowLength;
  final double height;
  final double strokeWidth;
  final EdgeInsets dragMargin;
  final Animation<double> elevationAnimation;
  final void Function() onOverdragStart;
  final void Function(double delta) onOverdragUpdate;
  final void Function() onOverdragEnd;
  final void Function() onDismiss;
  final void Function() onHorizontalLongDragStart;
  final void Function() onVerticalLongDragStart;
  final void Function() onLongDragStart;
  final void Function(double delta) onHorizontalLongDragUpdate;
  final void Function(double delta) onVerticalLongDragUpdate;
  final void Function(double delta) onLongDragUpdate;
  final void Function() onHorizontalLongDragEnd;
  final void Function() onVerticalLongDragEnd;
  final void Function() onLongDragEnd;

  _GestureDismissibleArrowTile({
    @required this.entryId,
    @required this.entryName,
    @required this.isActive,
    @required this.isDragged,
    @required this.isReleased,
    @required this.arrowLength,
    @required this.backArrowLength,
    @required this.elevationAnimation,
    @required this.onOverdragStart,
    @required this.onOverdragUpdate,
    @required this.onOverdragEnd,
    @required this.onDismiss,
    @required this.dragMargin,
    @required this.strokeWidth,
    this.height,
    this.onHorizontalLongDragStart,
    this.onVerticalLongDragStart,
    this.onLongDragStart,
    this.onHorizontalLongDragUpdate,
    this.onVerticalLongDragUpdate,
    this.onLongDragUpdate,
    this.onHorizontalLongDragEnd,
    this.onVerticalLongDragEnd,
    this.onLongDragEnd,
  });

  @override
  State<StatefulWidget> createState() {
    return _GestureDismissibleArrowTileState();
  }
}

class _GestureDismissibleArrowTileState extends State<_GestureDismissibleArrowTile> {
  static const double longDragSlop = 8;

  bool _foundLongDragDirection = false;
  bool _longDragDirectionVertical = false;
  bool _longDragDirectionHorizontal = false;

  // START
  void onHorizontalLongDragStart() {
    debugPrint('Horizontal long drag started');
    setState(() {
      _foundLongDragDirection = true;
      _longDragDirectionHorizontal = true;
    });
    if (widget.onHorizontalLongDragStart != null) widget.onHorizontalLongDragStart();
  }
  void onVerticalLongDragStart() {
    debugPrint('Vertical long drag started');
    setState(() {
      _foundLongDragDirection = true;
      _longDragDirectionVertical = true;
    });
    if (widget.onVerticalLongDragStart != null) widget.onVerticalLongDragStart();
  }
  void onLongDragStart(LongPressStartDetails details) {
    debugPrint('Long drag started');
    if (widget.onLongDragStart != null) widget.onLongDragStart();
  }
  // UPDATE
  void onHorizontalLongDragUpdate(double delta) {
    debugPrint("Horizontal drag update $delta");
    if (widget.onHorizontalLongDragUpdate != null) widget.onHorizontalLongDragUpdate(delta);
  }
  void onVerticalLongDragUpdate(double delta) {
    debugPrint("Vertical drag update $delta");
    if (widget.onVerticalLongDragUpdate != null) widget.onVerticalLongDragUpdate(delta);
  }
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    double dx = details.localOffsetFromOrigin.dx;
    double dy = details.localOffsetFromOrigin.dy;
    debugPrint("Long drag updated: $dx $dy");

    if (!_foundLongDragDirection) {
      bool isHorizontalDrag = dx.abs() >= longDragSlop;
      bool isVerticalDrag = dy.abs() >= longDragSlop;
      if (isHorizontalDrag && isVerticalDrag) {
        if (dx.abs() > dy.abs()) {
          onHorizontalLongDragStart();
        } else {
          onVerticalLongDragStart();
        }
      } else if (isHorizontalDrag) {
        onHorizontalLongDragStart();
      } else if (isVerticalDrag) {
        onVerticalLongDragStart();
      }
    }
    if (_foundLongDragDirection) {
      if (_longDragDirectionHorizontal == true && _longDragDirectionVertical == true) {
        throw new FlutterError('Directional long drag is neither horizontal nor vertical');
      } else if (_longDragDirectionHorizontal) {
        onHorizontalLongDragUpdate(dx);
      } else if (_longDragDirectionVertical) {
        onVerticalLongDragUpdate(dy);
      }
    }
  }
  // END
  void onHorizontalLongDragEnd() {
    debugPrint('Horizontal long drag end');
    if (widget.onHorizontalLongDragEnd != null) widget.onHorizontalLongDragEnd();
  }
  void onVerticalLongDragEnd() {
    debugPrint('Vertical long drag end');
    if (widget.onVerticalLongDragEnd != null) widget.onVerticalLongDragEnd();
  }
  void onLongDragEnd(LongPressEndDetails details) {
    debugPrint('Long drag end');
    if (widget.onLongDragEnd != null) widget.onLongDragEnd();
    if (_longDragDirectionHorizontal) {
      onHorizontalLongDragEnd();
    } else if (_longDragDirectionVertical) {
      onVerticalLongDragEnd();
    }
    setState(() {
      _foundLongDragDirection = false;
      _longDragDirectionHorizontal = false;
      _longDragDirectionVertical = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget dismissibleArrowTile = DismissibleArrowTile(
      key: Key(widget.entryId),
      isBackwards: !widget.isActive,
      color: FlipColor.white1,
      strokeColor: FlipColor.black,
      strokeWidth: widget.strokeWidth,
      shadowColor: FlipColor.black,
      elevation: widget.isDragged || widget.isReleased ? widget.elevationAnimation.value : 0,
      arrowTipLength: widget.arrowLength,
      backArrowTipLength: widget.backArrowLength,
      margin: widget.dragMargin,
      height: widget.height,
      overdragStart: widget.onOverdragStart,
      overdragUpdate: widget.onOverdragUpdate,
      overdragDone: widget.onOverdragEnd,
      dismiss: widget.onDismiss,
      child: Text(widget.entryName),
    );

    Widget gesturedDismissibleArrowTile = GestureDetector(
      onLongPressStart: onLongDragStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressEnd: onLongDragEnd,
      child: dismissibleArrowTile,
    );

    return gesturedDismissibleArrowTile;
  }

}

class _DismissibleArrowTileListState extends State<DismissibleArrowTileList> with TickerProviderStateMixin {

  AnimationController _verticalShiftController;
  AnimationController _draggedController;
  AnimationController _releasedController;

  Animation<double> _draggedShiftAnimation;
  Animation<double> _draggedElevationAnimation;
  Animation<double> _releasedShiftAnimation;
  Animation<double> _releasedElevationAnimation;
  Animation<double> _verticalShiftAnimation;

  static const Duration _duration = const Duration(milliseconds: 100);
  static const double _elevation = 16;
  static const double _deletePromptWidth = 80;
  static const double _arrowLength = 32;
  static const double _marginLength = 4;
  static const double _strokeWidth = 1;

  Map<String, double> _offsets = Map();
  Map<String, double> _heights = Map();
  String _draggingId;
  double _dragExtent;
  double _dragExtentModifier;
  double _draggedOffset;
  String _releasedId;

  bool _markHeightsForUpdate = false;

  @override
  void initState(){
    super.initState();
    _verticalShiftController = AnimationController(
      vsync: this,
      duration: _duration,
      debugLabel: '_DismissibleArrowTileListState vertical shift controller',
    );
    _draggedController = AnimationController(
      vsync: this,
      duration: _duration,
      debugLabel: '_DismissibleArrowTileListState dragged entry controller',
    );
    _releasedController = AnimationController(
      vsync: this,
      duration: _duration,
      debugLabel: '_DismissibleArrowTileListState released entry controller',
    );

    _draggedShiftAnimation = Tween<double>(begin: 0, end: _deletePromptWidth).animate(_draggedController);
    _draggedElevationAnimation = Tween<double>(begin: 0, end: _elevation).animate(_draggedController);

    _releasedShiftAnimation = Tween<double>(begin: _deletePromptWidth, end: 0).animate(_releasedController);
    _releasedElevationAnimation = Tween<double>(begin: _elevation, end: 0).animate(_releasedController);
  }

  // EdgeInsets _getDragMargin(bool isActive, Animation<double> animation){
  //   return animation != null ? EdgeInsets.only(
  //     bottom: _marginLength + _elevationAnimation.value,
  //     right: isActive ? _elevationAnimation.value : _deletePromptOffsetAnimation.value,
  //     left: isActive ? _deletePromptOffsetAnimation.value : _elevationAnimation.value
  //   ) : EdgeInsets.only(
  //     bottom: _marginLength
  //   );
  // }

  // Widget _getDeletePrompt() {
  //   return Positioned(
  //     top: _draggedOffset,
  //     left: widget.isActive ? 0 : null,
  //     right: !widget.isActive ? 0 : null,
  //     child: SlideTransition(
  //       position: Tween(begin: Offset(widget.isActive ? -1 : 1, 0), end: Offset(0,0)).animate(_deletePromptController),
  //       child: ArrowTile(
  //         height: (_heights[_draggingId] ?? _heights[_releasedId]) - _marginLength,
  //         width: _deletePromptWidth + _arrowLength,
  //         margin: _getDragMargin(!widget.isActive, false),
  //         strokeWidth: _strokeWidth,
  //         strokeColor: FlipColor.black,
  //         shadowColor: FlipColor.black,
  //         elevation: 0,
  //         arrowTipLength: _arrowLength,
  //         backArrowTipLength: -1 * _arrowLength,
  //         isBackwards: widget.isActive,
  //         alignment: Alignment.topCenter,
  //         color: FlipColor.red,
  //         child: Icon(FontAwesomeIcons.trash, color: FlipColor.white,),
  //       ),
  //     ),
  //   );
  // }

  // List<LayoutId> _getLayoutIdChildren(List<EntryModel> entries) => entries.map<LayoutId>((EntryModel entry) {
  //   return LayoutId(
  //     id: entry.id,
  //     child: _GestureDismissibleArrowTile(
  //       entryId: entry.id,
  //       entryName: entry.name,
  //       isActive: entry.isActive,
  //       isDragged: entry.id == _draggingId,
  //       isReleased: entry.id == _releasedId,
  //       strokeWidth: _strokeWidth,
  //       arrowLength: _arrowLength,
  //       // dragMargin: _getDragMargin(entry.isActive, entry.id == _draggingId || entry.id == _releasedId),
  //       dragMargin: EdgeInsets.all(8.0),
  //       backArrowLength: (entry.id == _draggingId || entry.id == _releasedId) ? _deletePromptArrowWidthAnimation.value : 0,
  //       elevationAnimation: AlwaysStoppedAnimation(0.0),
  //       onOverdragStart: widget.onOverdragStart,
  //       onOverdragUpdate: widget.onOverdragUpdate,
  //       onOverdragEnd: widget.onOverdragEnd,
  //       onDismiss: () {
  //         widget.setEntryStatus(
  //           entryId: entry.id,
  //           listId: widget.listId,
  //           status: !entry.isActive
  //         );
  //         _verticalShiftController
  //           ..reset()
  //           ..forward();
  //       },
  //       onLongDragStart: () {
  //         setState(() {
  //           _draggingId = entry.id;
  //           _dragExtent = 0;
  //           _dragExtentModifier = 0;
  //           _draggedOffset = _offsets[_draggingId];
  //         });
  //         _verticalShiftController
  //           ..reset()
  //           ..forward();
  //         // _elevationController
  //         //   ..reset()
  //         //   ..forward();
  //         // _deletePromptController
  //         //   ..reset()
  //         //   ..forward();
  //       },
  //       onVerticalLongDragStart: (){
  //         // _deletePromptController.reverse();
  //       },
  //       onVerticalLongDragUpdate: (double delta) {
  //         setState(() {
  //           _dragExtent = delta;
  //         });
  //       },
  //       onLongDragEnd: () {
  //         setState(() {
  //           _releasedId = _draggingId;
  //           _draggingId = null;
  //           _dragExtent = 0;
  //           _dragExtentModifier = 0;
  //         });
  //         // _deletePromptController.reverse();
  //         _verticalShiftController.reverse();
  //         // _elevationController.reverse();
  //         // _elevationController.addStatusListener(_elevationListener);
  //       },
  //     ),
  //   );
  // }).toList();

  @override
  Widget build(BuildContext context) {
    // Put dragged entry in front of the list
    widget.entries.sort((EntryModel a, EntryModel b) => a.id == _draggingId ? 1 : 0);

    Widget multiChildLayout = CustomMultiChildLayout(
      delegate: _DismissibleArrowTileListLayoutDelegate(
        entries: widget.entries,
        draggingId: _draggingId,
        releasedId: _releasedId,
        shouldUpdateHeights: _markHeightsForUpdate,
        dragExtent: _dragExtent != null ? _dragExtent + _dragExtentModifier : null,
        shiftAnimation: _verticalShiftController,
        prevOffsets: _offsets,
        prevHeights: _heights,
        updateOffsets: (Map<String, double> offsets) {
          setState(() {
            _offsets = offsets;
          });
        },
        updateHeights: (Map<String, double> heights) {
          setState(() {
            _heights = heights;
            _markHeightsForUpdate = false;
          });
        },
        onDragChange: ({int direction, String entryId, double height}) {
          setState(() {
            _dragExtentModifier -= direction * height;
          });
          widget.moveEntry(
            entryId: entryId,
            listId: widget.listId,
            direction: direction,
          );
          _verticalShiftController
            ..reset()
            ..forward();
        }
      ),
      // children: _getLayoutIdChildren(widget.entries)
    );

    List<Widget> children = [multiChildLayout];
    // if (_draggingId != null) children.add(_getDeletePrompt(_draggingId));
    // if (_releasedId != null) children.add(_getDeletePrompt(_releasedId));

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(16),
      child: GestureArrow(
        isBackwards: false,
        height: 100,
        child: Text('test'),
      ),
    );
  }

  @override
  void dispose() {
    _verticalShiftController.dispose();
    _draggedController.dispose();
    _releasedController.dispose();
    super.dispose();
  }
}


class _DismissibleArrowTileListLayoutDelegate extends MultiChildLayoutDelegate {
  List<EntryModel> entries;
  OnDragChange onDragChange;
  Map<String, double> prevOffsets;
  Map<String, double> prevHeights;
  UpdateOffsets updateOffsets;
  UpdateHeights updateHeights;
  String draggingId;
  String releasedId;
  double dragExtent;
  Animation<double> shiftAnimation;
  bool shouldUpdateHeights;

  bool _foundDragIndex = false;
  bool _shouldUpdateOffsets = false;
  bool _shouldUpdateHeights = false;
  int _dragIndex;
  double _draggedHeight;
  Map<String, double> _offsets = Map();
  Map<String, double> _heights = Map();

  _DismissibleArrowTileListLayoutDelegate({
    @required this.entries,
    @required this.onDragChange,
    @required this.prevOffsets,
    @required this.updateOffsets,
    @required this.prevHeights,
    @required this.updateHeights,
    this.draggingId,
    this.releasedId,
    this.dragExtent,
    this.shiftAnimation,
    this.shouldUpdateHeights = false,
  });

  BoxConstraints _getConstraint(double width) {
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0,
      maxHeight: double.infinity
    );
  }

  @override
  void performLayout(Size size) {
    double runningOffset = 0;
    double draggedOffset;

    // Sort by entry indexes
    entries.sort((EntryModel entryA, EntryModel entryB) => entryA.index > entryB.index ? 1 : -1);

    for (EntryModel entry in entries) {
      bool isDraggedEntry = draggingId == entry.id;
      double lastOffset = prevOffsets[entry.id];
      double lastHeight = prevHeights[entry.id];
      Size childSize = layoutChild(entry.id, _getConstraint(size.width));
      _heights[entry.id] = childSize.height;

      if (isDraggedEntry) {
        draggedOffset = runningOffset + dragExtent;
        if (draggedOffset != lastOffset) {
          _shouldUpdateOffsets = true;
        }
        _dragIndex = entry.index;
        _foundDragIndex = true;
        positionChild(draggingId, Offset(0, draggedOffset));
        _offsets[draggingId] = draggedOffset;

      } else {
        if (runningOffset != lastOffset) {
          double animatedOffset = lastOffset == null ? runningOffset : lastOffset + ((runningOffset - lastOffset) * shiftAnimation.value);
          _offsets[entry.id] = animatedOffset;
          positionChild(entry.id, Offset(0, animatedOffset));
          _shouldUpdateOffsets = true;
        } else {
          positionChild(entry.id, Offset(0, runningOffset));
          _offsets[entry.id] = runningOffset;
        }
      }
      if (entry.id == releasedId) {
        debugPrint("Current Height ${childSize.height.toStringAsFixed(4)}, Previous Height ${lastHeight.toStringAsFixed(4)}");
      }

      runningOffset += childSize.height;

      if (childSize.height != lastHeight) {
        _shouldUpdateHeights = true;
      }
    }

    if (shouldUpdateHeights || _shouldUpdateHeights) {
      SchedulerBinding.instance.addPostFrameCallback((Duration d) {
        updateHeights(_heights);
      });
      SchedulerBinding.instance.addPostFrameCallback((Duration d) {
        updateOffsets(_offsets);
      });
      _shouldUpdateHeights = false;
    }

    if (_shouldUpdateOffsets) {
      SchedulerBinding.instance.addPostFrameCallback((Duration d) {
        updateOffsets(_offsets);
      });
      _shouldUpdateOffsets = false;
    }

    if (_foundDragIndex) {
      if (_dragIndex > 0 && _offsets[entries.firstWhere((e) => e.index == _dragIndex - 1).id] > draggedOffset) {
        SchedulerBinding.instance.addPostFrameCallback((Duration d) => onDragChange(
          direction: -1,
          entryId: draggingId,
          height: _heights[entries.firstWhere((e) => e.index == _dragIndex - 1).id],
        ));
      } else if (_dragIndex < entries.length - 1 && _offsets[entries.firstWhere((e) => e.index == _dragIndex + 1).id] < draggedOffset) {
        SchedulerBinding.instance.addPostFrameCallback((Duration d) => onDragChange(
          direction:  1,
          entryId: draggingId,
          height: _heights[entries.firstWhere((e) => e.index == _dragIndex + 1).id],
        ));
      }
    }
  }

  @override
  bool shouldRelayout(_DismissibleArrowTileListLayoutDelegate oldDelegate) {
    return oldDelegate.entries != entries
      || oldDelegate.draggingId != draggingId
      || oldDelegate.releasedId != releasedId
      || oldDelegate._offsets != _offsets
      || oldDelegate._heights != _heights
      || oldDelegate._draggedHeight != _draggedHeight
      || oldDelegate._dragIndex != _dragIndex;
  }
}