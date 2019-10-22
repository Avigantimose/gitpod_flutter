import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'gesture_arrow.dart';
import 'models.dart';

class GestureArrowList extends StatefulWidget {
  static const _defaultDuration =  const Duration(milliseconds: 300);
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
  final Duration dismissDuration;

  GestureArrowList({
    @required this.listId,
    @required this.isActive,
    @required this.entries,
    @required this.setEntryStatus,
    @required this.createNewEntry,
    @required this.deleteEntry,
    @required this.moveEntry,
    this.onOverdragEnd,
    this.onOverdragUpdate,
    this.onOverdragStart,
    this.dismissDuration = _defaultDuration
  });

  @override
  State<GestureArrowList> createState() {
    return _GestureArrowListState();
  }
}

class _GestureArrowListState extends State<GestureArrowList> with TickerProviderStateMixin {
  MultiChildLayoutDelegate _delegate;
  Map<String, Animation<double>> _elevations = Map();
  Map<String, AnimationController> _sizeControllers = Map();

  @override
  void initState() {
    super.initState();
    _delegate = _GestureArrowListLayoutDelegate(
      entries: widget.entries,
      onDragChange: (int direction, String entryId) {
        widget.moveEntry(
          listId: widget.listId,
          entryId: entryId,
          direction: direction,
        );
      }
    );
  }

  List<Widget> _getChildren(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Sort by elevation
    widget.entries.sort((EntryModel entryA, EntryModel entryB){
      Animation<double> entryAElevationAnimation = _elevations[entryA.id];
      Animation<double> entryBElevationAnimation = _elevations[entryB.id];

      if (entryAElevationAnimation == null && entryBElevationAnimation == null) return 0;
      else if (entryAElevationAnimation == null) return -1;
      else if (entryBElevationAnimation == null) return 1;

      double entryAElevation = entryAElevationAnimation.value;
      double entryBElevation = entryBElevationAnimation.value;

      if (entryAElevation > entryBElevation) return 1;
      else if (entryBElevation > entryAElevation) return -1;
      else return 0;
    });

    List<Widget> children = widget.entries.map((EntryModel entry) {
      Animation<double> sizeAnimation = const AlwaysStoppedAnimation(1.0);
      Animation<Offset> slideAnimation = const AlwaysStoppedAnimation(Offset(0, 0));

      Widget gestureArrow = GestureArrow(
        key: Key(entry.id),
        isBackwards: !entry.isActive,
        child: Text(entry.name),
        onHorizontalDragStart: () =>
          _onHorizontalDragStart(entry.id, entry.isActive),
        onHorizontalDragUpdate: (DragUpdateDetails details) =>
          _onHorizontalDragUpdate(entry.id, entry.isActive, details, slideAnimation),
        onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDragEnd(entry.id, widget.isActive, details, screenWidth, slideAnimation, sizeAnimation),
      );

      return LayoutId(
        id: entry.id,
        child: SizeTransition(
          sizeFactor: sizeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: gestureArrow,
          ),
        ),
      );
    }).toList();

    return children;
  }

  void _onHorizontalDragStart(
    String entryId,
    bool isActive,
  ) {
    AnimationController controller = AnimationController(
      vsync: this,
      duration: widget.dismissDuration,
    );
    setState(() {
      _sizeControllers[entryId] = controller;
    });
  }

  void _onHorizontalDragUpdate(
    String entryId,
    bool isActive,
    DragUpdateDetails details,
    Animation<Offset> slideAnimation,
  ) {
    debugPrint("Horizontal drag update: ${details.localPosition.dx}");
    setState((){
      slideAnimation = Tween(begin: Offset(details.localPosition.dx, 0)).animate(_sizeControllers[entryId]);
    });
  }

  void _onHorizontalDragEnd(
    String entryId,
    bool isActive,
    DragEndDetails details,
    double screenWidth,
    Animation<Offset> slideAnimation,
    Animation<double> sizeAnimation,
  ) {


  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _delegate,
      children: _getChildren(context),
    );
  }
}

typedef OnDragChange = void Function(int direction, String entryId);

class _GestureArrowListLayoutDelegate extends MultiChildLayoutDelegate {
  final List<EntryModel> entries;
  final OnDragChange onDragChange;

  Map<String, Size> sizes;

  _GestureArrowListLayoutDelegate({
    @required this.entries,
    @required this.onDragChange,
  }) {
    sizes = Map();
  }

  @override
  void performLayout(Size size) {
    double runningHeight = 0;
    entries.sort((EntryModel entryA, EntryModel entryB) {
      return (entryA.index > entryB.index) ? 1 : -1;
    });
    for (EntryModel entry in entries) {
      Size childSize = layoutChild(entry.id, BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: 0,
        maxHeight: double.infinity,
      ));
      sizes[entry.id] = childSize;
      positionChild(entry.id, Offset(0, runningHeight));
      runningHeight += childSize.height;
    }
  }

  @override
  bool shouldRelayout(_GestureArrowListLayoutDelegate oldDelegate) {
    return this.entries != oldDelegate.entries &&
      this.onDragChange != oldDelegate.onDragChange;
  }

}