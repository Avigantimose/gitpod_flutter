import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitpod_flutter/robapp.dart';
import 'package:gitpod_flutter/gesture_arrow.dart';
import 'package:gitpod_flutter/gesture_arrow_list.dart';
import 'package:gitpod_flutter/fliplist_entries.dart';
import 'package:gitpod_flutter/models.dart';

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
    this.id = "test_entry_id_${_count++}";
  }
}

void main() {
  testWidgets('Test RobApp displays title', (WidgetTester tester) async {
    const title = 'Test Title';
    await tester.pumpWidget(RobApp(
      title: title,
      body: Container(),
    ));

    final titleFinder = find.text(title);

    expect(titleFinder, findsOneWidget);
  });

  testWidgets('GestureArrowList displays entries', (WidgetTester tester) async {
    const String firstName = 'Entry 1';
    const String secondName = 'Entry 2';

    List<EntryModel> entries = List();
    entries.add(_EntryModelTestView(
      name: firstName,
      isActive: true
    ));
    entries.add(_EntryModelTestView(
      name: secondName,
      isActive: true,
    ));

    await tester.pumpWidget(RobApp(
      body: GestureArrowList(
        entries: entries,
        isActive: true,
        listId: _EntryModelTestView._listId,
        setEntryStatus: null,
        createNewEntry: null,
        moveEntry: null,
        deleteEntry: null,
    )));

    final firstNameFinder = find.text(firstName);
    final secondNameFinder = find.text(secondName);

    expect(firstNameFinder, findsOneWidget);
    expect(secondNameFinder, findsOneWidget);
  });

  testWidgets('GestureArrow swipe to dismiss', (WidgetTester tester) async {
    const double _screenWidth = 600;
    const double _screenHeight = 800;
    const bool _initialStatus = true;
    const String _name = 'Test Entry';
    bool newStatus;

    Widget app = RobApp(
      body: Container(
        width:  _screenWidth,
        height: _screenHeight,
        child: GestureArrowList(
          isActive: _initialStatus,
          listId: _EntryModelTestView._listId,
          entries: [_EntryModelTestView(
            name: _name,
            isActive: _initialStatus)
          ],
          moveEntry: ({String entryId, String listId, int direction}) {
            TestFailure("No entries should have been moved, tried to " +
              "move entryId $entryId, listId $listId in direction $direction");
          },
          createNewEntry: ({String entryName, String listId, bool status}) {
            TestFailure("No entries should have been created, tried to create a new entry " +
              "${status ? 'active' : 'inactive'} $entryName in list $listId");
          },
          deleteEntry: ({String entryId, String listId}) {
            TestFailure("No entries should be deleted, tried to delete entryID $entryId " +
              "in list $listId");
          },
          setEntryStatus: ({String entryId, String listId, bool status}) {
            newStatus = status;
          },
        ),
      ),
    );

    await tester.pumpWidget(app);

    await tester.drag(find.byType(GestureArrow), Offset(_screenWidth - 50, 0));

    await tester.pumpAndSettle();

    expect(newStatus, !_initialStatus);
  });

    testWidgets('Backwsrds GestureArrow swipe to dismiss', (WidgetTester tester) async {
    const double _screenWidth = 600;
    const double _screenHeight = 800;
    const bool _initialStatus = false;
    const String _name = 'Test Entry';
    bool newStatus;

    Widget app = RobApp(
      body: Container(
        width:  _screenWidth,
        height: _screenHeight,
        child: GestureArrowList(
          isActive: _initialStatus,
          listId: _EntryModelTestView._listId,
          entries: [_EntryModelTestView(
            name: _name,
            isActive: _initialStatus)
          ],
          moveEntry: ({String entryId, String listId, int direction}) {
            TestFailure("No entries should have been moved, tried to " +
              "move entryId $entryId, listId $listId in direction $direction");
          },
          createNewEntry: ({String entryName, String listId, bool status}) {
            TestFailure("No entries should have been created, tried to create a new entry " +
              "${status ? 'active' : 'inactive'} $entryName in list $listId");
          },
          deleteEntry: ({String entryId, String listId}) {
            TestFailure("No entries should be deleted, tried to delete entryID $entryId " +
              "in list $listId");
          },
          setEntryStatus: ({String entryId, String listId, bool status}) {
            newStatus = status;
          },
        ),
      ),
    );

    await tester.pumpWidget(app);

    await tester.drag(find.byType(GestureArrow), Offset(-_screenWidth + 50, 0));

    await tester.pumpAndSettle();

    expect(newStatus, !_initialStatus);
  });
  testWidgets('FliplistEntries will shift its viewport when drags', (WidgetTester tester) async {

  });
}
