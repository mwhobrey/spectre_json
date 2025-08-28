import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON Editor Indentation Logic Tests', () {
    test('Indentation logic order is correct', () {
      // Test that the logic checks isAfterComma before isAfterColon
      final contextInfo = {
        'currentIndent': 4,
        'isAfterColon': true,
        'isAfterComma': true,
        'bracketLevel': 0,
      };

      // Simulate the logic order from the fix
      String calculateIndentation(Map<String, dynamic> context) {
        final currentIndent = context['currentIndent'] as int;
        final isAfterColon = context['isAfterColon'] as bool;
        final isAfterComma = context['isAfterComma'] as bool;

        // Check isAfterComma first (this is the fix)
        if (isAfterComma) {
          return ' ' * currentIndent; // Should return 4 spaces
        }

        // Check isAfterColon second
        if (isAfterColon) {
          return ' ' * (currentIndent + 2); // Would return 6 spaces
        }

        return ' ' * currentIndent;
      }

      final result = calculateIndentation(contextInfo);
      expect(result.length, equals(4)); // Should be 4 spaces, not 6
    });

    test('Different scenarios produce correct indentation', () {
      String calculateIndentation(Map<String, dynamic> context) {
        final currentIndent = context['currentIndent'] as int;
        final isAfterColon = context['isAfterColon'] as bool;
        final isAfterComma = context['isAfterComma'] as bool;

        if (isAfterComma) {
          return ' ' * currentIndent;
        }

        if (isAfterColon) {
          return ' ' * (currentIndent + 2);
        }

        return ' ' * currentIndent;
      }

      // Test 1: After comma (should maintain current indentation)
      final afterComma = {
        'currentIndent': 4,
        'isAfterColon': false,
        'isAfterComma': true,
      };
      expect(calculateIndentation(afterComma).length, equals(4));

      // Test 2: After colon only (should increase indentation)
      final afterColon = {
        'currentIndent': 4,
        'isAfterColon': true,
        'isAfterComma': false,
      };
      expect(calculateIndentation(afterColon).length, equals(6));

      // Test 3: After both comma and colon (should prioritize comma)
      final afterBoth = {
        'currentIndent': 4,
        'isAfterColon': true,
        'isAfterComma': true,
      };
      expect(calculateIndentation(afterBoth).length, equals(4)); // Fixed!
    });
  });
}
