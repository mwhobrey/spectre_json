import 'package:flutter/material.dart';

/// Abstract base class for JSON editor themes.
/// 
/// This class defines the interface for custom themes that can be used
/// with the [JsonEditor] widget. You can either implement this class directly
/// or use the [JsonEditorTheme.fromColors] factory constructor for quick setup.
/// 
/// ## Example 1: Using factory constructor (recommended)
/// 
/// ```dart
/// JsonEditor(
///   initialData: data,
///   onDataChanged: (newData) {},
///   theme: JsonEditorTheme.fromColors(
///     editorBackground: Colors.grey[900]!,
///     foreground: Colors.white,
///     primaryColor: Colors.blue,
///     stringColor: Colors.green,
///   ),
/// )
/// ```
/// 
/// ## Example 2: Extending the class
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

  /// Creates a custom theme from individual color parameters.
  /// 
  /// This factory constructor allows you to quickly create a custom theme
  /// by specifying only the colors you want to customize. Any colors not
  /// specified will use sensible defaults based on the provided colors.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// JsonEditorTheme.fromColors(
  ///   editorBackground: Colors.grey[900]!,
  ///   foreground: Colors.white,
  ///   primaryColor: Colors.blue,
  ///   stringColor: Colors.green,
  /// )
  /// ```
  factory JsonEditorTheme.fromColors({
    Color? editorBackground,
    Color? foreground,
    Color? headerBackground,
    Color? surfaceBackground,
    Color? lineNumbersBackground,
    Color? borderColor,
    Color? primaryColor,
    Color? onPrimary,
    Color? errorColor,
    Color? cursorColor,
    Color? stringColor,
    Color? numberColor,
    Color? booleanColor,
    Color? nullColor,
    Color? punctuationColor,
    Color? keyColor,
  }) {
    return _CustomJsonEditorTheme(
      editorBackground: editorBackground,
      foreground: foreground,
      headerBackground: headerBackground,
      surfaceBackground: surfaceBackground,
      lineNumbersBackground: lineNumbersBackground,
      borderColor: borderColor,
      primaryColor: primaryColor,
      onPrimary: onPrimary,
      errorColor: errorColor,
      cursorColor: cursorColor,
      stringColor: stringColor,
      numberColor: numberColor,
      booleanColor: booleanColor,
      nullColor: nullColor,
      punctuationColor: punctuationColor,
      keyColor: keyColor,
    );
  }

  /// Creates a light theme with the specified primary color.
  /// 
  /// This convenience method creates a light theme with a white background
  /// and dark text, using the provided primary color for accents.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// JsonEditorTheme.light(primaryColor: Colors.blue)
  /// ```
  factory JsonEditorTheme.light({Color? primaryColor}) {
    final primary = primaryColor ?? Colors.blue;
    return JsonEditorTheme.fromColors(
      editorBackground: Colors.white,
      foreground: Colors.black87,
      headerBackground: Colors.grey[50],
      surfaceBackground: Colors.grey[100],
      lineNumbersBackground: Colors.grey[50],
      borderColor: Colors.grey[300],
      primaryColor: primary,
      onPrimary: Colors.white,
      errorColor: Colors.red[600],
      cursorColor: Colors.black87,
      stringColor: Colors.green[700],
      numberColor: Colors.blue[700],
      booleanColor: Colors.purple[700],
      nullColor: Colors.orange[700],
      punctuationColor: primary,
      keyColor: Colors.green[700],
    );
  }

  /// Creates a dark theme with the specified primary color.
  /// 
  /// This convenience method creates a dark theme with a dark background
  /// and light text, using the provided primary color for accents.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// JsonEditorTheme.dark(primaryColor: Colors.blue)
  /// ```
  factory JsonEditorTheme.dark({Color? primaryColor}) {
    final primary = primaryColor ?? Colors.blue[400];
    return JsonEditorTheme.fromColors(
      editorBackground: Colors.grey[900],
      foreground: Colors.white,
      headerBackground: Colors.grey[850],
      surfaceBackground: Colors.grey[800],
      lineNumbersBackground: Colors.grey[850],
      borderColor: Colors.grey[700],
      primaryColor: primary,
      onPrimary: Colors.white,
      errorColor: Colors.red[400],
      cursorColor: Colors.white,
      stringColor: Colors.green[400],
      numberColor: Colors.blue[300],
      booleanColor: Colors.purple[400],
      nullColor: Colors.orange[400],
      punctuationColor: primary,
      keyColor: Colors.green[400],
    );
  }

  /// Creates a theme that matches the current Material theme.
  /// 
  /// This convenience method creates a theme that adapts to the current
  /// Material theme's brightness and primary color.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// JsonEditorTheme.material(context)
  /// ```
  factory JsonEditorTheme.material(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (isDark) {
      return JsonEditorTheme.dark(primaryColor: theme.primaryColor);
    } else {
      return JsonEditorTheme.light(primaryColor: theme.primaryColor);
    }
  }
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
  Color get numberColor => const Color(0xFF5F93D3);

  @override
  Color get booleanColor => const Color(0xFFAC3980);

  @override
  Color get nullColor => const Color(0xFFE67E22);

  @override
  Color get punctuationColor => const Color(0xFF5F93D3);

  @override
  Color get keyColor => const Color(0xFFC0EE5D);
}

