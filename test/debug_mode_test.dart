import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/src/json_editor.dart';

void main() {
  group('Debug Mode Tests', () {
    testWidgets('Debug info should not appear when debugMode is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: {'name': 'John', 'age': 30},
              onDataChanged: (newData) {},
              title: 'Test Editor',
              debugMode: false, // Debug mode disabled
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Debug info should not be visible
      expect(find.textContaining('Debug Info'), findsNothing);
      expect(find.byIcon(Icons.bug_report), findsNothing);
    });
    
    testWidgets('Debug info should appear when debugMode is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: {'name': 'John', 'age': 30},
              onDataChanged: (newData) {},
              title: 'Test Editor',
              debugMode: true, // Debug mode enabled
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Switch to raw view to trigger debug entries
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();
      
      // Find text field and trigger some debug entries
      final textField = find.byType(TextField);
      await tester.enterText(textField, '{"invalid": json}');
      
      // Wait for debounce and debug entries to be added
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      
      // Debug info should be visible when there are entries
      expect(find.textContaining('Debug Info'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });
    
    testWidgets('Error messages should display properly in raw view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: {'name': 'John', 'age': 30},
              onDataChanged: (newData) {},
              title: 'Test Editor',
              debugMode: false,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Switch to raw view
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();
      
      // Enter invalid JSON
      final textField = find.byType(TextField);
      await tester.enterText(textField, '{"invalid": json}');
      
      // Wait for validation
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      
      // Error message should be visible
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Invalid JSON'), findsOneWidget);
    });
    
    testWidgets('Error messages should not overlap in raw view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: JsonEditor(
                initialData: {'name': 'John', 'age': 30},
                onDataChanged: (newData) {},
                title: 'Test Editor',
                debugMode: false,
                viewType: ViewType.rawOnly, // Use raw only to test error display
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Enter invalid JSON
      final textField = find.byType(TextField);
      await tester.enterText(textField, '{"invalid": json}');
      
      // Wait for validation
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      
      // Error message should be visible but not covering the input
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // The text field should still be accessible
      expect(find.byType(TextField), findsOneWidget);
      
      // Verify the layout doesn't cause overflow
      expect(tester.takeException(), isNull);
    });
  });
}
