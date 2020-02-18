import 'package:fliplist/fliplist_entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';
import 'package:fliplist/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'robapp.dart';
import 'models.dart';
import 'colors.dart';

const double _edgeSize = 8;

class ListTile extends StatefulWidget{
  static const double _tileHeight = 50;
  static const double _backButtonWidth = 40;
  static const Duration _duration = Duration(milliseconds: 300);
  static const EdgeInsets _margin = EdgeInsets.all(8);
  static const EdgeInsets _padding = EdgeInsets.all(0);

  final Key key;
  final String listName;
  final String listId;
  final List<EntryModel> activeEntries;
  final List<EntryModel> inactiveEntries;
  final double tileHeight;
  final Color tileColor;
  final double backButtonWidth;
  final Duration duration;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final SetEntryStatus setEntryStatus;
  final CreateNewEntry createNewEntry;
  final DeleteEntry deleteEntry;
  final MoveEntry moveEntry;

  ListTile({
    this.key,
    @required FliplistModel listModel, 
    this.tileHeight = _tileHeight,
    this.tileColor = FlipColor.white3,
    this.backButtonWidth = _backButtonWidth,
    this.duration = _duration,
    this.padding = _padding,
    this.margin = _margin,
    @required this.setEntryStatus,
    @required this.createNewEntry,
    @required this.deleteEntry,
    @required this.moveEntry,
  }) :
    this.listName = listModel.name,
    this.listId = listModel.id,
    this.activeEntries = listModel.activeEntries,
    this.inactiveEntries = listModel.inactiveEntries,
    super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return _ListTileState();
  }
}

class _ListTileState extends State<ListTile> {
  Animation<double> animation = AlwaysStoppedAnimation(0);

  @override
  void initState(){
    super.initState();
  }

  Widget _backButton(BuildContext context, Function() onTap, Animation<double> animation) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizeTransition(
        axis: Axis.horizontal,
        sizeFactor: CurveTween(curve: Curves.easeInOut).animate(animation),
        axisAlignment: 1,
        child: Container(
          alignment: Alignment.center,
          height: widget.tileHeight,
          width: widget.backButtonWidth,
          child: Icon(FontAwesomeIcons.solidArrowAltCircleLeft),
        )
      ),
    );
  }

  Widget _getTile(BuildContext context, {Animation<double> animation = const AlwaysStoppedAnimation(0)}) {
    Widget backButtonAndListName = Row(
      children: <Widget>[
        _backButton(context, () => Navigator.pop(context), animation),
        Padding(
          padding: EdgeInsets.only(left: _edgeSize),
          child: Text(widget.listName),
        )
      ],
    );

    Widget entries = FliplistEntriesPage(
      listId: widget.listId,
      setEntryStatus: widget.setEntryStatus,
      createNewEntry: widget.createNewEntry,
      deleteEntry: widget.deleteEntry,
      moveEntry: widget.moveEntry,
      activeEntries: widget.activeEntries,
      inactiveEntries: widget.inactiveEntries
    );

    Widget tile = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        backButtonAndListName,
        Expanded(
          child: SizeTransition(
            sizeFactor: animation,
            child: SingleChildScrollView(
              child: entries
            ),
          ),
        ),
      ],
    );

    return Container(
      alignment: AlignmentDirectional.center,
      padding: widget.padding,
      height: widget.tileHeight,
      color: FlipColor.white3,
      child: tile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(RobPageRoute(
          transitionDuration: widget.duration,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> animationSecondary) {
            return Hero(
              tag: widget.listId,
              child: _getTile(context, animation: animation),
            );
          }
        ));
      },
      child: Container(
        margin: widget.margin,
        child: Hero(
          tag: widget.listId,
          child: _getTile(context),
          flightShuttleBuilder: (BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection, BuildContext fromHeroContext, BuildContext toHeroContext) {
            final Hero hero = flightDirection == HeroFlightDirection.push ? toHeroContext.widget : fromHeroContext.widget;
            return hero.child;
          },
        )
      )
    );
  }
}
