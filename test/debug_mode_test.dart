import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Debug Mode Tests', () {
    testWidgets('Debug mode parameter is passed correctly', (WidgetTester tester) async {
      final testData = {
        'name': 'Test',
        'settings': {
          'theme': 'dark',
          'items': ['item1', 'item2'],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              expansionMode: ExpansionMode.all,
              maxExpansionLevel: 3,
              debugMode: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors when debug mode is enabled
      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('Debug mode disabled works correctly', (WidgetTester tester) async {
      final testData = {
        'name': 'Test',
        'settings': {
          'theme': 'dark',
          'items': ['item1', 'item2'],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              expansionMode: ExpansionMode.all,
              maxExpansionLevel: 3,
              debugMode: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors when debug mode is disabled
      expect(find.byType(JsonEditor), findsOneWidget);
    });
  });
}
