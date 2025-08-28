import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre/spectre.dart';

void main() {
  group('ViewType Tests', () {
    testWidgets('dual view shows both tree and raw tabs', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              viewType: ViewType.dual,
            ),
          ),
        ),
      );

      // Should show both Tree and Raw tabs
      expect(find.text('Tree'), findsOneWidget);
      expect(find.text('Raw'), findsOneWidget);
      
      // Should start with tree view (no TextField)
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('treeOnly view shows only tree view', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      // Should not show any tabs
      expect(find.text('Tree'), findsNothing);
      expect(find.text('Raw'), findsNothing);
      
      // Should show tree view content directly
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('rawOnly view shows only raw editor', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

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

      // Should not show any tabs
      expect(find.text('Tree'), findsNothing);
      expect(find.text('Raw'), findsNothing);
      
      // Should show TextField directly
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('dual view allows switching between tabs', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              viewType: ViewType.dual,
            ),
          ),
        ),
      );

      // Should start with tree view
      expect(find.byType(TextField), findsNothing);

      // Switch to raw view
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();

      // Should now show TextField
      expect(find.byType(TextField), findsOneWidget);

      // Switch back to tree view
      await tester.tap(find.text('Tree'));
      await tester.pumpAndSettle();

      // Should hide TextField again
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('treeOnly view shows tree view content', (WidgetTester tester) async {
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
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      // Should show tree view content (the exact text might be in different widgets)
      expect(find.byType(JsonEditor), findsOneWidget);
      // Tree view should be visible (no TextField in tree view)
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('rawOnly view shows raw JSON content', (WidgetTester tester) async {
      final testData = {
        'name': 'Test',
        'nested': {'value': 123},
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

      // Should show formatted JSON in TextField
      expect(find.byType(TextField), findsOneWidget);
      
      // The TextField should contain the formatted JSON
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, contains('"name"'));
      expect(textField.controller!.text, contains('"Test"'));
      expect(textField.controller!.text, contains('"nested"'));
    });

    testWidgets('viewType changes update the interface', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              viewType: ViewType.dual,
            ),
          ),
        ),
      );

      // Should show tabs in dual mode
      expect(find.text('Tree'), findsOneWidget);
      expect(find.text('Raw'), findsOneWidget);

      // Change to treeOnly
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              viewType: ViewType.treeOnly,
            ),
          ),
        ),
      );

      // Should not show tabs
      expect(find.text('Tree'), findsNothing);
      expect(find.text('Raw'), findsNothing);

      // Change to rawOnly
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

      // Should show TextField directly
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('default viewType is dual', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              // viewType not specified, should default to dual
            ),
          ),
        ),
      );

      // Should show both tabs (default behavior)
      expect(find.text('Tree'), findsOneWidget);
      expect(find.text('Raw'), findsOneWidget);
    });
  });
}
