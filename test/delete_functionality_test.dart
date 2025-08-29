import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Delete Functionality Tests', () {
    testWidgets('Can delete properties from objects', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
        'age': 30,
        'email': 'john@example.com',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              expansionMode: ExpansionMode.all,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all properties are visible
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);
      expect(find.text('email'), findsOneWidget);

      // Find and tap the delete button for the 'age' property
      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsNWidgets(3)); // One for each property

      // Tap the second delete button (for 'age')
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "age"?'), findsOneWidget);

      // Tap the Delete button in the dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the 'age' property is no longer visible
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsNothing);
      expect(find.text('email'), findsOneWidget);

      // Verify only 2 delete buttons remain
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets('Can delete items from arrays', (WidgetTester tester) async {
      final testData = {
        'items': ['item1', 'item2', 'item3'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              expansionMode: ExpansionMode.all,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all items are visible
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsOneWidget);
      expect(find.text('"item3"'), findsOneWidget);

      // Find and tap the delete button for the second item
      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsNWidgets(3)); // One for each array item

      // Tap the second delete button (for 'item2')
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      // Array items are displayed with their index, not their value
      expect(find.text('Are you sure you want to delete "1"?'), findsOneWidget);

      // Tap the Delete button in the dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify 'item2' is no longer visible
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsNothing);
      expect(find.text('"item3"'), findsOneWidget);

      // Verify only 2 delete buttons remain
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets('Cancel delete operation', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
        'age': 30,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              expansionMode: ExpansionMode.all,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both properties are visible
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);

      // Find and tap the delete button for the 'age' property
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);

      // Tap the Cancel button in the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify both properties are still visible
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);

      // Verify dialog is gone
      expect(find.text('Delete Item'), findsNothing);
    });

    testWidgets('Delete button not shown in read-only mode', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
        'age': 30,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              readOnly: true,
              expansionMode: ExpansionMode.all,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify properties are visible
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);

      // Verify no delete buttons are shown in read-only mode
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}
