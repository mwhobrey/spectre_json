# Spectre JSON - JSON Editor for Flutter

A beautiful and feature-rich JSON editor widget for Flutter with syntax highlighting, tree view navigation, real-time validation, and customizable themes.

[![pub package](https://img.shields.io/pub/v/spectre.svg)](https://pub.dev/packages/spectre)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)

## ✨ Features

- 📝 **Flexible View Modes**: Choose between dual view (tabs), tree-only, or raw-only modes
- 🎨 **Syntax Highlighting**: Beautiful JSON syntax highlighting with customizable themes
- 🌳 **Interactive Tree View**: Navigate and edit JSON with an intuitive tree interface
- 🎯 **Real-time Validation**: Live JSON validation with error highlighting
- 📋 **Copy & Paste**: Built-in clipboard functionality
- 🎨 **Customizable Themes**: Multiple built-in themes and custom theme support
- 📱 **Responsive Design**: Works seamlessly across different screen sizes
- ⚡ **Performance Optimized**: Efficient rendering and memory management
- 🔧 **Smart Indentation**: Context-aware indentation and auto-closing
- 🎛️ **Advanced Controls**: Format, clear, and validate JSON with action buttons

## 🚀 Installation

Add `spectre_json` to your `pubspec.yaml`:

```yaml
dependencies:
  spectre_json: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📖 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:spectre_json/spectre_json.dart';

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
          theme: RedPandaTheme(),
        ),
      ),
    );
  }
}
```

## 🎯 Usage

### Basic Usage

```dart
JsonEditor(
  initialData: yourJsonData,
  onDataChanged: (newData) {
    // Handle data changes
    print('JSON updated: $newData');
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
  theme: JsonEditorTheme.light(primaryColor: Colors.blue),
  isExpanded: true,
  onExpansionChanged: (expanded) {
    print('Editor ${expanded ? 'expanded' : 'collapsed'}');
  },
  onCollapse: () {
    print('Editor collapsed');
  },
)
```

### Custom Theme

```dart
// Using the factory constructor (recommended)
JsonEditor(
  initialData: data,
  onDataChanged: (newData) {},
  theme: JsonEditorTheme.fromColors(
    editorBackground: Colors.grey[900]!,
    foreground: Colors.white,
    primaryColor: Colors.blue,
    stringColor: Colors.green,
    numberColor: Colors.orange,
  ),
)

// Or extend the base class
class MyCustomTheme extends JsonEditorTheme {
  @override
  Color get editorBackground => Colors.grey[900]!;
  
  @override
  Color get foreground => Colors.white;
  
  @override
  Color get primaryColor => Colors.blue;
  
  // ... implement all other color getters
}
```

### View Types

Choose how the JSON editor is displayed:

```dart
// Dual view (default) - shows both tree and raw editor with tabs
JsonEditor(
  initialData: data,
  onDataChanged: (newData) {},
  viewType: ViewType.dual,
)

// Tree view only - shows only the interactive tree interface
JsonEditor(
  initialData: data,
  onDataChanged: (newData) {},
  viewType: ViewType.treeOnly,
)

// Raw editor only - shows only the text editor
JsonEditor(
  initialData: data,
  onDataChanged: (newData) {},
  viewType: ViewType.rawOnly,
)
```

## 🎨 Available Themes

### Built-in Themes

- **RedPandaTheme**: Beautiful dark theme with red accents (default)
- **JsonEditorTheme.light()**: Clean light theme
- **JsonEditorTheme.dark()**: Modern dark theme
- **JsonEditorTheme.material(context)**: Theme that adapts to your app's Material theme

### Custom Themes

Create custom themes using the `JsonEditorTheme.fromColors()` factory constructor:

```dart
JsonEditorTheme.fromColors(
  editorBackground: Colors.grey[900]!,
  foreground: Colors.white,
  primaryColor: Colors.blue,
  stringColor: Colors.green,
  numberColor: Colors.orange,
  booleanColor: Colors.purple,
  nullColor: Colors.red,
  punctuationColor: Colors.grey,
  keyColor: Colors.cyan,
)
```

## 📚 API Reference

### JsonEditor

The main widget for editing JSON data.

#### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `initialData` | `Map<String, dynamic>` | ✅ | - | The initial JSON data to display |
| `onDataChanged` | `Function(Map<String, dynamic>)` | ✅ | - | Callback function when data changes |
| `title` | `String` | ❌ | `'JSON Editor'` | The title displayed in the editor header |
| `readOnly` | `bool` | ❌ | `false` | Whether the editor is read-only |
| `allowCopy` | `bool` | ❌ | `false` | Whether to show copy functionality |
| `theme` | `JsonEditorTheme?` | ❌ | `RedPandaTheme()` | Custom theme for the editor |
| `isExpanded` | `bool?` | ❌ | `true` | Initial expansion state |
| `onExpansionChanged` | `Function(bool)?` | ❌ | - | Callback when expansion state changes |
| `onCollapse` | `VoidCallback?` | ❌ | - | Callback when editor is collapsed |
| `viewType` | `ViewType` | ❌ | `ViewType.dual` | The view type to display (dual, treeOnly, rawOnly) |

### JsonEditorTheme

Base class for custom themes with the following color properties:

- `editorBackground`: Background color of the editor
- `foreground`: Default text color
- `headerBackground`: Header background color
- `surfaceBackground`: Surface background color
- `lineNumbersBackground`: Line numbers background color
- `borderColor`: Border color
- `primaryColor`: Primary accent color
- `onPrimary`: Text color on primary background
- `errorColor`: Error text and border color
- `cursorColor`: Text cursor color
- `stringColor`: JSON string value color
- `numberColor`: JSON number value color
- `booleanColor`: JSON boolean value color
- `nullColor`: JSON null value color
- `punctuationColor`: JSON punctuation color
- `keyColor`: JSON key color

## 🌟 Features in Detail

### Flexible View Modes
- **Dual View**: Switch between text editor and tree view with tabs
- **Tree Only**: Dedicated tree view interface for focused navigation
- **Raw Only**: Full-featured text editor with syntax highlighting

### Syntax Highlighting
- Color-coded JSON syntax for better readability
- Support for strings, numbers, booleans, null values, and punctuation
- Customizable colors through themes

### Tree View Features
- Expandable/collapsible nodes
- Inline editing of values and keys
- Add new properties and array items
- Intelligent type inference for arrays
- Copy individual values

### Smart Editing
- Context-aware indentation
- Auto-closing brackets, braces, and quotes
- Real-time JSON validation
- Error highlighting and messages

### Action Buttons
- **Format**: Beautify JSON with proper indentation
- **Clear**: Reset to empty JSON object
- **Validate**: Check JSON validity
- **Copy**: Copy JSON to clipboard
- **Paste**: Paste JSON from clipboard

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Development

### Running Tests

```bash
flutter test
```

### Running the Example

```bash
cd example
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📋 Changelog

### 1.0.0
- 🎉 Initial release
- ✨ Dual view mode (text editor and tree view)
- 🎨 Syntax highlighting with customizable themes
- 🌳 Interactive tree view with inline editing
- 🔧 Real-time JSON validation
- 📋 Copy and paste functionality
- 🎛️ Action buttons (format, clear, validate)
- 🎨 Multiple built-in themes (RedPanda, Light, Dark, Material)
- 🔧 Smart indentation and auto-closing
- 📱 Responsive design for all platforms
- ⚡ Performance optimizations
- 🧪 Comprehensive test coverage (85+ tests)

## 🙏 Acknowledgments

- Inspired by modern code editors and JSON viewers
- Built with Flutter's powerful widget system
- Tested across multiple platforms and devices
