import 'package:flutter_test/flutter_test.dart';
import 'package:bitchat_flutter/app.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BitchatApp());
    expect(find.text('匿匿'), findsOneWidget);
  });
}
