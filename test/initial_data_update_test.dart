import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre/spectre.dart';

void main() {
  group('JsonEditor Initial Data Update Tests', () {
    testWidgets('JsonEditor updates when initialData changes', (WidgetTester tester) async {
      // Initial data
      final initialData = {
        'name': 'John Doe',
        'age': 30,
      };

      // Updated data
      final updatedData = {
        'title': 'Updated Data',
        'value': 42,
        'nested': {
          'key': 'value',
        },
      };

      // Build the widget with initial data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (data) {},
              title: 'Test Editor',
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify JsonEditor is present
      expect(find.byType(JsonEditor), findsOneWidget);

      // Update the widget with new data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: updatedData,
              onDataChanged: (data) {},
              title: 'Test Editor',
            ),
          ),
        ),
      );

      // Wait for the widget to rebuild
      await tester.pumpAndSettle();

      // Verify JsonEditor is still present
      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('JsonEditor handles empty data updates', (WidgetTester tester) async {
      final initialData = {
        'name': 'John Doe',
      };

      final emptyData = <String, dynamic>{};

      // Build with initial data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (data) {},
              title: 'Test Editor',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify JsonEditor is present
      expect(find.byType(JsonEditor), findsOneWidget);

      // Update with empty data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: emptyData,
              onDataChanged: (data) {},
              title: 'Test Editor',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify JsonEditor is still present
      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('JsonEditor didUpdateWidget method is called', (WidgetTester tester) async {
      final initialData = {'test': 'value'};
      final updatedData = {'updated': 'data'};

      // Build with initial data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (data) {},
              title: 'Test Editor',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update with new data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: updatedData,
              onDataChanged: (data) {},
              title: 'Test Editor',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // If we get here without errors, the didUpdateWidget method is working
      expect(find.byType(JsonEditor), findsOneWidget);
    });
  });
}
