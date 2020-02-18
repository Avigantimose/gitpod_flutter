import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'robapp.dart';
import 'colors.dart';
import 'models.dart';
import 'gesture_arrow_list.dart';

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

  PageController pageController;
  ScrollPhysics _scrollPhysics;
  ScrollController _scrollController;

  static const EdgeInsets _edgesAll = EdgeInsets.all(_edgeLength);
  static const EdgeInsets _edgesTopBottom = EdgeInsets.only(top: _edgeLength, bottom: _edgeLength);
  static const EdgeInsets _edgeLeft = EdgeInsets.only(left: _edgeLength);
  static const EdgeInsets _edgeTop = EdgeInsets.only(top: _edgeLength);

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _scrollPhysics = PageScrollPhysics();
    _scrollController = ScrollController(debugLabel: 'FliplistEntries scroll controller');
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
                            bool isActive = pageController.page == 0;
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

  Widget _getGestureArrowList(bool isActive) {
    return GestureArrowList(
      listId: widget.listId,
      isActive: isActive,
      entries: isActive ? widget.activeEntries : widget.inactiveEntries,
      setEntryStatus: widget.setEntryStatus,
      createEntry: widget.createNewEntry,
      deleteEntry: widget.deleteEntry,
      moveEntry: widget.moveEntry,
    );
  }

  Widget _getEntries(BuildContext context) {
    return Scrollable(
      axisDirection: AxisDirection.right,
      controller: pageController,
      physics: _scrollPhysics,
      viewportBuilder: (BuildContext viewportContext, ViewportOffset position){
        return ShrinkWrappingViewport(
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[SliverFillViewport(
            delegate: SliverChildListDelegate([
              _getGestureArrowList(true),
              _getGestureArrowList(false),
            ]),
          )],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
          child: IntrinsicHeight(
            child: Container(
              color: FlipColor.red,
              alignment: AlignmentDirectional.center,
              height: 1000,
              child: Text('test'),
            ),
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}