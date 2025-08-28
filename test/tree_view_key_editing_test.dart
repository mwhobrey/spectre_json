import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre/spectre.dart';

void main() {
  group('JsonTreeView Key Editing Tests', () {
    testWidgets('Can edit key names in tree view', (WidgetTester tester) async {
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

      // Tap on the key name to start editing
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      // Should show text field for editing
      expect(find.byType(TextField), findsOneWidget);

      // Enter new key name
      await tester.enterText(find.byType(TextField), 'fullName');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify key was renamed
      expect(updatedData, isNotNull);
      expect(updatedData!.containsKey('fullName'), isTrue);
      expect(updatedData!['fullName'], equals('John Doe'));
      expect(updatedData!.containsKey('name'), isFalse);
      expect(updatedData!['age'], equals(30));
    });

    testWidgets('Cannot edit root node key', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
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

      // Tap on the root node name
      await tester.tap(find.text('root'));
      await tester.pumpAndSettle();

      // Should not show text field for editing
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Cannot edit keys when read-only', (WidgetTester tester) async {
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

      // Tap on the key name
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      // Should not show text field for editing
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Cannot create duplicate keys', (WidgetTester tester) async {
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

      // Tap on the key name to start editing
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      // Try to rename to an existing key
      await tester.enterText(find.byType(TextField), 'age');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Data should not be changed (duplicate key should be prevented)
      // The duplicate key should be prevented, so updatedData should be null
      expect(updatedData, isNull);
    });

    testWidgets('Can edit nested object keys', (WidgetTester tester) async {
      final testData = {
        'user': {
          'name': 'John Doe',
          'age': 30,
        },
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

      // Expand the user object
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Tap on the nested key name to start editing
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      // Enter new key name
      await tester.enterText(find.byType(TextField), 'fullName');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify nested key was renamed
      expect(updatedData, isNotNull);
      expect(updatedData!['user']['fullName'], equals('John Doe'));
      expect(updatedData!['user'].containsKey('name'), isFalse);
      expect(updatedData!['user']['age'], equals(30));
    });

    testWidgets('Empty key names are ignored', (WidgetTester tester) async {
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

      // Tap on the key name to start editing
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      // Enter empty key name
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Data should not be changed
      expect(updatedData, isNull);
    });

    testWidgets('Same key name is ignored', (WidgetTester tester) async {
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

      // Tap on the key name to start editing
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();

      // Enter same key name
      await tester.enterText(find.byType(TextField), 'name');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Data should not be changed
      expect(updatedData, isNull);
    });

    testWidgets('Key and value editing are mutually exclusive', (WidgetTester tester) async {
      final testData = {
        'name': 'John Doe',
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

      // Start editing the key
      await tester.tap(find.text('name'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      // Try to start editing the value
      await tester.tap(find.text('"John Doe"'));
      await tester.pumpAndSettle();

      // Should still be editing the key (only one text field)
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
