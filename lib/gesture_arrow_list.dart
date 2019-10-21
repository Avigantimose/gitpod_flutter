import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'gesture_arrow.dart';
import 'models.dart';
import 'gesture_arrow.dart';

class GestureArrowList extends StatefulWidget {
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
  });

  @override
  State<GestureArrowList> createState() {
    return _GestureArrowListState();
  }
}

class _GestureArrowListState extends State<GestureArrowList> with TickerProviderStateMixin {
  MultiChildLayoutDelegate _delegate;
  Map<String, Animation<double>> _elevations = Map();


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

  List<Widget> _getChildren() {
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
      return LayoutId(
        id: entry.id,
        child: GestureArrow(
          key: Key(entry.id),
          isBackwards: !entry.isActive,
          child: Text(entry.name),
          onHorizontalDragStart: () {

          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {

          },
          onHorizontalDragEnd: (DragEndDetails details) {

          },
        ),
      );
    }).toList();

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _delegate,
      children: _getChildren(),
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