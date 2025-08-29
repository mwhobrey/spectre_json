import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectre_json/spectre_json.dart';

void main() {
  group('Data Change Expansion Tests', () {
    testWidgets('Expansion is re-applied when data changes', (WidgetTester tester) async {
      // Initial empty data
      final initialData = <String, dynamic>{};
      
      // Complex data that should be expanded
      final complexData = {
        'offerId': 'offer_12345',
        'userId': 'user_67890',
        'acceptanceDetails': {
          'timestamp': '2024-01-15T10:30:00Z',
          'metadata': {
            'sessionId': 'sess_abc123',
            'deviceInfo': {
              'platform': 'desktop',
              'browser': 'chrome',
            },
          },
        },
        'terms': {
          'sections': [
            {'id': 'privacy', 'accepted': true},
            {'id': 'terms', 'accepted': true},
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return JsonEditor(
                  initialData: initialData,
                  onDataChanged: (data) {},
                  expansionMode: ExpansionMode.all,
                  maxExpansionLevel: 5,
                  debugMode: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially, only root should be expanded (empty data)
      expect(find.text('offerId'), findsNothing);
      expect(find.text('acceptanceDetails'), findsNothing);

      // Now update the data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return JsonEditor(
                  initialData: complexData,
                  onDataChanged: (data) {},
                  expansionMode: ExpansionMode.all,
                  maxExpansionLevel: 5,
                  debugMode: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // After data change, all nodes should be expanded
      // Note: The tree view shows keys without quotes in the UI
      expect(find.text('offerId'), findsOneWidget);
      expect(find.text('acceptanceDetails'), findsOneWidget);
      expect(find.text('terms'), findsOneWidget);
    });

    testWidgets('Expansion mode changes are applied when data changes', (WidgetTester tester) async {
      final testData = {
        'level1': {
          'level2': {
            'level3': 'value',
          },
        },
        'array': [
          {'item': 'value1'},
          {'item': 'value2'},
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return JsonEditor(
                  initialData: testData,
                  onDataChanged: (data) {},
                  expansionMode: ExpansionMode.none,
                  debugMode: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With ExpansionMode.none, only root should be expanded
      expect(find.text('level1'), findsOneWidget);
      expect(find.text('level2'), findsNothing);
      expect(find.text('level3'), findsNothing);
      expect(find.text('array'), findsOneWidget);
      expect(find.text('item'), findsNothing);

      // Now change to ExpansionMode.all
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return JsonEditor(
                  initialData: testData,
                  onDataChanged: (data) {},
                  expansionMode: ExpansionMode.all,
                  debugMode: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With ExpansionMode.all, everything should be expanded
      expect(find.text('level1'), findsOneWidget);
      expect(find.text('array'), findsOneWidget);
    });
  });
}
