import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';

import 'robapp.dart';
import 'fliplist_entries.dart';
import 'models.dart';
import 'colors.dart';

///
/// The top level fliplist app.
///
/// Displays individual lists via [ListPage]
///

class FliplistApp extends StatefulWidget {
  @override
  State<FliplistApp> createState() {
    return _FliplistAppState();
  }

}

class _FliplistAppState extends State<FliplistApp> {
  FliplistAppModel _appView;
  String _title = 'Fliplist';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  static const EdgeInsets _edgesAll = EdgeInsets.all(8);
  static const EdgeInsets _edgesTopBottom = EdgeInsets.only(top: 8, bottom: 8);
  static const EdgeInsets _edgeLeft = EdgeInsets.only(left: 8);
  static const EdgeInsets _edgeTop = EdgeInsets.only(top: 8);

  @override
  void initState() {
    super.initState();
    _appView = FliplistAppViewModel();
    String entryId = _appView.addNewFliplist('Test List');
    _appView.getFliplist(entryId)
      ..addEntry('Test Active 1', true)
      ..addEntry('Test Active 2', true)
      ..addEntry('Test Active 3', true)
      ..addEntry('Test Active 4', true)
      ..addEntry('Test Active 5', true)
      ..addEntry('Test Inactive 1', false)
      ..addEntry('Test Inactive 2', false)
      ..addEntry('Test Inactive 3', false);
  }

  void _showNewListDialog(BuildContext context) {
    Navigator.of(context).push(RobPopupRoute(
      child: Center(child: Container(
        color: FlipColor.white,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: Padding(
            padding: _edgesAll,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: _edgeTop,
                    child: Text('New list name:'),
                  ),
                  FormField(
                    builder: (FormFieldState field) {
                      return Container(
                        color: FlipColor.white2,
                        margin: _edgesTopBottom,
                        padding: _edgesAll,
                        child: EditableText(
                          autofocus: true,
                          controller: _textController,
                          backgroundCursorColor: FlipColor.black3,
                          cursorColor: FlipColor.black1,
                          focusNode: _focusNode,
                          style: DefaultTextStyle.of(context).style,
                        )
                      );
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            padding: _edgesAll,
                            color: FlipColor.white3,
                            child: Text('Cancel'),
                          ),
                        ),
                      ),
                      Padding(padding: _edgeLeft,),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            String listName = _textController.text;
                            setState(() {
                              _appView.addNewFliplist(listName);
                            });
                            _textController.clear();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            padding: _edgesAll,
                            color: FlipColor.white3,
                            child: Text('Okay'),
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
              )
            )
          )
        )
      )
    ));
  }

  List<Widget> _getHeroListTiles() {
    return _appView.lists.map<Widget>((FliplistModel f) => ListTileHero(
      listModel: f,
      setEntryStatus: ({String entryId, String listId, bool status}) {
        debugPrint("List $listId setting entry $entryId to $status");
        setState((){
          _appView.getFliplist(listId).setEntryStatus(entryId, status);
        });
      },
      createNewEntry: ({String listId, String entryName, bool status}) {
        debugPrint("List $listId creating entry $entryName with $status status");
        setState((){
          _appView.getFliplist(listId).addEntry(entryName, status);
        });
      },
      deleteEntry: ({String listId, String entryId}){
        debugPrint("List $listId deleting entry $entryId");
        setState((){
          _appView.getFliplist(listId).deleteEntry(entryId);
        });
      },
      moveEntry: ({String listId, String entryId, int direction}) {
        debugPrint("List $listId moving entry $entryId in $direction direction");
        setState((){
          _appView.getFliplist(listId).moveEntry(entryId, direction);
        });
      },
    )).toList();
  }

  Widget _getAddButton(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _showNewListDialog(context);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          color: FlipColor.green,
        ),
        alignment: AlignmentDirectional.center,
        child: Text('+', style: TextStyle(
          color: Color(0xffffffff),
          fontSize: 80
        )),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> heroTilesWithBottomPadding = _getHeroListTiles()
      ..add(Padding(padding: _edgeTop,));

    return RobApp(
      body: Stack(
        children: [
          ListView(
            children: heroTilesWithBottomPadding,
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Builder(
              builder: (BuildContext context) => _getAddButton(context),
            ),
          ),
          ]
      ),
      title: _title,
      mainColor: const Color.fromRGBO(0, 200, 0, 1),
    );
  }
}

/// ListTile with a hero animation
///
/// Expands a [ListTile] to fill screen
/// Contained by [FliplistApp]

