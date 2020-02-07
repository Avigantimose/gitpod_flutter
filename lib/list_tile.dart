import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';
import 'package:fliplist/colors.dart';

import 'robapp.dart';
import 'fliplist_entries.dart';
import 'models.dart';
import 'colors.dart';

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

class _ListTileState extends State<ListTile> with SingleTickerProviderStateMixin {
  Animation<double> heroAnimation;

  @override
  void initState(){
    super.initState();

  }

  Widget _backButton(BuildContext context, Function() onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: widget.tileHeight,
        width: widget.backButtonWidth,
        child: Text("<"),
      ),
    );
  }

  Widget _getTile(BuildContext context) {
    return Container(
      color: FlipColor.white2,
      child: Row(children: <Widget>[
        _backButton(context, () => Navigator.pop(context)),
        Text(widget.listName)
      ],),
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
              child: _getTile(context),
            );
          }
        ));
      },
      child: Hero(
        tag: widget.listId,
        child: _getTile(context),
      )
    );
  }
}
