import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RobColor {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color blue  = Color(0xFF437C90);
  static const Color fadeGrey = Color.fromRGBO(0, 0, 0, 0.3);
}

class RobApp extends StatefulWidget {
  final Widget body;
  final String title;
  final Color mainColor;

  RobApp({
    Key key,
    @required this.body,
    this.title = 'RobApp Title',
    this.mainColor = RobColor.blue,
  }) :  assert(body != null),
        assert(title != null),
        assert(mainColor != null), super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RobAppState();
  }
}

class _RobAppState extends State<RobApp> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "RobApp NavigatorState");
  final HeroController heroController = HeroController();
  static const double _topBarHeight = 56;
  static const double _topBarFontSize = 18;
  static const EdgeInsetsGeometry _edges = EdgeInsets.all(8.0);
  static const TextStyle textStyle = const TextStyle(
    debugLabel: 'RobApp TextStyle',
    fontFamily: 'Roboto',
    inherit: true,
    color: RobColor.black,
    decoration: TextDecoration.none,
    fontSize: 18,
  );

  static const TextStyle titleTextStyle = const TextStyle(
    debugLabel: 'RobApp TextStyle',
    fontFamily: 'Roboto',
    inherit: true,
    color: RobColor.black,
    decoration: TextDecoration.none,
    fontSize: 24,
  );

  Widget _addTopBar(Widget child) {
    return Column(
      children: <Widget>[
        Container(
          alignment: AlignmentDirectional.centerStart,
          height: _topBarHeight,
          color: widget.mainColor,
          padding: _edges,
          child: Text(widget.title, style: titleTextStyle),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: AlignmentDirectional.topStart,
            color: RobColor.white,
            child: child,
          )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      key: GlobalObjectKey(this),
      textStyle: textStyle,
      debugShowWidgetInspector: false,
      debugShowCheckedModeBanner: true,
      navigatorKey: navigatorKey,
      color: RobColor.blue,
      navigatorObservers: [heroController],
      home: widget.body,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) => PageRouteBuilder<T>(
        pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
          return _addTopBar(widget.body);
        },
        transitionsBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation, Widget child) {
          return child;
        },
      ),
    );
  }
}

class RobPopupRoute extends PopupRoute {
  @override Duration get transitionDuration => const Duration(milliseconds: 200);
  @override Color get barrierColor => RobColor.fadeGrey;
  @override bool get barrierDismissible => true;
  @override String get barrierLabel => 'Dismissible Popup';
  final Widget child;

  RobPopupRoute({@required this.child});

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
        child: child,
      ),
    );
  }
}

class RobDialog extends RobPopupRoute {
  @override final Widget child;

  RobDialog({@required this.child});

  @override
  Widget buildPage (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      heightFactor: 0.5,
      child: Container(
        color: RobColor.white,
        child: child,
      ),
    );
  }
}