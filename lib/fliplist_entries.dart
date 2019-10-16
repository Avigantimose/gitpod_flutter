import 'dismissible_arrow_tile_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'robapp.dart';
import 'colors.dart';
import 'models.dart';

/// The individual entries of a list.
///
/// Contains [ArrowTile]s that can be swiped

class FliplistEntriesPage extends StatefulWidget {

  final String listId;
  final SetEntryStatus setEntryStatus;
  final CreateNewEntry createNewEntry;
  final DeleteEntry deleteEntry;
  final MoveEntry moveEntry;
  final List<EntryModel> activeEntries;
  final List<EntryModel> inactiveEntries;

  FliplistEntriesPage({
    Key key,
    @required this.listId,
    @required this.setEntryStatus,
    @required this.createNewEntry,
    @required this.deleteEntry,
    @required this.moveEntry,
    @required this.activeEntries,
    @required this.inactiveEntries,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FliplistEntriesPageState();
  }
}

class _FliplistEntriesPageState extends State<FliplistEntriesPage> with SingleTickerProviderStateMixin{
  static const double FLING_THESHOLD = 2;
  static const double _edgeLength = 8;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  PageController _scrollController;
  ScrollPhysics _scrollPhysics;

  static const EdgeInsets _edgesAll = EdgeInsets.all(_edgeLength);
  static const EdgeInsets _edgesTopBottom = EdgeInsets.only(top: _edgeLength, bottom: _edgeLength);
  static const EdgeInsets _edgeLeft = EdgeInsets.only(left: _edgeLength);
  static const EdgeInsets _edgeTop = EdgeInsets.only(top: _edgeLength);

  @override
  void initState() {
    super.initState();
    _scrollController = PageController();
    _scrollPhysics = PageScrollPhysics();
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
                    child: Text('New entry name:'),
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
                            String entryName = _textController.text;
                            bool isActive = _scrollController.page == 0;
                            widget.createNewEntry(
                              listId: widget.listId,
                              entryName: entryName,
                              status: isActive);
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

  Widget _getDismissibleArrowTileList(bool isActive) {
    return DismissibleArrowTileList(
      listId: widget.listId,
      entries: isActive ? widget.activeEntries : widget.inactiveEntries,
      isActive: isActive,
      setEntryStatus: widget.setEntryStatus,
      createNewEntry: widget.createNewEntry,
      deleteEntry: widget.deleteEntry,
      moveEntry: widget.moveEntry,
      onOverdragStart: () => setState(() {
        _scrollPhysics = NeverScrollableScrollPhysics();
      }),
      onOverdragUpdate: (double delta) => setState((){
        _scrollController.jumpTo(-delta);
      }),
      onOverdragEnd: () => setState((){
        _scrollPhysics = PageScrollPhysics();
      }),
    );
  }

  Widget _getEntries(BuildContext context) {
    return Scrollable(
      axisDirection: AxisDirection.right,
      controller: _scrollController,
      physics: _scrollPhysics,
      viewportBuilder: (BuildContext viewportContext, ViewportOffset position){
        return Viewport(
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[SliverFillViewport(
            delegate: SliverChildListDelegate([
              _getDismissibleArrowTileList(true),
              _getDismissibleArrowTileList(false)
              ,
            ]),
          )],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0, right: 0, bottom: 0, left: 0,
          child: _getEntries(context)
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _getAddButton(context),
        )
      ]
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}