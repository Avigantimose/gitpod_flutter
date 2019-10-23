import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitpod_flutter/robapp.dart';

void main() {
    testWidgets('Test RobApp displays title', (WidgetTester tester) async {
    const title = 'Test Title';
    await tester.pumpWidget(RobApp(
      title: title,
      body: Container(),
    ));

    final titleFinder = find.text(title);

    expect(titleFinder, findsOneWidget);
  });
}