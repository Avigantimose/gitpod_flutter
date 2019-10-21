import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitpod_flutter/robapp.dart';
import 'package:gitpod_flutter/gesture_arrow_list.dart';
import 'package:gitpod_flutter/models.dart';

class _EntryModelTestView implements EntryModel {
  String id;
  int index;
  bool isActive;
  String listId = 'test_list_id';
  String name;

  static int _count = 0;

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
        listId: 'listId',
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

  
}
