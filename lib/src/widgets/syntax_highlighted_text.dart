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
          style: TextStyle(color: theme.foreground),
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
          // Find the end of the string
          final endQuote = line.indexOf('"', pos + 1);
          if (endQuote != -1) {
            final stringContent = line.substring(pos, endQuote + 1);
            final isKey =
                endQuote + 1 < line.length && line[endQuote + 1] == ':';

            spans.add(
              TextSpan(
                text: stringContent,
                style: TextStyle(
                  color: isKey ? theme.keyColor : theme.stringColor,
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
              style: TextStyle(color: theme.punctuationColor),
            ),
          );
          pos++;
        } else if (char == '{' || char == '}' || char == '[' || char == ']') {
          spans.add(
            TextSpan(
              text: char,
              style: TextStyle(color: theme.punctuationColor),
            ),
          );
          pos++;
        } else if (RegExp(r'[0-9]').hasMatch(char)) {
          // Find the complete number
          final numberMatch = RegExp(
            r'^\d+\.?\d*',
          ).firstMatch(line.substring(pos));
          if (numberMatch != null) {
            final number = numberMatch.group(0)!;
            spans.add(
              TextSpan(
                text: number,
                style: TextStyle(color: theme.numberColor),
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
        } else if (char == 't' &&
            pos + 3 < line.length &&
            line.substring(pos, pos + 4) == 'true') {
          spans.add(
            TextSpan(
              text: 'true',
              style: TextStyle(color: theme.booleanColor),
            ),
          );
          pos += 4;
        } else if (char == 'f' &&
            pos + 4 < line.length &&
            line.substring(pos, pos + 5) == 'false') {
          spans.add(
            TextSpan(
              text: 'false',
              style: TextStyle(color: theme.booleanColor),
            ),
          );
          pos += 5;
        } else if (char == 'n' &&
            pos + 3 < line.length &&
            line.substring(pos, pos + 4) == 'null') {
          spans.add(
            TextSpan(
              text: 'null',
              style: TextStyle(color: theme.nullColor),
            ),
          );
          pos += 4;
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
}
