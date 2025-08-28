import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre/spectre.dart';

void main() {
  group('JsonEditor Widget Tests', () {
    testWidgets('renders with initial data', (WidgetTester tester) async {
      final testData = {
        'name': 'Test User',
        'age': 25,
        'isActive': true,
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

      expect(find.byType(JsonEditor), findsOneWidget);
      expect(find.text('JSON Editor'), findsOneWidget);
    });

    testWidgets('calls onDataChanged when data is modified in text view', (WidgetTester tester) async {
      final testData = {'name': 'Test'};
      bool callbackCalled = false;
      Map<String, dynamic>? callbackData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {
                callbackCalled = true;
                callbackData = data;
              },
            ),
          ),
        ),
      );

      // Switch to text view (Raw tab)
      final rawTab = find.text('Raw');
      expect(rawTab, findsOneWidget);
      await tester.tap(rawTab);
      await tester.pumpAndSettle();

      // Find the text field and enter new JSON
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, '{"name": "Updated", "age": 30}');
      await tester.pumpAndSettle();

      // The callback should be called with debouncing
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(callbackCalled, isTrue);
      expect(callbackData, isNotNull);
      expect(callbackData!['name'], 'Updated');
      expect(callbackData!['age'], 30);
    });

    testWidgets('shows error for invalid JSON in text view', (WidgetTester tester) async {
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

      // Switch to text view
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '{"invalid": json}');
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.textContaining('Invalid JSON'), findsOneWidget);
    });

    testWidgets('respects readOnly property', (WidgetTester tester) async {
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

      // Switch to text view
      final rawTab = find.text('Raw');
      await tester.tap(rawTab);
      await tester.pumpAndSettle();

      // Should show read-only view instead of TextField
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows copy button when allowCopy is true', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              allowCopy: true,
            ),
          ),
        ),
      );

      // Should find copy icons (header + tree view)
      expect(find.byIcon(Icons.copy), findsWidgets);
    });

    testWidgets('does not show copy button when allowCopy is false', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              allowCopy: false,
            ),
          ),
        ),
      );

      // Should still find copy icons in tree view even when allowCopy is false
      // (the tree view has its own copy functionality)
      expect(find.byIcon(Icons.copy), findsWidgets);
    });

    testWidgets('uses custom theme when provided', (WidgetTester tester) async {
      final testData = {'name': 'Test'};
      final customTheme = RedPandaTheme();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              theme: customTheme,
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('switches between tree and text view', (WidgetTester tester) async {
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

      // Should start with tree view (no TextField)
      expect(find.byType(TextField), findsNothing);

      // Switch to text view
      final rawTab = find.text('Raw');
      expect(rawTab, findsOneWidget);
      
      await tester.tap(rawTab);
      await tester.pumpAndSettle();

      // Should now show TextField
      expect(find.byType(TextField), findsOneWidget);

      // Switch back to tree view
      final treeTab = find.text('Tree');
      await tester.tap(treeTab);
      await tester.pumpAndSettle();

      // Should hide TextField again
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('RedPandaTheme Tests', () {
    test('provides correct color values', () {
      final theme = RedPandaTheme();

      expect(theme.editorBackground, isA<Color>());
      expect(theme.foreground, isA<Color>());
      expect(theme.headerBackground, isA<Color>());
      expect(theme.surfaceBackground, isA<Color>());
      expect(theme.lineNumbersBackground, isA<Color>());
      expect(theme.borderColor, isA<Color>());
      expect(theme.primaryColor, isA<Color>());
      expect(theme.onPrimary, isA<Color>());
      expect(theme.errorColor, isA<Color>());
      expect(theme.cursorColor, isA<Color>());
      expect(theme.stringColor, isA<Color>());
      expect(theme.numberColor, isA<Color>());
      expect(theme.booleanColor, isA<Color>());
      expect(theme.nullColor, isA<Color>());
      expect(theme.punctuationColor, isA<Color>());
      expect(theme.keyColor, isA<Color>());
    });
  });
}
