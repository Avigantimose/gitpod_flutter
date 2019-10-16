import 'package:flutter/widgets.dart';

typedef SetEntryStatus = void Function({
  @required String entryId,
  @required String listId,
  @required bool status});
typedef CreateNewEntry = void Function({
  @required String entryName,
  @required String listId,
  @required bool status});
typedef DeleteEntry = void Function({
  @required String entryId,
  @required String listId});
typedef MoveEntry = void Function({
  @required String entryId,
  @required String listId,
  @required int direction,
});

/// *************
/// Models
/// *************

abstract class FliplistAppModel {
  List<FliplistModel> get lists;
  String addNewFliplist(String name);
  FliplistModel getFliplist(String id);
  void deleteFliplist(String id);
}

abstract class FliplistModel {
  String name;
  String id;
  List<EntryModel> get activeEntries;
  List<EntryModel> get inactiveEntries;

  EntryModel getEntry(String id);
  String addEntry(String entryName, bool isActive);
  void deleteEntry(String id);
  void setEntryStatus(String id, bool status);
  void moveEntry(String id, int direction);
}

abstract class EntryModel {
  String name;
  String id;
  String listId;
  bool isActive;
  int index;
}

/// *******************
/// Implementations
/// *******************

class FliplistAppViewModel implements FliplistAppModel{
  List<FliplistModel> _lists = List<FliplistModel>();
  static int _idCount = 1;

  @override
  List<FliplistModel> get lists => _lists;

  @override
  String addNewFliplist(String name) {
    String id = "listid#${_idCount.toString().padLeft(8, '0')}";
    _lists.add(FliplistViewModel(
      name: name,
      id: id,
      activeEntries: List<EntryModel>(),
      inactiveEntries: List<EntryModel>(),
    ));
    _idCount++;
    return id;
  }

  @override
  FliplistModel getFliplist(String id) {
    Iterable<FliplistModel> matchingLists = _lists.where((FliplistModel model) => model.id == id);
    assert(matchingLists.length > 0, "No list with matching id: $id");
    assert(matchingLists.length <= 1, "Multiple lists with matching id: $id");
    return matchingLists.first;
  }

  @override
  void deleteFliplist(String id) {
    List<FliplistModel> matchingLists = _lists.where((FliplistModel m) => m.id == id).toList();
    assert(matchingLists.length > 0, 'No matching List');
    assert(matchingLists.length < 2, 'Multpiple matching lists');
    matchingLists.removeWhere((FliplistModel m) => m.id == id);
  }
}

class FliplistViewModel implements FliplistModel {
  String id;
  String name;

  List<EntryModel> get activeEntries { return _activeEntries; }
  List<EntryModel> get inactiveEntries { return _inactiveEntries; }

  List<EntryModel> _activeEntries;
  List<EntryModel> _inactiveEntries;

  List<EntryModel> get _allEntries {
    List<EntryModel> all = List<EntryModel>.from(_activeEntries);
    all.addAll(_inactiveEntries);
    return all;
  }



  FliplistViewModel({
    @required this.id,
    @required this.name,
    @required List<EntryModel> activeEntries,
    @required List<EntryModel> inactiveEntries}) :
      _activeEntries = activeEntries,
      _inactiveEntries = inactiveEntries;

  EntryModelView getEntry(String id){
    Iterable<EntryModel> entries = _allEntries.where((t) => t.id == id);
    assert(entries.length > 0, 'No matching entry');
    assert(entries.length <= 1, 'Multiple matching entries');
    return entries.first;
  }


  String addEntry(String name, bool isActive) {
    EntryModel entry;
    if (isActive) {
      entry = EntryModelView(name: name, listId: id, isActive: true, index: _activeEntries.length);
      _activeEntries.add(entry);
    } else {
      entry = EntryModelView(name: name, listId: id, isActive: false, index: _inactiveEntries.length);
      _inactiveEntries.add(entry);
    }
    return entry.id;
  }

  EntryModel deleteEntry(String id) {
    EntryModel entry = getEntry(id);
    List<EntryModel> entries;

    if (entry.isActive) {
      entries = _activeEntries;
    } else {
      entries = _inactiveEntries;
    }

    entries.removeWhere((t) => t.id == id);

    for (int i = entry.index; i < entries.length; i++) {
      entries[i].index--;
    }
    return entry;
  }

  void setEntryStatus(String id, bool status) {
    EntryModel tmp = deleteEntry(id);
    addEntry(tmp.name, status);
  }

  void moveEntry(String id, int direction) {
    assert(direction == 1 || direction == -1);
    EntryModel entry = getEntry(id);
    List<EntryModel> entries;
    if (entry.isActive) {
      entries = _activeEntries;
    } else {
      entries = _inactiveEntries;
    }

    if (direction == 1) {
      if (entry.index >= entries.length) {
        throw FlutterError('Tried to move an entry down when its already at the end');
      } else {
        EntryModel nextEntry = entries.firstWhere((EntryModel m) => m.index == entry.index + 1);
        EntryModel currentEntry = entries.firstWhere((EntryModel m) => m.index == entry.index);

        nextEntry.index--;
        currentEntry.index++;
      }
    } else if (direction == -1) {
      if (entry.index == 0) {
        throw FlutterError('Tried to move an entry up when its already at the top');
      } else {
        EntryModel prevEntry = entries.firstWhere((EntryModel m) => m.index == entry.index - 1);
        EntryModel currentEntry = entries.firstWhere((EntryModel m) => m.index == entry.index);

        prevEntry.index++;
        currentEntry.index--;
      }
    }
  }
}

class EntryModelView implements EntryModel {
  bool isActive;
  String name;
  String id;
  String listId;
  int index;
  static int _idCount = 1;
  static String get _idCountPadded {
    return _idCount.toString().padLeft(8, '0');
  }

  EntryModelView({
    this.name,
    this.isActive,
    this.id,
    this.listId,
    this.index,
  }): assert(name != null),
      assert(isActive != null) {
    this.id = "entryid#$_idCountPadded";
    _idCount++;
  }
}