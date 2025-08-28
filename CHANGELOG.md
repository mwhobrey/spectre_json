# Changelog

All notable changes to the Spectre JSON Editor package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of Spectre JSON Editor
- Dual view mode (text editor and tree view)
- Syntax highlighting with customizable themes
- Real-time JSON validation with error highlighting
- Copy functionality for JSON data
- RedPandaTheme - a beautiful dark theme with red accents
- Responsive design that works across different screen sizes
- Tab-based interface for switching between views
- Line numbers in text editor mode
- Scroll synchronization between line numbers and text
- Debounced text input for better performance
- Expansion/collapse functionality
- Read-only mode support

### Features
- **JsonEditor**: Main widget for editing JSON data
- **JsonEditorTheme**: Base class for custom themes
- **RedPandaTheme**: Pre-built dark theme
- **Syntax Highlighting**: Color-coded JSON syntax
- **Tree View**: Interactive tree view for JSON navigation
- **Error Handling**: Visual feedback for invalid JSON
- **Copy Support**: Built-in copy to clipboard functionality

### Technical Details
- Built with Flutter 3.10.0+
- Dart SDK 3.0.0+
- No external dependencies beyond Flutter core
- MIT License
