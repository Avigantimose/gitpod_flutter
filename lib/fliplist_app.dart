import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'robapp.dart';
import 'models.dart';
import 'colors.dart';
import 'list_tile.dart';

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
  String _newListModalTitle = 'New list name:';
  String _cancel = 'Cancel';
  String _okay = 'Okay';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  static const double _edgeSize = 8;

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

    String entryId2 = _appView.addNewFliplist('Test List 2');
    _appView.getFliplist(entryId2)
      ..addEntry('Test Active', true)
      ..addEntry('Test Inactive', false);

      String entryId3 = _appView.addNewFliplist('Test List 3');
    _appView.getFliplist(entryId3)
      ..addEntry('Test Active', true)
      ..addEntry('Test Inactive', false);
    
  }

  void _showNewListDialog(BuildContext context) {
    Navigator.of(context).push(RobPopupRoute(
      child: Center(child: Container(
        color: FlipColor.white,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: Padding(
            padding: EdgeInsets.all(_edgeSize),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: _edgeSize),
                    child: Text(_newListModalTitle),
                  ),
                  FormField(
                    builder: (FormFieldState field) {
                      return Container(
                        color: FlipColor.white2,
                        margin: EdgeInsets.only(top: _edgeSize, bottom: _edgeSize),
                        padding: EdgeInsets.all(_edgeSize),
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
                            padding: EdgeInsets.all(_edgeSize),
                            color: FlipColor.white3,
                            child: Text(_cancel),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: _edgeSize),),
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
                            padding: EdgeInsets.all(_edgeSize),
                            color: FlipColor.white3,
                            child: Text(_okay),
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

  List<Widget> _getListTiles() {
    List<Widget> tiles = List();
    for (int i = 0; i < _appView.lists.length - 1; i++) {
      FliplistModel f = _appView.lists[i];
      bool isLast = i == _appView.lists.length - 1;
      EdgeInsets allMargin = EdgeInsets.only(left: _edgeSize, top: _edgeSize, right: _edgeSize);
      EdgeInsets lastMargin = EdgeInsets.all(_edgeSize);

      tiles.add(ListTile(
        listModel: f,
        margin: isLast ? lastMargin : allMargin,
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
      ));
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return RobApp(
      body: RobAppBar(
        fabIcon: Text('+', style: TextStyle(
          color: FlipColor.white,
          fontSize: 80
        )),
        onTapFab: (BuildContext context) {
          _showNewListDialog(context);
        },
        child: Column(
          children: _getListTiles()
        ),
      ),
      title: _title,
      mainColor: FlipColor.green,
    );
  }
}