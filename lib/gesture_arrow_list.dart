import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
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
    this.listId,
    this.isActive,
    this.entries,
    this.setEntryStatus,
    this.createNewEntry,
    this.deleteEntry,
    this.moveEntry,
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

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _delegate,
    );
  }
}

typedef OnDragChange = void Function(int direction, String entryId);

class _GestureArrowListLayoutDelegate extends MultiChildLayoutDelegate {
  final List<EntryModel> entries;
  final OnDragChange onDragChange;
  final String draggingId;

  Map<String, Size> sizes;

  _GestureArrowListLayoutDelegate({
    @required this.entries,
    @required this.onDragChange,
    this.draggingId,
  }) {
    sizes = Map();
  }

  @override
  void performLayout(Size size) {
    List<String> ids = entries.map((EntryModel entry) => entry.id);
    if (draggingId != null) {
      bool foundDraggingId = ids.remove(draggingId);
      if (!foundDraggingId) {
        throw FlutterError("Dragging id $draggingId not found in entries");
      }
      ids.insert(0, draggingId);
    }

    for (String id in ids) {
      Size childSize = layoutChild(id, BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: 0,
        maxHeight: double.infinity,
      ));
      sizes[id] = childSize;
      
    }
  }

  @override
  bool shouldRelayout(_GestureArrowListLayoutDelegate oldDelegate) {
    return this.entries == oldDelegate.entries
        || this.onDragChange == oldDelegate.onDragChange;
  }

}