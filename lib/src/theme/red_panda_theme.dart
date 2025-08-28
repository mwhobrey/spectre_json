import 'package:flutter/material.dart';

/// Abstract base class for JSON editor themes.
/// 
/// This class defines the interface for custom themes that can be used
/// with the [JsonEditor] widget. Implement this class to create custom
/// color schemes for the JSON editor.
/// 
/// ## Example
/// 
/// ```dart
/// class CustomTheme extends JsonEditorTheme {
///   @override
///   Color get editorBackground => Colors.grey[900]!;
///   
///   @override
///   Color get foreground => Colors.white;
///   
///   // ... implement all other color getters
/// }
/// ```
abstract class JsonEditorTheme {
  Color get editorBackground;
  Color get foreground;
  Color get headerBackground;
  Color get surfaceBackground;
  Color get lineNumbersBackground;
  Color get borderColor;
  Color get primaryColor;
  Color get onPrimary;
  Color get errorColor;
  Color get cursorColor;
  Color get stringColor;
  Color get numberColor;
  Color get booleanColor;
  Color get nullColor;
  Color get punctuationColor;
  Color get keyColor;
}

/// A beautiful dark theme with red accents for the JSON editor.
/// 
/// This theme provides a modern, dark color scheme with red accent colors
/// that creates an elegant and professional appearance for the JSON editor.
/// 
/// ## Color Scheme
/// 
/// * **Background**: Dark grey (#2E3638)
/// * **Foreground**: Light grey (#C7CED1)
/// * **Primary**: Blue (#5F93D3)
/// * **Strings**: Green (#C0EE5D)
/// * **Numbers**: Light grey (#C7CED1)
/// * **Booleans/Null**: Purple (#AC3980)
/// * **Error**: Red (#F73B45)
class RedPandaTheme implements JsonEditorTheme {
  @override
  Color get editorBackground => const Color(0xFF2E3638);

  @override
  Color get foreground => const Color(0xFFC7CED1);

  @override
  Color get headerBackground => const Color(0xFF2F3537);

  @override
  Color get surfaceBackground => const Color(0xFF171B1C);

  @override
  Color get lineNumbersBackground => const Color(0xFF2F3537);

  @override
  Color get borderColor => const Color(0xFF171B1C);

  @override
  Color get primaryColor => const Color(0xFF5F93D3);

  @override
  Color get onPrimary => Colors.white;

  @override
  Color get errorColor => const Color(0xFFF73B45);

  @override
  Color get cursorColor => const Color(0xFFC7CED1);

  @override
  Color get stringColor => const Color(0xFFC0EE5D);

  @override
  Color get numberColor => const Color(0xFFC7CED1);

  @override
  Color get booleanColor => const Color(0xFFAC3980);

  @override
  Color get nullColor => const Color(0xFFAC3980);

  @override
  Color get punctuationColor => const Color(0xFF5F93D3);

  @override
  Color get keyColor => const Color(0xFFC0EE5D);
}
