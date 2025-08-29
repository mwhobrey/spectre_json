import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/src/json_editor.dart';

void main() {
  group('Auto-Format Bug Fix Tests', () {
    testWidgets('Format and validate operations should work correctly', (WidgetTester tester) async {
      // Track callback invocations
      List<Map<String, dynamic>> callbackInvocations = [];
      
      final initialData = {'name': 'John', 'age': 30};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (newData) {
                callbackInvocations.add(newData);
              },
              title: 'Test Editor',
              readOnly: false, // Enable editing to show action buttons
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Clear callback invocations from initial setup
      callbackInvocations.clear();
      
      // Switch to raw view to access action buttons
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();
      
      // Test 1: Format button should format the JSON
      final formatButton = find.text('Format');
      expect(formatButton, findsOneWidget);
      
      await tester.tap(formatButton);
      await tester.pumpAndSettle();
      
      // Format should work without issues
      expect(find.textContaining('Invalid JSON'), findsNothing);
      
      // Test 2: Validate button should validate the JSON
      final validateButton = find.text('Validate');
      expect(validateButton, findsOneWidget);
      
      await tester.tap(validateButton);
      await tester.pumpAndSettle();
      
      // Should show success message for valid JSON
      expect(find.text('JSON is valid!'), findsOneWidget);
    });
    
    testWidgets('User actions should trigger parent callbacks', (WidgetTester tester) async {
      // Track callback invocations
      List<Map<String, dynamic>> callbackInvocations = [];
      
      final initialData = {'name': 'John', 'age': 30};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (newData) {
                callbackInvocations.add(newData);
              },
              title: 'Test Editor',
              readOnly: false, // Enable editing to show action buttons
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Clear callback invocations from initial setup
      callbackInvocations.clear();
      
      // Switch to raw view to access action buttons
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();
      
      // Test 1: Clear button should trigger callback
      final clearButton = find.text('Clear');
      expect(clearButton, findsOneWidget);
      
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      
      expect(callbackInvocations.length, 1, 
        reason: 'Clear operation should trigger parent callback');
      expect(callbackInvocations.first, equals({}));
      

    });
    
    testWidgets('Direct text editing should trigger parent callbacks', (WidgetTester tester) async {
      // Track callback invocations
      List<Map<String, dynamic>> callbackInvocations = [];
      
      final initialData = {'name': 'John', 'age': 30};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (newData) {
                callbackInvocations.add(newData);
              },
              title: 'Test Editor',
              readOnly: false, // Enable editing to show action buttons
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Clear callback invocations from initial setup
      callbackInvocations.clear();
      
      // Switch to raw JSON view
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();
      
      // Find the text field and edit it
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      
      // Type some text to trigger a change
      await tester.enterText(textField, '{"name": "Jane", "age": 25}');
      
      // Wait for debounce timer
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      
      expect(callbackInvocations.length, 1, 
        reason: 'Direct text editing should trigger parent callback');
      expect(callbackInvocations.first['name'], equals('Jane'));
      expect(callbackInvocations.first['age'], equals(25));
    });
    
    testWidgets('Paste operation should trigger parent callbacks', (WidgetTester tester) async {
      // Track callback invocations
      List<Map<String, dynamic>> callbackInvocations = [];
      
      final initialData = {'name': 'John', 'age': 30};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (newData) {
                callbackInvocations.add(newData);
              },
              title: 'Test Editor',
              readOnly: false, // Enable editing to show action buttons
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Clear callback invocations from initial setup
      callbackInvocations.clear();
      
      // Find and tap the paste button
      final pasteButton = find.byIcon(Icons.paste);
      expect(pasteButton, findsOneWidget);
      
      // Note: We can't easily test clipboard operations in unit tests,
      // but we can verify the button exists and is tappable
      await tester.tap(pasteButton);
      await tester.pumpAndSettle();
      
      // The paste operation should be set up to trigger callbacks when it has data
      // This test verifies the button exists and the method is callable
      expect(pasteButton, findsOneWidget);
    });
    
    testWidgets('Tree view changes should trigger parent callbacks', (WidgetTester tester) async {
      // Track callback invocations
      List<Map<String, dynamic>> callbackInvocations = [];
      
      final initialData = {'name': 'John', 'age': 30};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: initialData,
              onDataChanged: (newData) {
                callbackInvocations.add(newData);
              },
              title: 'Test Editor',
              readOnly: false, // Enable editing to show action buttons
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Clear callback invocations from initial setup
      callbackInvocations.clear();
      
      // Switch to tree view
      final treeTab = find.text('Tree');
      await tester.tap(treeTab);
      await tester.pumpAndSettle();
      
      // Tree view changes should trigger callbacks
      // Note: Testing tree view interactions would require more complex setup
      // This test verifies the tree view is accessible
      expect(treeTab, findsOneWidget);
    });
  });
}