class ListTileHero extends StatefulWidget {
  final FliplistModel listModel;
  final String listName;
  final String listId;
  final List<EntryModel> activeEntries;
  final List<EntryModel> inactiveEntries;
  final SetEntryStatus setEntryStatus;
  final CreateNewEntry createNewEntry;
  final DeleteEntry deleteEntry;
  final MoveEntry moveEntry;
  final Duration heroDuration;

  ListTileHero({
    @required this.listModel,
    @required this.setEntryStatus,
    @required this.createNewEntry,
    @required this.deleteEntry,
    @required this.moveEntry,
    this.heroDuration = const Duration(milliseconds: 300),
  }) :  listName = listModel.name,
        listId = listModel.id,
        activeEntries = listModel.activeEntries,
        inactiveEntries = listModel.inactiveEntries;

  @override
  State<StatefulWidget> createState() {
    return _ListTileHeroState();
  }
}

class _ListTileHeroState extends State<ListTileHero> with SingleTickerProviderStateMixin {
  static const double _edgeSize = 8;
  final EdgeInsets _edgesNoBottom = const EdgeInsets.fromLTRB(_edgeSize, _edgeSize, _edgeSize, 0);
  GlobalKey _childKey;

  void initState() {
    super.initState();
    _childKey = GlobalKey(debugLabel: "List ID: ${widget.listId}");
  }

  Widget _getListTile(Key key, Animation animation, bool showEntries) {
    return ListTile(
      key: key,
      listName: widget.listName,
      listId: widget.listId,
      activeEntries: widget.activeEntries,
      inactiveEntries: widget.inactiveEntries,
      showEntries: showEntries,
      animation: animation,
      setEntryStatus: widget.setEntryStatus,
      createNewEntry: widget.createNewEntry,
      deleteEntry: widget.deleteEntry,
      moveEntry: widget.moveEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: widget.heroDuration,
          pageBuilder: (BuildContext newContext, Animation animation, Animation secondaryAnimation) {
            return Hero(
              tag: widget.listId,
              child: _getListTile(_childKey, animation, true),
            );
          }
        ));

      },
      child: Padding(
        padding: _edgesNoBottom,
        child: Hero(
          tag: widget.listId,
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> progress,
            HeroFlightDirection direction,
            BuildContext fromContext,
            BuildContext toContext) {
              return _getListTile(_childKey, progress, true);
          },
          child: _getListTile(null, const AlwaysStoppedAnimation<double>(0), false),
        ),
      )
    );
  }
}

/// Contains the individual entries in a list
///
/// Is contained by [ListTileHero]

class ListTile extends StatefulWidget{
  final String listName;
  final String listId;
  final Key key;
  final List<EntryModel> activeEntries;
  final List<EntryModel> inactiveEntries;
  final bool showEntries;
  final Color tileColor;
  final double tileHeight;
  final EdgeInsets padding;
  final Animation<double> animation;
  final SetEntryStatus setEntryStatus;
  final CreateNewEntry createNewEntry;
  final DeleteEntry deleteEntry;
  final MoveEntry moveEntry;

  ListTile({
    this.key,
    this.animation = const AlwaysStoppedAnimation<double>(0),
    this.tileColor = const Color(0xFFDDDDDD),
    this.tileHeight = 50,
    this.padding = const EdgeInsets.all(8),
    this.showEntries = false,
    @required this.activeEntries,
    @required this.inactiveEntries,
    @required this.listName,
    @required this.listId,
    @required this.setEntryStatus,
    @required this.createNewEntry,
    @required this.deleteEntry,
    @required this.moveEntry,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListTileState();
  }
}

class _ListTileState extends State<ListTile> {
  static const double _backButtonWidth = 40;

  Widget _getBackButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        alignment: Alignment.center,
        height: widget.tileHeight,
        width: _backButtonWidth,
        child: Text("<"),
      ),
    );
  }

  Widget _getAnimatedBackButton(BuildContext context) {
    return SizeTransition(
      axis: Axis.horizontal,
      sizeFactor: CurvedAnimation(
        curve: Curves.ease,
        parent: Tween<double>(begin: 0, end: 1).animate(widget.animation)
      ),
      child: _getBackButton(context),
    );
  }

  Widget _getTopRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        _getAnimatedBackButton(context),
        Text(widget.listName)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: widget.padding,
      color: widget.tileColor,
      child: widget.showEntries ? Column(
        children: <Widget>[
          _getTopRow(context),
          Expanded(
            flex: 1,
            child: FliplistEntriesPage(
              listId: widget.listId,
              activeEntries: widget.activeEntries,
              inactiveEntries: widget.inactiveEntries,
              createNewEntry: widget.createNewEntry,
              deleteEntry: widget.deleteEntry,
              moveEntry: widget.moveEntry,
              setEntryStatus: widget.setEntryStatus,
            ),
          )
        ],
      ) : _getTopRow(context),
    );
  }
}