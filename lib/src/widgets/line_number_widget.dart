import 'package:flutter/material.dart';
import '../theme/red_panda_theme.dart';

class LineNumberWidget extends StatelessWidget {
  final String text;
  final JsonEditorTheme theme;

  const LineNumberWidget({super.key, required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final lineHeight = 13.0 * 1.4; // Match text editor line height

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        lines.length,
        (index) => SizedBox(
          height: lineHeight,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: theme.foreground.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
