import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitpod_flutter/robapp.dart';
import 'package:gitpod_flutter/gesture_arrow.dart';
import 'package:gitpod_flutter/gesture_arrow_list.dart';
import 'package:gitpod_flutter/models.dart';

void _moveEntryFail({String entryId, String listId, int direction}) {
  TestFailure("No entries should have been moved, tried to " +
    "move entryId $entryId, listId $listId in direction $direction");
}
void _createNewEntryFail({String entryName, String listId, bool status}) {
  TestFailure("No entries should have been created, tried to create a new entry " +
    "${status ? 'active' : 'inactive'} $entryName in list $listId");
}
void _deleteEntryFail({String entryId, String listId}) {
  TestFailure("No entries should be deleted, tried to delete entryId $entryId " +
    "in list $listId");
}
void _setEntryStatusFail({String entryId, String listId, bool status}) {
  TestFailure("No entries should have their value set, tried to set entryId $entryId " +
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

void main() {
  testWidgets('GestureArrow can be dragged', (WidgetTester tester) async {
    const double screenWidth = 600;
    const double screenHeight = 800;
    const bool initialStatus = true;
    const String name = 'Test Entry';
    const double dragLength = 200;

    Widget app = RobApp(
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
          moveEntry: _moveEntryFail,
          createNewEntry: _createNewEntryFail,
          deleteEntry: _deleteEntryFail,
          setEntryStatus: _setEntryStatusFail,
        ),
      ),
    );
    final int pointer = 1;
    await tester.pumpWidget(app);
    final Finder arrowFinder = find.byType(GestureArrow);
    final Offset initialArrowCenter = tester.getTopLeft(arrowFinder);
    TestGesture gesture = await tester.startGesture(initialArrowCenter, pointer: pointer);
    await gesture.moveBy(Offset(dragLength, 0));
    await gesture.up();
    await tester.pump();

    final Offset afterArrowCenter = tester.getTopLeft(arrowFinder);

    expect(afterArrowCenter.dx, initialArrowCenter.dx + dragLength);
  });
}
