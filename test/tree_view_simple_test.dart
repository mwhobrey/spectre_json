import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre/spectre.dart';

void main() {
  group('JsonTreeView Simple Tests', () {
    testWidgets('Tree view renders with edit functionality', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
        'age': 30,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonTreeView(
              data: testData,
              onDataChanged: (data) {},
              readOnly: false,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      // Should find the root node
      expect(find.text('root'), findsOneWidget);
      expect(find.text('2 items'), findsOneWidget);

      // Should find the leaf node values
      expect(find.text('"John Doe"'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      // Should find edit buttons (using a more flexible approach)
      final allIcons = find.byType(Icon);
      final editIcons = allIcons.evaluate().where((element) {
        final icon = element.widget as Icon;
        return icon.icon == Icons.edit;
      }).toList();
      
      expect(editIcons.length, equals(2)); // One for each leaf node
    });

    testWidgets('Can edit values by tapping on them', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
      };

      Map<String, dynamic>? updatedData;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonTreeView(
              data: testData,
              onDataChanged: (data) => updatedData = data,
              readOnly: false,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      // Tap on the value text to start editing
      await tester.tap(find.text('"John Doe"'));
      await tester.pumpAndSettle();

      // Should show text field for editing
      expect(find.byType(TextField), findsOneWidget);

      // Enter new value
      await tester.enterText(find.byType(TextField), 'Jane Smith');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify data was updated
      expect(updatedData, isNotNull);
      expect(updatedData!['name'], equals('Jane Smith'));
    });

    testWidgets('Read-only mode disables editing', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonTreeView(
              data: testData,
              onDataChanged: (data) {},
              readOnly: true,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      // Tap on the value text
      await tester.tap(find.text('"John Doe"'));
      await tester.pumpAndSettle();

      // Should not show text field for editing
      expect(find.byType(TextField), findsNothing);
    });
  });
}
