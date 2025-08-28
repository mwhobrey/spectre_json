import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Theme System Tests', () {
    test('JsonEditorTheme.fromColors creates custom theme', () {
      final customTheme = JsonEditorTheme.fromColors(
        editorBackground: Colors.red,
        foreground: Colors.white,
        primaryColor: Colors.blue,
      );

      expect(customTheme.editorBackground, equals(Colors.red));
      expect(customTheme.foreground, equals(Colors.white));
      expect(customTheme.primaryColor, equals(Colors.blue));
      
      // Should use defaults for unspecified colors
      expect(customTheme.stringColor, isA<Color>());
      expect(customTheme.numberColor, isA<Color>());
      expect(customTheme.booleanColor, isA<Color>());
    });

    test('JsonEditorTheme.fromColors uses sensible defaults', () {
      final minimalTheme = JsonEditorTheme.fromColors();

      // Should have all required colors with defaults
      expect(minimalTheme.editorBackground, isA<Color>());
      expect(minimalTheme.foreground, isA<Color>());
      expect(minimalTheme.headerBackground, isA<Color>());
      expect(minimalTheme.surfaceBackground, isA<Color>());
      expect(minimalTheme.lineNumbersBackground, isA<Color>());
      expect(minimalTheme.borderColor, isA<Color>());
      expect(minimalTheme.primaryColor, isA<Color>());
      expect(minimalTheme.onPrimary, isA<Color>());
      expect(minimalTheme.errorColor, isA<Color>());
      expect(minimalTheme.cursorColor, isA<Color>());
      expect(minimalTheme.stringColor, isA<Color>());
      expect(minimalTheme.numberColor, isA<Color>());
      expect(minimalTheme.booleanColor, isA<Color>());
      expect(minimalTheme.nullColor, isA<Color>());
      expect(minimalTheme.punctuationColor, isA<Color>());
      expect(minimalTheme.keyColor, isA<Color>());
    });

    test('JsonEditorTheme.light creates light theme', () {
      final lightTheme = JsonEditorTheme.light();

      expect(lightTheme.editorBackground, isA<Color>());
      expect(lightTheme.foreground, isA<Color>());
      expect(lightTheme.primaryColor, isA<Color>());
      
      // Light theme should have light colors
      expect(lightTheme.editorBackground, isNot(equals(Colors.black)));
    });

    test('JsonEditorTheme.light with custom primary color', () {
      final lightTheme = JsonEditorTheme.light(primaryColor: Colors.purple);

      expect(lightTheme.primaryColor, equals(Colors.purple));
    });

    test('JsonEditorTheme.dark creates dark theme', () {
      final darkTheme = JsonEditorTheme.dark();

      expect(darkTheme.editorBackground, isA<Color>());
      expect(darkTheme.foreground, isA<Color>());
      expect(darkTheme.primaryColor, isA<Color>());
      
      // Dark theme should have dark colors
      expect(darkTheme.editorBackground, isNot(equals(Colors.white)));
    });

    test('JsonEditorTheme.dark with custom primary color', () {
      final darkTheme = JsonEditorTheme.dark(primaryColor: Colors.orange);

      expect(darkTheme.primaryColor, equals(Colors.orange));
    });

    testWidgets('JsonEditorTheme.material creates theme from context', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final materialTheme = JsonEditorTheme.material(context);
              
              // Should have all required colors
              expect(materialTheme.editorBackground, isA<Color>());
              expect(materialTheme.foreground, isA<Color>());
              expect(materialTheme.primaryColor, isA<Color>());
              
              return Container();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('JsonEditor uses custom theme', (WidgetTester tester) async {
      final testData = {'name': 'Test'};
      final customTheme = JsonEditorTheme.fromColors(
        editorBackground: Colors.red,
        primaryColor: Colors.blue,
      );

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

    testWidgets('JsonEditor uses default theme when none provided', (WidgetTester tester) async {
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

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('theme updates when widget is rebuilt', (WidgetTester tester) async {
      final testData = {'name': 'Test'};
      final theme1 = JsonEditorTheme.fromColors(primaryColor: Colors.red);
      final theme2 = JsonEditorTheme.fromColors(primaryColor: Colors.blue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              theme: theme1,
            ),
          ),
        ),
      );

      // Rebuild with different theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              theme: theme2,
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    test('RedPandaTheme has correct color values', () {
      final theme = RedPandaTheme();

      // Check specific color values
      expect(theme.editorBackground, equals(const Color(0xFF2E3638)));
      expect(theme.foreground, equals(const Color(0xFFC7CED1)));
      expect(theme.primaryColor, equals(const Color(0xFF5F93D3)));
      expect(theme.stringColor, equals(const Color(0xFFC0EE5D)));
      expect(theme.numberColor, equals(const Color(0xFF5F93D3)));
      expect(theme.booleanColor, equals(const Color(0xFFAC3980)));
      expect(theme.nullColor, equals(const Color(0xFFE67E22)));
      expect(theme.punctuationColor, equals(const Color(0xFF5F93D3)));
      expect(theme.keyColor, equals(const Color(0xFFC0EE5D)));
    });

    test('light theme has appropriate light colors', () {
      final theme = JsonEditorTheme.light();

      // Light theme should have light background
      expect(theme.editorBackground, isNot(equals(Colors.black)));
      expect(theme.foreground, isNot(equals(Colors.white)));
      
      // Should have error color
      expect(theme.errorColor, isA<Color>());
    });

    test('dark theme has appropriate dark colors', () {
      final theme = JsonEditorTheme.dark();

      // Dark theme should have dark background
      expect(theme.editorBackground, isNot(equals(Colors.white)));
      expect(theme.foreground, isNot(equals(Colors.black)));
      
      // Should have error color
      expect(theme.errorColor, isA<Color>());
    });
  });
}
