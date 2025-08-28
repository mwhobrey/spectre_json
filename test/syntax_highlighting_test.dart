import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Syntax Highlighting Tests', () {
    testWidgets('should highlight JSON syntax with RedPandaTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: '{"name": "John", "age": 30, "active": true, "data": null}',
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should highlight JSON syntax with custom theme', (tester) async {
      final customTheme = JsonEditorTheme.fromColors(
        editorBackground: Colors.grey[900]!,
        foreground: Colors.white,
        primaryColor: Colors.cyan,
        stringColor: Colors.lightGreen,
        numberColor: Colors.orange,
        booleanColor: Colors.pink,
        nullColor: Colors.yellow,
        punctuationColor: Colors.cyan,
        keyColor: Colors.lightBlue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: '{"name": "John", "age": 30, "active": true, "data": null}',
              theme: customTheme,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle complex JSON with nested structures', (tester) async {
      const complexJson = '''
{
  "user": {
    "id": 12345,
    "name": "John Doe",
    "email": "john@example.com",
    "active": true,
    "settings": null,
    "preferences": {
      "theme": "dark",
      "notifications": false
    },
    "tags": ["admin", "developer"],
    "metadata": {
      "created": "2024-01-01T00:00:00Z",
      "version": 1.2
    }
  }
}''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: complexJson,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle escaped characters in strings', (tester) async {
      const jsonWithEscapes = '{"message": "Hello\\nWorld", "path": "C:\\\\Users\\\\John"}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: jsonWithEscapes,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle scientific notation in numbers', (tester) async {
      const jsonWithScientific = '{"small": 1.23e-10, "large": 1.23e+10, "normal": 123.45}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: jsonWithScientific,
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle empty JSON object', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: '{}',
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle empty string', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: '',
              theme: RedPandaTheme(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: '{"name": "John", "age": 30}',
              theme: JsonEditorTheme.light(primaryColor: Colors.blue),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });

    testWidgets('should handle dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyntaxHighlightedText(
              text: '{"name": "John", "age": 30}',
              theme: JsonEditorTheme.dark(primaryColor: Colors.blue),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(SyntaxHighlightedText), findsOneWidget);
    });
  });
}
