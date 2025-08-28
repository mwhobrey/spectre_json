# Spectre - JSON Editor for Flutter

A beautiful and feature-rich JSON editor widget for Flutter with syntax highlighting, tree view, and customizable themes.

## Features

- 📝 **Dual View Mode**: Switch between text editor and tree view
- 🎨 **Syntax Highlighting**: Beautiful JSON syntax highlighting with customizable themes
- 🌳 **Tree View**: Interactive tree view for easy JSON navigation
- 🎯 **Real-time Validation**: Live JSON validation with error highlighting
- 📋 **Copy Support**: Built-in copy functionality for JSON data
- 🎨 **Customizable Themes**: Multiple theme options including dark mode
- 📱 **Responsive Design**: Works seamlessly across different screen sizes
- ⚡ **Performance Optimized**: Efficient rendering and memory management

## Installation

Add `spectre` to your `pubspec.yaml`:

```yaml
dependencies:
  spectre: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:spectre/spectre.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> jsonData = {
    'name': 'John Doe',
    'age': 30,
    'isActive': true,
    'address': {
      'street': '123 Main St',
      'city': 'Anytown',
      'zipCode': '12345'
    },
    'hobbies': ['reading', 'coding', 'gaming'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('JSON Editor Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: JsonEditor(
          initialData: jsonData,
          onDataChanged: (newData) {
            setState(() {
              jsonData = newData;
            });
          },
          title: 'My JSON Data',
          allowCopy: true,
        ),
      ),
    );
  }
}
```

## Usage

### Basic Usage

```dart
JsonEditor(
  initialData: yourJsonData,
  onDataChanged: (newData) {
    // Handle data changes
  },
)
```

### Advanced Usage

```dart
JsonEditor(
  initialData: jsonData,
  onDataChanged: (newData) {
    setState(() {
      jsonData = newData;
    });
  },
  title: 'Configuration Editor',
  readOnly: false,
  allowCopy: true,
  theme: RedPandaTheme(), // Custom theme
  isExpanded: true,
  onExpansionChanged: (expanded) {
    print('Editor ${expanded ? 'expanded' : 'collapsed'}');
  },
)
```

## API Reference

### JsonEditor

The main widget for editing JSON data.

#### Properties

- `initialData` (required): The initial JSON data to display
- `onDataChanged` (required): Callback function when data changes
- `title`: The title displayed in the editor header (default: 'JSON Editor')
- `readOnly`: Whether the editor is read-only (default: false)
- `allowCopy`: Whether to show copy functionality (default: false)
- `theme`: Custom theme for the editor
- `isExpanded`: Initial expansion state
- `onExpansionChanged`: Callback when expansion state changes

### JsonEditorTheme

Base class for custom themes.

```dart
class CustomTheme extends JsonEditorTheme {
  @override
  Color get backgroundColor => Colors.grey[900]!;
  
  @override
  Color get textColor => Colors.white;
  
  @override
  Color get keywordColor => Colors.blue;
  
  @override
  Color get stringColor => Colors.green;
  
  @override
  Color get numberColor => Colors.orange;
  
  @override
  Color get booleanColor => Colors.purple;
  
  @override
  Color get nullColor => Colors.red;
}
```

## Available Themes

- `RedPandaTheme`: A beautiful dark theme with red accents

## Examples

Check out the `example` directory for complete working examples.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### 1.0.0
- Initial release
- Dual view mode (text editor and tree view)
- Syntax highlighting
- Customizable themes
- Real-time validation
- Copy functionality
