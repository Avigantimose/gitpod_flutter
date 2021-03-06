import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' as Gestures;
import 'gesture_arrow.dart';
import 'models.dart';

class GestureArrowList extends StatefulWidget {
  static const _defaultDuration =  const Duration(milliseconds: 300);
  final String listId;
  final SetEntryStatus setEntryStatus;
  final CreateNewEntry createEntry;
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
    @required this.createEntry,
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

  List<Widget> _getChildren(BuildContext context) => widget.entries.map((EntryModel entry) {
    Widget gesturedArrow = _GesturedArrow(
      key: Key(entry.id),
      isBackwards: !entry.isActive,
      duration: widget.dismissDuration,
      child: Text(entry.name),
      onDismiss: () {
        widget.setEntryStatus(
          entryId: entry.id,
          listId: widget.listId,
          status: !entry.isActive,
        );
      },
    );

    return LayoutId(
      id: entry.id,
      child: gesturedArrow,
    );
  }).toList();


  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _delegate,
      children: _getChildren(context),
    );
  }
}

class _GesturedArrow extends StatefulWidget {
  final Key key;
  final bool isBackwards;
  final Widget child;
  final Duration duration;
  final void Function() onDismiss;

  _GesturedArrow({
    @required this.key,
    @required this.isBackwards,
    @required this.child,
    @required this.duration,
    @required this.onDismiss,
  }) : super(key: key);

  @override
  State<_GesturedArrow> createState() {
    return _GesturedArrowState();
  }
}

class _GesturedArrowState extends State<_GesturedArrow> with TickerProviderStateMixin {
  AnimationController slideController;
  Animation<Offset> slideAnimation;
  double offsetX;

  AnimationController shrinkController;
  Animation<double> shrinkAnimation;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      vsync: this,
      duration: widget.duration
    );
    slideAnimation = slideController.drive(Tween(begin: Offset.zero));
    shrinkController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    shrinkAnimation = shrinkController.drive(Tween(begin: 1));
  }

  @override
  void dispose() {
    slideController.dispose();
    shrinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget arrow = GestureArrow(
      key: widget.key,
      isBackwards: widget.isBackwards,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, context),
      onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, context),
      child: widget.child,
    );

    return SizeTransition(
      sizeFactor: shrinkAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: arrow,
      )
    );
  }

  double get offsetXCapped {
    return widget.isBackwards ?
      offsetX > 0 ? 0 : offsetX :
      offsetX < 0 ? 0 : offsetX;
  }

  void _onHorizontalDragStart() {
    slideController.reset();
    setState(() {
      slideAnimation = Tween(begin: Offset.zero).animate(slideController);
      offsetX = 0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      offsetX += details.primaryDelta;
      slideAnimation = slideController.drive(Tween(begin: Offset(offsetXCapped / screenWidth, 0)));
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double velocity = details.primaryVelocity;
    double minFlingVelocity = Gestures.kMinFlingVelocity;

    if (velocity > minFlingVelocity) {
      setState(() {
        slideAnimation = slideController.drive(Tween(
          begin: Offset(offsetX / screenWidth, 0),
          end: widget.isBackwards ? Offset(-1, 0) : Offset(1, 0),
        ));
      });
      slideController.addStatusListener((AnimationStatus status){
        if (status == AnimationStatus.completed) {
          setState(() {
            shrinkAnimation = Tween(begin: 1.0, end: 0.0).animate(shrinkController);
          });
          shrinkController.addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              widget.onDismiss();
            }
          });
          shrinkController.forward();
        }
      });
      slideController.forward();
    } else {
      setState((){
        slideAnimation = slideController.drive(Tween(
          begin: Offset(offsetX / screenWidth, 0),
          end: Offset.zero));
      });
      slideController.forward();
    }
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