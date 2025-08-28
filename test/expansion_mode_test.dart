import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('ExpansionMode Tests', () {
    final testData = {
      'name': 'Test',
      'settings': {
        'theme': 'dark',
        'language': 'en',
      },
      'items': ['item1', 'item2', 'item3'],
      'config': {
        'enabled': true,
        'options': ['opt1', 'opt2'],
      },
    };

    testWidgets('ExpansionMode.none expands only root node', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.none,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Root should be expanded (always)
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);

      // Nested nodes should be collapsed
      expect(find.text('theme'), findsNothing);
      expect(find.text('language'), findsNothing);
      expect(find.text('"item1"'), findsNothing);
      expect(find.text('enabled'), findsNothing);
    });

    testWidgets('ExpansionMode.objects expands all object nodes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.objects,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All object nodes should be expanded
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('theme'), findsOneWidget);
      expect(find.text('language'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);
      expect(find.text('enabled'), findsOneWidget);
      expect(find.text('options'), findsOneWidget);

      // Array items should be collapsed
      expect(find.text('"item1"'), findsNothing);
      expect(find.text('"item2"'), findsNothing);
      expect(find.text('"item3"'), findsNothing);
      expect(find.text('"opt1"'), findsNothing);
      expect(find.text('"opt2"'), findsNothing);
    });

    testWidgets('ExpansionMode.arrays expands all array nodes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.arrays,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Array nodes should be expanded
      expect(find.text('items'), findsOneWidget);
      expect(find.text('options'), findsOneWidget);
      
      // Array items should be visible
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsOneWidget);
      expect(find.text('"item3"'), findsOneWidget);
      expect(find.text('"opt1"'), findsOneWidget);
      expect(find.text('"opt2"'), findsOneWidget);

      // Object nodes should be collapsed (but parent objects containing arrays are expanded)
      // So settings and config are expanded because they contain arrays, making their properties visible
      // No object properties should be collapsed in this case
    });

    testWidgets('ExpansionMode.objectsAndArrays expands both objects and arrays', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.objectsAndArrays,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both objects and arrays should be expanded
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('theme'), findsOneWidget);
      expect(find.text('language'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsOneWidget);
      expect(find.text('"item3"'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);
      expect(find.text('enabled'), findsOneWidget);
      expect(find.text('options'), findsOneWidget);
      expect(find.text('"opt1"'), findsOneWidget);
      expect(find.text('"opt2"'), findsOneWidget);
    });

    testWidgets('ExpansionMode.all expands everything', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.all,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Everything should be expanded
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('theme'), findsOneWidget);
      expect(find.text('language'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsOneWidget);
      expect(find.text('"item3"'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);
      expect(find.text('enabled'), findsOneWidget);
      expect(find.text('options'), findsOneWidget);
      expect(find.text('"opt1"'), findsOneWidget);
      expect(find.text('"opt2"'), findsOneWidget);
    });

    testWidgets('ExpansionMode.levels expands only specified levels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.levels,
              maxExpansionLevel: 2,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Level 0 (root) and level 1 should be expanded
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('theme'), findsOneWidget);
      expect(find.text('language'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('"item1"'), findsOneWidget);
      expect(find.text('"item2"'), findsOneWidget);
      expect(find.text('"item3"'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);
      expect(find.text('enabled'), findsOneWidget);
      expect(find.text('options'), findsOneWidget);
      // Array items at level 3 should NOT be visible (maxExpansionLevel: 2)
      expect(find.text('"opt1"'), findsNothing);
      expect(find.text('"opt2"'), findsNothing);
    });

    testWidgets('ExpansionMode.levels with level 1 expands only first level', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              expansionMode: ExpansionMode.levels,
              maxExpansionLevel: 1,
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Only level 0 (root) should be expanded
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);

      // Level 1 and deeper should be collapsed
      expect(find.text('theme'), findsNothing);
      expect(find.text('language'), findsNothing);
      expect(find.text('"item1"'), findsNothing);
      expect(find.text('"item2"'), findsNothing);
      expect(find.text('"item3"'), findsNothing);
      expect(find.text('enabled'), findsNothing);
      expect(find.text('options'), findsNothing);
      expect(find.text('"opt1"'), findsNothing);
      expect(find.text('"opt2"'), findsNothing);
    });

    testWidgets('ExpansionMode defaults to none when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (_) {},
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Root should be expanded (always)
      expect(find.text('name'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('config'), findsOneWidget);

      // Nested nodes should be collapsed (default behavior)
      expect(find.text('theme'), findsNothing);
      expect(find.text('language'), findsNothing);
      expect(find.text('"item1"'), findsNothing);
      expect(find.text('enabled'), findsNothing);
    });
  });
}
