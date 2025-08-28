# Changelog

All notable changes to the Spectre JSON Editor package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### 🎉 Initial Release

Spectre is a beautiful and feature-rich JSON editor widget for Flutter with syntax highlighting, tree view navigation, real-time validation, and customizable themes.

### ✨ Added

#### Core Features
- **Flexible View Modes**: Choose between dual view (tabs), tree-only, or raw-only modes
- **Syntax Highlighting**: Beautiful JSON syntax highlighting with customizable themes
- **Interactive Tree View**: Navigate and edit JSON with an intuitive tree interface
- **Real-time Validation**: Live JSON validation with error highlighting
- **Copy & Paste**: Built-in clipboard functionality
- **Customizable Themes**: Multiple built-in themes and custom theme support
- **Responsive Design**: Works seamlessly across different screen sizes
- **Performance Optimized**: Efficient rendering and memory management

#### Advanced Features
- **Smart Indentation**: Context-aware indentation and auto-closing
- **Advanced Controls**: Format, clear, and validate JSON with action buttons
- **Tree View Editing**: Inline editing of values and keys
- **Node Addition**: Add new properties and array items with intelligent type inference
- **Auto-closing**: Smart auto-closing for brackets, braces, and quotes
- **Line Numbers**: Line numbers display in text editor mode
- **Scroll Synchronization**: Synchronized scrolling between line numbers and text
- **Debounced Input**: Optimized text input with debouncing for better performance

#### Theme System
- **RedPandaTheme**: Beautiful dark theme with red accents (default)
- **JsonEditorTheme.light()**: Clean light theme
- **JsonEditorTheme.dark()**: Modern dark theme
- **JsonEditorTheme.material(context)**: Theme that adapts to your app's Material theme
- **JsonEditorTheme.fromColors()**: Factory constructor for custom themes

#### Widget Properties
- **initialData**: The initial JSON data to display
- **onDataChanged**: Callback function when data changes
- **title**: Custom title for the editor header
- **readOnly**: Read-only mode support
- **allowCopy**: Enable/disable copy functionality
- **theme**: Custom theme support
- **isExpanded**: Initial expansion state
- **onExpansionChanged**: Expansion state change callback
- **onCollapse**: Collapse event callback
- **viewType**: View mode selection (dual, treeOnly, rawOnly)

#### Action Buttons
- **Format**: Beautify JSON with proper indentation
- **Clear**: Reset to empty JSON object
- **Validate**: Check JSON validity with visual feedback
- **Copy**: Copy JSON to clipboard
- **Paste**: Paste JSON from clipboard

### 🔧 Technical Features

#### Performance
- Debounced text input (750ms delay)
- Efficient widget rebuilding
- Optimized tree view rendering
- Memory-efficient data handling

#### Error Handling
- Real-time JSON validation
- Visual error highlighting
- Comprehensive error messages
- Graceful handling of invalid input

#### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

### 🧪 Testing

- **85+ comprehensive tests** covering all major functionality
- Widget testing for all components
- Theme system testing
- Error handling and edge cases
- Tree view functionality testing
- Syntax highlighting verification
- Performance and memory testing

### 📚 Documentation

- Comprehensive README with examples
- API reference with property tables
- Theme customization guide
- Usage examples for common scenarios
- Platform support documentation
- Contributing guidelines

### 🛠️ Development

- Built with Flutter 3.10.0+
- Dart SDK 3.0.0+
- No external dependencies beyond Flutter core
- MIT License
- Comprehensive linting with flutter_lints
- GitHub Actions CI/CD ready

### 🎯 Use Cases

Perfect for:
- Configuration editors
- Data visualization tools
- JSON manipulation in Flutter apps
- API response viewers
- Settings panels
- Development tools
- Data entry forms

### 🔮 Future Plans

- Additional theme presets
- Export to different formats
- Search and replace functionality
- Keyboard shortcuts
- Plugin system for extensions
- More advanced validation rules
