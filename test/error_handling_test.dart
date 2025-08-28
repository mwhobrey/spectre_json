import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Error Handling and Edge Cases Tests', () {
    testWidgets('handles empty initial data', (WidgetTester tester) async {
      final emptyData = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: emptyData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
      // Empty JSON might not be visible as text in the tree view
    });

    testWidgets('handles complex nested data', (WidgetTester tester) async {
      final complexData = {
        'string': 'test',
        'number': 123.45,
        'boolean': true,
        'null': null,
        'array': [1, 2, 3, {'nested': 'value'}],
        'object': {
          'deep': {
            'very': {
              'nested': {
                'value': 'test'
              }
            }
          }
        }
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: complexData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles invalid JSON input gracefully', (WidgetTester tester) async {
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

      // Enter various invalid JSON formats
      final textField = find.byType(TextField);
      
      // Test missing closing brace
      await tester.enterText(textField, '{"name": "test"');
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.textContaining('Invalid JSON'), findsNWidgets(2));

      // Test invalid syntax
      await tester.enterText(textField, '{"name": test}');
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.textContaining('Invalid JSON'), findsNWidgets(2));

      // Test trailing comma
      await tester.enterText(textField, '{"name": "test",}');
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.textContaining('Invalid JSON'), findsNWidgets(2));
    });

    testWidgets('handles very large JSON data', (WidgetTester tester) async {
      // Create a large nested structure
      final largeData = <String, dynamic>{};
      for (int i = 0; i < 100; i++) {
        largeData['key$i'] = {
          'nested$i': {
            'value$i': 'test$i',
            'number$i': i,
            'array$i': List.generate(10, (j) => j),
          }
        };
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: largeData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles special characters in strings', (WidgetTester tester) async {
      final specialData = {
        'quotes': 'He said "Hello"',
        'newlines': 'Line 1\nLine 2\nLine 3',
        'tabs': 'Tab\tSeparated\tValues',
        'unicode': 'Unicode: 🚀🌟🎉',
        'escaped': 'Escaped: \\" \\n \\t',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: specialData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles scientific notation in numbers', (WidgetTester tester) async {
      final scientificData = {
        'small': 1.23e-10,
        'large': 1.23e+10,
        'mixed': [1.23e-5, 1.23e+5, 123.45],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: scientificData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles rapid text changes', (WidgetTester tester) async {
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

      final textField = find.byType(TextField);
      
      // Rapidly change text
      await tester.enterText(textField, '{"a": 1}');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, '{"b": 2}');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, '{"c": 3}');
      await tester.pump(const Duration(milliseconds: 800));

      // Should handle without errors
      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles clipboard operations gracefully', (WidgetTester tester) async {
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

      // Test copy functionality - find the first copy icon in the header
      final copyIcons = find.byIcon(Icons.copy);
      expect(copyIcons, findsWidgets);
      await tester.tap(copyIcons.first);
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('JSON copied to clipboard'), findsOneWidget);
    });

    testWidgets('handles theme with null colors gracefully', (WidgetTester tester) async {
      final testData = {'name': 'Test'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: testData,
              onDataChanged: (data) {},
              theme: RedPandaTheme(), // Should use default theme
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles widget disposal gracefully', (WidgetTester tester) async {
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

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Should not throw any errors
      expect(find.byType(JsonEditor), findsNothing);
    });

    testWidgets('handles empty strings in JSON', (WidgetTester tester) async {
      final emptyStringData = {
        'empty': '',
        'spaces': '   ',
        'normal': 'test',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: emptyStringData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });

    testWidgets('handles extreme numeric values', (WidgetTester tester) async {
      final extremeData = {
        'max_int': 9223372036854775807,
        'min_int': -9223372036854775808,
        'max_double': double.maxFinite,
        'min_double': double.minPositive,
        'infinity': double.infinity,
        'negative_infinity': double.negativeInfinity,
        'nan': double.nan,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JsonEditor(
              initialData: extremeData,
              onDataChanged: (data) {},
            ),
          ),
        ),
      );

      expect(find.byType(JsonEditor), findsOneWidget);
    });
  });
}
