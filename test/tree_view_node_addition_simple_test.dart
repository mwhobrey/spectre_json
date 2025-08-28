import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('JsonTreeView Node Addition Simple Tests', () {
    testWidgets('Can add properties to objects', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
        'age': 30,
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

      // Root object is already expanded by default
      // Look for the "Add property" button
      expect(find.text('Add property'), findsOneWidget);

      // Tap on "Add property" button
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      // Should show text fields for adding
      expect(find.byType(TextField), findsNWidgets(2)); // Key and value fields

      // Enter property name
      await tester.enterText(find.byType(TextField).first, 'email');
      await tester.pumpAndSettle();

      // Enter property value
      await tester.enterText(find.byType(TextField).last, 'john@example.com');
      await tester.pumpAndSettle();

      // Submit the form by pressing Enter on the value field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify property was added
      expect(updatedData, isNotNull);
      print('DEBUG: updatedData = $updatedData');
      expect(updatedData!.containsKey('email'), isTrue);
      expect(updatedData!['email'], equals('john@example.com'));
      expect(updatedData!['name'], equals('John Doe'));
      expect(updatedData!['age'], equals(30));
    });

    testWidgets('Can add items to arrays', (WidgetTester tester) async {
      final testData = {
        'hobbies': ['reading', 'coding'],
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

      // Root object is already expanded by default
      // Need to expand the hobbies array first
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Now look for the "Add item" button
      expect(find.text('Add item'), findsOneWidget);

      // Tap on "Add item" button
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      // Should show text field for adding
      expect(find.byType(TextField), findsOneWidget);

      // Enter array item value
      await tester.enterText(find.byType(TextField), 'gaming');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify item was added
      expect(updatedData, isNotNull);
      expect(updatedData!['hobbies'], equals(['reading', 'coding', 'gaming']));
    });

    testWidgets('Cannot add items when read-only', (WidgetTester tester) async {
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

      // Should not show add property button in read-only mode
      expect(find.text('Add property'), findsNothing);
    });
  });
}
