import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('JsonTreeView Node Addition Tests', () {
    testWidgets('Can add properties to objects', (WidgetTester tester) async {
      final testData = <String, dynamic>{
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
      expect(updatedData!.containsKey('email'), isTrue);
      expect(updatedData!['email'], equals('john@example.com'));
      expect(updatedData!['name'], equals('John Doe'));
      expect(updatedData!['age'], equals(30));
    });

    testWidgets('Can add arrays as property values', (WidgetTester tester) async {
      final testData = <String, dynamic>{
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

      // Root object is already expanded by default
      // Tap on "Add property" button
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      // Should show text fields for adding
      expect(find.byType(TextField), findsNWidgets(2)); // Key and value fields

      // Enter property name
      await tester.enterText(find.byType(TextField).first, 'hobbies');
      await tester.pumpAndSettle();

      // Enter array value
      await tester.enterText(find.byType(TextField).last, '["reading", "coding"]');
      await tester.pumpAndSettle();

      // Submit the form by pressing Enter on the value field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify array property was added
      expect(updatedData, isNotNull);
      expect(updatedData!.containsKey('hobbies'), isTrue);
      expect(updatedData!['hobbies'], isA<List>());
      expect(updatedData!['hobbies'], equals(['reading', 'coding']));
    });

    testWidgets('Can add objects as property values', (WidgetTester tester) async {
      final testData = <String, dynamic>{
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

      // Root object is already expanded by default
      // Tap on "Add property" button
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      // Should show text fields for adding
      expect(find.byType(TextField), findsNWidgets(2)); // Key and value fields

      // Enter property name
      await tester.enterText(find.byType(TextField).first, 'address');
      await tester.pumpAndSettle();

      // Enter object value
      await tester.enterText(find.byType(TextField).last, '{"street": "123 Main St", "city": "Anytown"}');
      await tester.pumpAndSettle();

      // Submit the form by pressing Enter on the value field
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify object property was added
      expect(updatedData, isNotNull);
      expect(updatedData!.containsKey('address'), isTrue);
      expect(updatedData!['address'], isA<Map>());
      expect(updatedData!['address']['street'], equals('123 Main St'));
      expect(updatedData!['address']['city'], equals('Anytown'));
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
      // Need to expand the hobbies array
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
        'age': 30,
      };

      Map<String, dynamic>? updatedData;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonTreeView(
              data: testData,
              onDataChanged: (data) => updatedData = data,
              readOnly: true,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      // Root object is already expanded by default
      // Should not show "Add property" button in read-only mode
      expect(find.text('Add property'), findsNothing);
      expect(updatedData, isNull);
    });

    testWidgets('Cannot add duplicate properties', (WidgetTester tester) async {
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
      // Add a property
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      // Try to add a duplicate property
      await tester.enterText(find.byType(TextField).first, 'name');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Jane Doe');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show error and not update data
      expect(find.text('Property "name" already exists'), findsOneWidget);
      expect(updatedData, isNull);
    });

    testWidgets('Cannot add empty property names', (WidgetTester tester) async {
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
      // Add a property
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      // Try to add empty property name
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'value');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show error and not update data
      expect(find.text('Property name cannot be empty'), findsOneWidget);
      expect(updatedData, isNull);
    });

    testWidgets('Cannot add empty array items', (WidgetTester tester) async {
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
      // Need to expand the hobbies array
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Add an item
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      // Try to add empty value
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show error and not update data
      expect(find.text('Array item value cannot be empty'), findsOneWidget);
      expect(updatedData, isNull);
    });

    testWidgets('Array type validation works for integers', (WidgetTester tester) async {
      final testData = {
        'numbers': [1, 2, 3],
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
      // Need to expand the numbers array
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Add an integer item
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '4');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify integer was added correctly
      expect(updatedData, isNotNull);
      expect(updatedData!['numbers'], equals([1, 2, 3, 4]));
    });

    testWidgets('Array type validation rejects invalid types', (WidgetTester tester) async {
      final testData = {
        'numbers': [1, 2, 3],
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
      // Need to expand the numbers array
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Add an invalid item
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should show error for invalid type
      expect(find.text('Expected integer value'), findsOneWidget);
      expect(updatedData, isNull);
    });

    testWidgets('Array type validation works for booleans', (WidgetTester tester) async {
      final testData = {
        'flags': [true, false],
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
      // Need to expand the flags array
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Add a boolean item
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'true');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify boolean was added correctly
      expect(updatedData, isNotNull);
      expect(updatedData!['flags'], equals([true, false, true]));
    });

    testWidgets('Empty arrays allow any type', (WidgetTester tester) async {
      final testData = {
        'items': <dynamic>[],
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
      // Need to expand the items array
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Add a string item
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify string was added correctly
      expect(updatedData, isNotNull);
      expect(updatedData!['items'], equals(['test']));
    });

    testWidgets('Suggested keys are unique', (WidgetTester tester) async {
      final testData = {
        'property1': 'value1',
        'property2': 'value2',
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
      // Add a property
      await tester.tap(find.text('Add property'));
      await tester.pumpAndSettle();

      // Check that the suggested key is unique
      final textField = find.byType(TextField).first;
      final controller = tester.widget<TextField>(textField).controller;
      expect(controller?.text, equals('property3'));

      // Enter a different key
      await tester.enterText(textField, 'newProperty');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'newValue');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify property was added
      expect(updatedData, isNotNull);
      expect(updatedData!.containsKey('newProperty'), isTrue);
      expect(updatedData!['newProperty'], equals('newValue'));
    });
  });
}
