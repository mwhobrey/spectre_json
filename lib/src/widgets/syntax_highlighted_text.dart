import 'package:flutter/material.dart';
import '../theme/red_panda_theme.dart';

class SyntaxHighlightedText extends StatelessWidget {
  final String text;
  final JsonEditorTheme theme;

  const SyntaxHighlightedText({
    super.key,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: theme.foreground,
          height: 1.4,
          textBaseline: TextBaseline.alphabetic,
        ),
        children: _buildHighlightedSpans(),
      ),
    );
  }

  List<TextSpan> _buildHighlightedSpans() {
    final spans = <TextSpan>[];

    // Handle empty JSON case
    if (text.trim().isEmpty || text.trim() == '{}') {
      spans.add(
        TextSpan(
          text: '{\n}',
          style: TextStyle(color: theme.punctuationColor),
        ),
      );
      return spans;
    }

    // Split into lines for better handling
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Handle empty lines
      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Process each character for syntax highlighting
      int pos = 0;
      while (pos < line.length) {
        final char = line[pos];

        if (char == '"') {
          // Find the end of the string (handle escaped quotes)
          int endQuote = pos + 1;
          while (endQuote < line.length) {
            if (line[endQuote] == '"' && line[endQuote - 1] != '\\') {
              break;
            }
            endQuote++;
          }
          
          if (endQuote < line.length) {
            final stringContent = line.substring(pos, endQuote + 1);
            final isKey = endQuote + 1 < line.length && 
                         line[endQuote + 1] == ':' &&
                         _isValidKey(stringContent);

            spans.add(
              TextSpan(
                text: stringContent,
                style: TextStyle(
                  color: isKey ? theme.keyColor : theme.stringColor,
                  fontWeight: isKey ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
            pos = endQuote + 1;
          } else {
            // Incomplete string
            spans.add(
              TextSpan(
                text: char,
                style: TextStyle(color: theme.stringColor),
              ),
            );
            pos++;
          }
        } else if (char == ':' || char == ',') {
          spans.add(
            TextSpan(
              text: char,
              style: TextStyle(
                color: theme.punctuationColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
          pos++;
        } else if (char == '{' || char == '}' || char == '[' || char == ']') {
          spans.add(
            TextSpan(
              text: char,
              style: TextStyle(
                color: theme.punctuationColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
          pos++;
        } else if (_isNumberStart(char)) {
          // Find the complete number (including scientific notation)
          final numberMatch = RegExp(
            r'^-?\d+\.?\d*(?:[eE][+-]?\d+)?',
          ).firstMatch(line.substring(pos));
          if (numberMatch != null) {
            final number = numberMatch.group(0)!;
            spans.add(
              TextSpan(
                text: number,
                style: TextStyle(
                  color: theme.numberColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
            pos += number.length;
          } else {
            spans.add(
              TextSpan(
                text: char,
                style: TextStyle(color: theme.foreground),
              ),
            );
            pos++;
          }
        } else if (_isBooleanStart(char, line, pos)) {
          final boolean = _extractBoolean(line, pos);
          if (boolean != null) {
            spans.add(
              TextSpan(
                text: boolean,
                style: TextStyle(
                  color: theme.booleanColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
            pos += boolean.length;
          } else {
            spans.add(
              TextSpan(
                text: char,
                style: TextStyle(color: theme.foreground),
              ),
            );
            pos++;
          }
        } else if (_isNullStart(char, line, pos)) {
          if (pos + 3 < line.length && line.substring(pos, pos + 4) == 'null') {
            spans.add(
              TextSpan(
                text: 'null',
                style: TextStyle(
                  color: theme.nullColor,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
            pos += 4;
          } else {
            spans.add(
              TextSpan(
                text: char,
                style: TextStyle(color: theme.foreground),
              ),
            );
            pos++;
          }
        } else if (char == '\\') {
          // Handle escaped characters
          if (pos + 1 < line.length) {
            final escapedChar = line[pos + 1];
            spans.add(
              TextSpan(
                text: '\\$escapedChar',
                style: TextStyle(
                  color: theme.stringColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
            pos += 2;
          } else {
            spans.add(
              TextSpan(
                text: char,
                style: TextStyle(color: theme.foreground),
              ),
            );
            pos++;
          }
        } else {
          // Default case - whitespace or other characters
          spans.add(
            TextSpan(
              text: char,
              style: TextStyle(color: theme.foreground),
            ),
          );
          pos++;
        }
      }

      // Add newline if not the last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  /// Check if a character is the start of a number
  bool _isNumberStart(String char) {
    return RegExp(r'[0-9\-]').hasMatch(char);
  }

  /// Check if a character is the start of a boolean value
  bool _isBooleanStart(String char, String line, int pos) {
    if (char == 't' && pos + 3 < line.length) {
      return line.substring(pos, pos + 4) == 'true';
    } else if (char == 'f' && pos + 4 < line.length) {
      return line.substring(pos, pos + 5) == 'false';
    }
    return false;
  }

  /// Extract boolean value from the line starting at pos
  String? _extractBoolean(String line, int pos) {
    if (pos + 3 < line.length && line.substring(pos, pos + 4) == 'true') {
      return 'true';
    } else if (pos + 4 < line.length && line.substring(pos, pos + 5) == 'false') {
      return 'false';
    }
    return null;
  }

  /// Check if a character is the start of null value
  bool _isNullStart(String char, String line, int pos) {
    return char == 'n' && pos + 3 < line.length && line.substring(pos, pos + 4) == 'null';
  }

  /// Check if a string is a valid JSON key
  bool _isValidKey(String stringContent) {
    // Remove quotes and check if it looks like a key
    final key = stringContent.substring(1, stringContent.length - 1);
    // A key should not be empty and should not contain only whitespace
    return key.isNotEmpty && key.trim().isNotEmpty;
  }
}
