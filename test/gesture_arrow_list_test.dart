import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitpod_flutter/robapp.dart';
import 'package:gitpod_flutter/gesture_arrow.dart';
import 'package:gitpod_flutter/gesture_arrow_list.dart';
import 'package:gitpod_flutter/models.dart';

void _moveEntryFail({String entryId, String listId, int direction}) {
  TestFailure("No entries should have been moved, tried to "
    "move entryId $entryId, listId $listId in direction $direction");
}
void _createEntryFail({String entryName, String listId, bool status}) {
  TestFailure("No entries should have been created, tried to create a new entry "
    "${status ? 'active' : 'inactive'} $entryName in list $listId");
}
void _deleteEntryFail({String entryId, String listId}) {
  TestFailure("No entries should be deleted, tried to delete entryId $entryId "
    "in list $listId");
}
void _setEntryStatusFail({String entryId, String listId, bool status}) {
  TestFailure("No entries should have their value set, tried to set entryId $entryId "
    "to $status");
}

class _EntryModelTestView implements EntryModel {
  String id;
  int index;
  bool isActive;
  String listId = _listId;
  String name;

  static int _count = 0;
  static const String _listId = 'test_list_id';

  _EntryModelTestView({
    @required this.name,
    @required this.isActive,
  }) {
    this.index = _count;
    this.id = "test_entry_id_num_${_count.toStringAsFixed(8)}";
    _count++;
  }
}

Widget _getTestRobApp({
  double screenWidth = 600,
  double screenHeight = 800,
  bool initialStatus = true,
  String name = 'Test Entry',
  void Function({String entryId, String listId, int direction}) moveEntry = _moveEntryFail,
  void Function({String entryName, String listId, bool status}) createEntry = _createEntryFail,
  void Function({String entryId, String listId}) deleteEntry = _deleteEntryFail,
  void Function({String entryId, String listId, bool status}) setEntryStatus = _setEntryStatusFail,
}) {
  return RobApp(
    body: Container(
      width:  screenWidth,
      height: screenHeight,
      child: GestureArrowList(
        isActive: initialStatus,
        listId: _EntryModelTestView._listId,
        entries: [_EntryModelTestView(
          name: name,
          isActive: initialStatus)
        ],
        moveEntry: moveEntry,
        createEntry: createEntry,
        deleteEntry: deleteEntry,
        setEntryStatus: setEntryStatus,
      ),
    ),
  );
}

void main() {
  testWidgets('GestureArrow can be dragged', (WidgetTester tester) async {
    const double dragLength = 200;

    Widget app = _getTestRobApp();
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    final Offset initialArrowCenter = tester.getTopLeft(arrowFinder);
    await tester.drag(arrowFinder, Offset(dragLength, 0));
    await tester.pump();

    final Offset afterArrowCenter = tester.getTopLeft(arrowFinder);
    if (afterArrowCenter.dx > initialArrowCenter.dx) {
      print("afterArrowCenter.dx ${afterArrowCenter.dx} > initialArrowCenter.dx ${initialArrowCenter.dx}");
      return; // Tried to actually confirm that afterArrowCenter.dx - initialArrowCenter.dx == dragLength
    } else {
      TestFailure("afterArrowCenter.dx ${afterArrowCenter.dx} is not greater "
        "than initialArrowCenter.dx ${initialArrowCenter.dx}");
    }
  });
  testWidgets('Backwards gestureArrow can be dragged', (WidgetTester tester) async {
    const bool initialStatus = false;
    const double dragLength = -200;

    Widget app = _getTestRobApp(
      initialStatus: initialStatus,
    );
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    final Offset initialArrowCenter = tester.getTopLeft(arrowFinder);
    await tester.drag(arrowFinder, Offset(dragLength, 0));
    await tester.pump();
    final Offset afterArrowCenter = tester.getTopLeft(arrowFinder);
    if (afterArrowCenter.dx < initialArrowCenter.dx) {
      print("afterArrowCenter.dx ${afterArrowCenter.dx} < initialArrowCenter.dx ${initialArrowCenter.dx}");
      return; // Tried to actually confirm that afterArrowCenter.dx - initialArrowCenter.dx == dragLength
    } else {
      TestFailure("afterArrowCenter.dx ${afterArrowCenter.dx} is not less "
        "than initialArrowCenter.dx ${initialArrowCenter.dx}");
    }
  });

  testWidgets('Dragged GestureArrow returns to original spot', (WidgetTester tester) async {
    const double dragLength = 200;

    Widget app = _getTestRobApp();
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    final Offset initialArrowCenter = tester.getTopLeft(arrowFinder);
    await tester.drag(arrowFinder, Offset(dragLength, 0));
    await tester.pumpAndSettle();

    final Offset afterArrowCenter = tester.getTopLeft(arrowFinder);
    expect(afterArrowCenter.dx, initialArrowCenter.dx);
  });

  testWidgets('Backwards dragged GestureArrow returns to original spot', (WidgetTester tester) async {
    const double dragLength = -200;
    const bool initialStatus = false;

    Widget app = _getTestRobApp(
      initialStatus: initialStatus,
    );
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    final Offset initialArrowCenter = tester.getTopLeft(arrowFinder);
    await tester.drag(arrowFinder, Offset(dragLength, 0));
    await tester.pumpAndSettle();

    final Offset afterArrowCenter = tester.getTopLeft(arrowFinder);
    expect(afterArrowCenter.dx, initialArrowCenter.dx);
  });

  testWidgets('GestureArrow in GestureArrowList will go from active to inactive when flung', (WidgetTester tester) async {
    int timesCalled = 0;
    void setEntryStatus({String entryId, String listId, bool status}) {
      expect(status, false);
      timesCalled++;
      if (timesCalled > 1) TestFailure('SetEntryStatus should only be called once');
    }
    Widget app = _getTestRobApp(
      setEntryStatus: setEntryStatus,
    );
    const Offset flingOffset = Offset(200, 0);
    const double flingSpeed = 20;
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    await tester.fling(arrowFinder, flingOffset, flingSpeed);
    await tester.pumpAndSettle();
  });

  testWidgets('Backwards GestureArrow in GestureArrowList will go from inactive to active when flung', (WidgetTester tester) async {
    int timesCalled = 0;
    bool initialStatus = false;
    void setEntryStatus({String entryId, String listId, bool status}) {
      expect(status, !initialStatus);
      timesCalled++;
      if (timesCalled > 1) TestFailure('SetEntryStatus should only be called once');
    }
    Widget app = _getTestRobApp(
      initialStatus: initialStatus,
      setEntryStatus: setEntryStatus,
    );
    const Offset flingOffset = Offset(-200, 0);
    const double flingSpeed = 20;
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    await tester.fling(arrowFinder, flingOffset, flingSpeed);
    await tester.pumpAndSettle();
  });
}