/// Internal implementation of a custom JSON editor theme.
/// 
/// This class is used by the [JsonEditorTheme.fromColors] factory constructor
/// to create custom themes with user-specified colors and sensible defaults.
class _CustomJsonEditorTheme implements JsonEditorTheme {
  final Color? _editorBackground;
  final Color? _foreground;
  final Color? _headerBackground;
  final Color? _surfaceBackground;
  final Color? _lineNumbersBackground;
  final Color? _borderColor;
  final Color? _primaryColor;
  final Color? _onPrimary;
  final Color? _errorColor;
  final Color? _cursorColor;
  final Color? _stringColor;
  final Color? _numberColor;
  final Color? _booleanColor;
  final Color? _nullColor;
  final Color? _punctuationColor;
  final Color? _keyColor;

  const _CustomJsonEditorTheme({
    Color? editorBackground,
    Color? foreground,
    Color? headerBackground,
    Color? surfaceBackground,
    Color? lineNumbersBackground,
    Color? borderColor,
    Color? primaryColor,
    Color? onPrimary,
    Color? errorColor,
    Color? cursorColor,
    Color? stringColor,
    Color? numberColor,
    Color? booleanColor,
    Color? nullColor,
    Color? punctuationColor,
    Color? keyColor,
  }) : _editorBackground = editorBackground,
       _foreground = foreground,
       _headerBackground = headerBackground,
       _surfaceBackground = surfaceBackground,
       _lineNumbersBackground = lineNumbersBackground,
       _borderColor = borderColor,
       _primaryColor = primaryColor,
       _onPrimary = onPrimary,
       _errorColor = errorColor,
       _cursorColor = cursorColor,
       _stringColor = stringColor,
       _numberColor = numberColor,
       _booleanColor = booleanColor,
       _nullColor = nullColor,
       _punctuationColor = punctuationColor,
       _keyColor = keyColor;

  @override
  Color get editorBackground => _editorBackground ?? const Color(0xFF2E3638);

  @override
  Color get foreground => _foreground ?? const Color(0xFFC7CED1);

  @override
  Color get headerBackground => _headerBackground ?? _surfaceBackground ?? const Color(0xFF2F3537);

  @override
  Color get surfaceBackground => _surfaceBackground ?? const Color(0xFF171B1C);

  @override
  Color get lineNumbersBackground => _lineNumbersBackground ?? _headerBackground ?? const Color(0xFF2F3537);

  @override
  Color get borderColor => _borderColor ?? _surfaceBackground ?? const Color(0xFF171B1C);

  @override
  Color get primaryColor => _primaryColor ?? const Color(0xFF5F93D3);

  @override
  Color get onPrimary => _onPrimary ?? Colors.white;

  @override
  Color get errorColor => _errorColor ?? const Color(0xFFF73B45);

  @override
  Color get cursorColor => _cursorColor ?? _foreground ?? const Color(0xFFC7CED1);

  @override
  Color get stringColor => _stringColor ?? const Color(0xFFC0EE5D);

  @override
  Color get numberColor => _numberColor ?? _foreground ?? const Color(0xFFC7CED1);

  @override
  Color get booleanColor => _booleanColor ?? const Color(0xFFAC3980);

  @override
  Color get nullColor => _nullColor ?? _booleanColor ?? const Color(0xFFAC3980);

  @override
  Color get punctuationColor => _punctuationColor ?? _primaryColor ?? const Color(0xFF5F93D3);

  @override
  Color get keyColor => _keyColor ?? _stringColor ?? const Color(0xFFC0EE5D);
}
