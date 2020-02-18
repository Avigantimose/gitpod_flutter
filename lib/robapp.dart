import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _edgeLength = 8;

class RobColor {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color blue  = Color(0xFF437C90);
  static const Color fadeGrey = Color.fromRGBO(0, 0, 0, 0.3);
}

class RobAppData {
  final String title;
  final Color mainColor;
  final double topBarHeight;
  final TextStyle textStyle;
  final TextStyle titleTextStyle;

  RobAppData({
    this.title,
    this.mainColor,
    this.topBarHeight,
    this.textStyle,
    this.titleTextStyle,
  });
}

class RobApp extends InheritedWidget {
  static const TextStyle _textStyle = TextStyle(
    debugLabel: 'RobApp TextStyle',
    fontFamily: 'Roboto',
    inherit: true,
    color: RobColor.black,
    decoration: TextDecoration.none,
    fontSize: 18,
  );

  static const TextStyle _titleTextStyle = TextStyle(
    debugLabel: 'RobApp TitleTextStyle',
    fontFamily: 'Roboto',
    inherit: true,
    color: RobColor.black,
    decoration: TextDecoration.none,
    fontSize: 24,
  );

  final Widget body;
  final String title;
  final Color mainColor;
  final double topBarHeight;
  final TextStyle textStyle;
  final TextStyle titleTextStyle;

  RobApp({
    Key key,
    @required this.body,
    this.title = 'RobApp Title',
    this.mainColor = RobColor.blue,
    this.topBarHeight = 56,
    this.textStyle = _textStyle,
    this.titleTextStyle = _titleTextStyle,
  }) :  assert(body != null),
    assert(title != null),
    assert(mainColor != null),
    super(key: key, child: _RobApp(
      title: title,
      mainColor: mainColor,
      topBarHeight: topBarHeight,
      textStyle: textStyle,
      titleTextStyle: titleTextStyle,
      body: body,
    ));

  @override
  bool updateShouldNotify(RobApp oldWidget) {
    return title != oldWidget.title
      || mainColor != oldWidget.mainColor
      || topBarHeight != oldWidget.topBarHeight
      || textStyle != oldWidget.textStyle
      || titleTextStyle != oldWidget.titleTextStyle;
  }

  static RobAppData of(BuildContext context) {
    RobApp robApp = context.dependOnInheritedWidgetOfExactType<RobApp>();
    return RobAppData(
      title: robApp.title,
      mainColor: robApp.mainColor,
      topBarHeight: robApp.topBarHeight,
      textStyle: robApp.textStyle,
      titleTextStyle: robApp.titleTextStyle,
    );
  }
}

class _RobApp extends StatefulWidget {
  final Widget body;
  final String title;
  final Color mainColor;
  final double topBarHeight;
  final TextStyle textStyle;
  final TextStyle titleTextStyle;

  _RobApp({
    Key key,
    @required this.body,
    @required this.title,
    @required this.mainColor,
    @required this.topBarHeight,
    @required this.textStyle,
    @required this.titleTextStyle,
  }) :  super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RobAppState();
  }
}

class _RobAppState extends State<_RobApp> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "RobApp NavigatorState");
  final HeroController heroController = HeroController();
  TextStyle textStyle;
  TextStyle titleTextStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget robApp = WidgetsApp(
      key: GlobalObjectKey(this),
      textStyle: textStyle,
      debugShowWidgetInspector: false,
      debugShowCheckedModeBanner: true,
      navigatorKey: navigatorKey,
      color: widget.mainColor,
      navigatorObservers: [heroController],
      title: widget.title,
      home: widget.body,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return builder(context);
          }
        );
      }
    );
    return DefaultTextStyle(
      style: widget.textStyle,
      child: robApp,
    );
  }
}

abstract class _RobRoute {
  static const Duration _duration = const Duration(milliseconds: 200);
  @override Duration get transitionDuration => _duration;
  @override bool get barrierDismissible => true;
  @override String get barrierLabel => '_RobRoute';
  @override Color get barrierColor => RobColor.fadeGrey;
  @override bool get maintainState => true;
  @override bool get opaque => false;
}

class RobPageRoute<T> extends PageRoute<T> with _RobRoute {
  final RoutePageBuilder pageBuilder;
  final Duration transitionDuration;

  RobPageRoute({
    @required this.pageBuilder,
    @required this.transitionDuration,
  });

  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Column(
      children: <Widget>[
        Container(height: MediaQuery.of(context).viewPadding.top,),
        Expanded(child: pageBuilder(context, animation, secondaryAnimation))
    ],
    );
  }
}

class RobPopupRoute<T> extends PageRoute<T> with _RobRoute {
  final Widget child;
  final Duration duration;

  RobPopupRoute({
    @required this.child,
    this.duration = _RobRoute._duration
  });

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

class RobFAB extends StatelessWidget {
  final void Function(BuildContext) onTapFab;
  final Color color;
  final Widget fabIcon;
  final double diameter;

  RobFAB({
    @required this.fabIcon,
    this.onTapFab,
    this.color,
    this.diameter = 100
  });

  @override
  Widget build(BuildContext context) {
    Color mainColor = RobApp.of(context).mainColor;
    return GestureDetector(
      onTap: () => onTapFab != null ? onTapFab(context) : null,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          color: color ?? mainColor,
        ),
        alignment: AlignmentDirectional.center,
        child: fabIcon,
      ),
    );
  }
  
}

class RobAppBar extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget fabIcon;
  final void Function(BuildContext) onTapFab;

  RobAppBar({
    Key key,
    @required this.child,
    this.title,
    this.fabIcon,
    this.onTapFab,
  }) : assert((fabIcon == null) == (onTapFab == null)),
  super(key: key);

  @override
  Widget build(BuildContext context) {
    RobAppData data = RobApp.of(context);
    double topOSStatusBarPadding = MediaQuery.of(context).viewPadding.top;
    Widget appBarWithChild = Container(
      color: RobColor.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: data.topBarHeight + topOSStatusBarPadding,
            color: data.mainColor,
            padding: EdgeInsets.only(
              top: topOSStatusBarPadding,
              left: _edgeLength
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Text(title ?? data.title, style: data.titleTextStyle),
          ),
          Expanded(
            child: child,
          )
        ],
      )
    );
    
    if (onTapFab == null) {
      return appBarWithChild;
    } else {
      return Stack(
        children: <Widget>[
          appBarWithChild,
          Positioned(
            right: _edgeLength,
            bottom: _edgeLength,
            child: RobFAB(
              fabIcon: fabIcon,
              onTapFab: onTapFab,
            )
          )
        ],
      );
    }
  }

}