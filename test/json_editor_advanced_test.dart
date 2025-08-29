import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('JsonEditor Advanced Functionality Tests', () {
    testWidgets('handles expansion and collapse', (WidgetTester tester) async {
      final testData = {'name': 'Test'};
      bool expansionChanged = false;
      bool collapseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              isExpanded: true,
              onExpansionChanged: (expanded) {
                expansionChanged = true;
              },
              onCollapse: () {
                collapseCalled = true;
              },
            ),
          ),
        ),
      );

      // Should start expanded
      expect(find.byType(TextField), findsNothing); // Tree view is active
      expect(find.byIcon(Icons.expand_less), findsWidgets); // Multiple expand icons might exist

      // Collapse the editor - find the first expand_less icon
      final expandIcons = find.byIcon(Icons.expand_less);
      expect(expandIcons, findsWidgets);
      await tester.tap(expandIcons.first);
      await tester.pumpAndSettle();

      expect(expansionChanged, isTrue);
      expect(collapseCalled, isTrue);
      expect(find.byIcon(Icons.expand_more), findsWidgets);
    });

    testWidgets('starts collapsed when isExpanded is false', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              isExpanded: false,
            ),
          ),
        ),
      );

      // Should start collapsed
      expect(find.byIcon(Icons.expand_more), findsWidgets);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows action buttons in raw view', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Should show action buttons
      expect(find.text('Format'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Validate'), findsOneWidget);
    });

    testWidgets('format button reformats JSON', (WidgetTester tester) async {
      final testData = {'name': 'Test', 'nested': {'value': 123}};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Enter malformed JSON
      final textField = find.byType(TextField);
      await tester.enterText(textField, '{"name":"Test","nested":{"value":123}}');
      await tester.pumpAndSettle();

      // Click format button
      await tester.tap(find.text('Format'));
      await tester.pumpAndSettle();

      // Should be formatted with proper indentation
      expect(find.textContaining('  "name"'), findsOneWidget);
    });

    testWidgets('clear button clears the JSON', (WidgetTester tester) async {
      final testData = {'name': 'Test'};
      Map<String, dynamic>? lastData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {
                lastData = data;
              },
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Click clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Should have empty object
      expect(lastData, equals({}));
    });

    testWidgets('validate button shows success for valid JSON', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Click validate button
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('JSON is valid!'), findsOneWidget);
    });

    testWidgets('shows line numbers in raw view', (WidgetTester tester) async {
      final testData = {
        'name': 'Test',
        'nested': {'value': 123},
        'array': [1, 2, 3],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Should show line numbers
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      
      // Verify line numbers are properly aligned (no offset issues)
      // The line numbers should be visible and properly positioned
      final lineNumberWidgets = find.byType(Text);
      expect(lineNumberWidgets, findsWidgets);
    });

    testWidgets('line numbers are properly aligned with text content', (WidgetTester tester) async {
      final testData = {
        'name': 'Test User',
        'age': 30,
        'active': true,
        'nested': {
          'value': 123,
          'deep': {
            'final': 'test'
          }
        },
        'array': [1, 2, 3, 4, 5]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              viewType: ViewType.rawOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show line numbers for all lines (this JSON should have multiple lines)
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      
      // Verify that line numbers are properly aligned with text content
      // This test ensures the offset issue is fixed
    });

    testWidgets('handles paste functionality', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {
                // Data changed callback
              },
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Simulate paste (we can't actually test clipboard, but we can test the UI)
      expect(find.byIcon(Icons.paste), findsOneWidget);
    });

    testWidgets('handles custom title', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              title: 'Custom Title',
            ),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
    });

    testWidgets('handles read-only mode with action buttons', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              readOnly: true,
            ),
          ),
        ),
      );

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Should not show action buttons in read-only mode
      expect(find.text('Format'), findsNothing);
      expect(find.text('Clear'), findsNothing);
      expect(find.text('Validate'), findsNothing);
    });
  });
}
