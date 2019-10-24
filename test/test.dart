import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitpod_flutter/robapp.dart';

class _TestDrag extends StatefulWidget {
  final void Function(double) onDragEnd;
  final Widget child;

  _TestDrag({
    @required this.onDragEnd,
    @required this.child,
  });

  @override
  State<_TestDrag> createState() {
    return _TestDragState();
  }
}

class _TestDragState extends State<_TestDrag> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animation;
  double offset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
    _animation = Tween(begin: Offset.zero).animate(_controller);
  }
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onHorizontalDragStart: (details) => setState((){
          offset = 0;
        }),
        onHorizontalDragUpdate: (details) => setState((){
          offset += details.primaryDelta;
        }),
        onHorizontalDragEnd: (details) => widget.onDragEnd(offset),
        child: widget.child,
      ),
    );
  }
}

void main() {
  testWidgets('Tester drag translates to gesture detector 1:1', (WidgetTester tester) async {
    const double screenWidth = 600;
    const double screenHeight = 800;
    const String name = 'Test Text';
    const double dragLength = 200;
    double actualDragTotal;

    Widget app = RobApp(
      body: Container(
        width:  screenWidth,
        height: screenHeight,
        child: _TestDrag(
          onDragEnd: (double dragTotal) => actualDragTotal = dragTotal,
          child: Text(name),
        )
      ),
    );

    await tester.pumpWidget(app);
    final Finder textFinder = find.text(name);
    await tester.drag(textFinder, Offset(dragLength, 0));
    await tester.pumpAndSettle();

    expect(actualDragTotal, dragLength);
  });
}