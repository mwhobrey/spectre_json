import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Delete Confirmation Tests', () {
    testWidgets('Shows confirmation dialog by default', (WidgetTester tester) async {
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

      // Find and tap the delete button for the 'age' property
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "age"?'), findsOneWidget);
      expect(find.text('Don\'t ask again'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('Skips confirmation when skipDeleteConfirmation is true', (WidgetTester tester) async {
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
              skipDeleteConfirmation: true,
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

      // Verify no confirmation dialog appears
      expect(find.text('Delete Item'), findsNothing);
      expect(find.text('Are you sure you want to delete "age"?'), findsNothing);

      // Verify the 'age' property is deleted immediately
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsNothing);
    });

    testWidgets('"Don\'t ask again" checkbox works correctly', (WidgetTester tester) async {
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

      // Find and tap the delete button for the 'age' property
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Don\'t ask again'), findsOneWidget);

      // Check the "Don't ask again" checkbox
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Tap the Delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the 'age' property is deleted
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsNothing);
      expect(find.text('email'), findsOneWidget);

      // Now try to delete another property - should skip confirmation
      await tester.tap(deleteButtons.at(0)); // Delete 'name'
      await tester.pumpAndSettle();

      // Verify no confirmation dialog appears for the second deletion
      expect(find.text('Delete Item'), findsNothing);
      expect(find.text('Are you sure you want to delete "name"?'), findsNothing);

      // Verify the 'name' property is deleted immediately
      expect(find.text('name'), findsNothing);
      expect(find.text('email'), findsOneWidget);
    });

    testWidgets('"Don\'t ask again" preference is not set when checkbox is unchecked', (WidgetTester tester) async {
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

      // Find and tap the delete button for the 'age' property
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);

      // Don't check the "Don't ask again" checkbox, just tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the 'age' property is deleted
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsNothing);
      expect(find.text('email'), findsOneWidget);

      // Now try to delete another property - should show confirmation again
      await tester.tap(deleteButtons.at(0)); // Delete 'name'
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears again
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "name"?'), findsOneWidget);
    });

    testWidgets('Cancel button in confirmation dialog works correctly', (WidgetTester tester) async {
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

      // Tap the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify both properties are still visible
      expect(find.text('name'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);

      // Verify dialog is gone
      expect(find.text('Delete Item'), findsNothing);
    });

    testWidgets('"Don\'t ask again" checkbox state is preserved in dialog', (WidgetTester tester) async {
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

      // Find and tap the delete button for the 'age' property
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Don\'t ask again'), findsOneWidget);

      // Check the "Don't ask again" checkbox
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify checkbox is checked
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, true);

      // Uncheck the checkbox
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify checkbox is unchecked
      final checkboxWidget2 = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget2.value, false);
    });

    testWidgets('Delete confirmation works for array items', (WidgetTester tester) async {
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
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "1"?'), findsOneWidget);
      expect(find.text('Don\'t ask again'), findsOneWidget);

      // Check the "Don't ask again" checkbox
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Tap the Delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify 'item2' is deleted
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsNothing);
      expect(find.text('"item3"'), findsOneWidget);

      // Now try to delete another item - should skip confirmation
      await tester.tap(deleteButtons.at(0)); // Delete 'item1'
      await tester.pumpAndSettle();

      // Verify no confirmation dialog appears
      expect(find.text('Delete Item'), findsNothing);

      // Verify 'item1' is deleted immediately
      expect(find.text('"item1"'), findsNothing);
      expect(find.text('"item3"'), findsOneWidget);
    });
  });
}
