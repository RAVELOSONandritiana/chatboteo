import 'package:flutter_test/flutter_test.dart';
import 'package:chatbot/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatBotApp());
    await tester.pump();
  });
}
