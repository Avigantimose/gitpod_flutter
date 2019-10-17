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
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _delegate,
    );
  }
}

typedef OnDragChange = void Function({int direction, String entryId, double height});

class _GestureArrowListLayoutDelegate extends MultiChildLayoutDelegate {
  List<EntryModel> entries;
  OnDragChange onDragChange;

  _GestureArrowListLayoutDelegate({
    @required this.entries,
    @required this.onDragChange,
  });

  @override
  void performLayout(Size size) {
    // TODO: implement performLayout
  }

  @override
  bool shouldRelayout(_GestureArrowListLayoutDelegate oldDelegate) {
    return this.entries == oldDelegate.entries
        || this.onDragChange == oldDelegate.onDragChange;
  }

}