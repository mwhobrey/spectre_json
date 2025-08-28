import 'package:flutter/material.dart';
import 'package:spectre/spectre.dart';

/// Example application demonstrating the Spectre JSON Editor package.
/// 
/// This app showcases various use cases and features of the JSON editor
/// including different data types, themes, and configurations.
void main() {
  runApp(const SpectreExampleApp());
}

/// Main application widget for the Spectre JSON Editor examples.
class SpectreExampleApp extends StatelessWidget {
  const SpectreExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spectre JSON Editor Examples',
      theme: ThemeData.dark(),
      home: const ExamplesPage(),
    );
  }
}

/// Page containing multiple examples of the JSON editor.
class ExamplesPage extends StatefulWidget {
  const ExamplesPage({super.key});

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  int _currentIndex = 0;
  int _currentThemeIndex = 0;
  
  /// Store original example data to restore when switching examples
  late final List<Map<String, dynamic>> _originalExamples;

  /// List of available themes for demonstration
  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Red Panda (Default)',
      'theme': RedPandaTheme(),
    },
    {
      'name': 'Light Theme',
      'theme': JsonEditorTheme.light(primaryColor: Colors.blue),
    },
    {
      'name': 'Dark Theme',
      'theme': JsonEditorTheme.dark(primaryColor: Colors.blue),
    },
    {
      'name': 'Green Theme',
      'theme': JsonEditorTheme.fromColors(
        editorBackground: Colors.grey[900]!,
        foreground: Colors.white,
        primaryColor: Colors.green,
        stringColor: Colors.lightGreen,
        keyColor: Colors.lightGreen,
      ),
    },
    {
      'name': 'Purple Theme',
      'theme': JsonEditorTheme.fromColors(
        editorBackground: Colors.grey[900]!,
        foreground: Colors.white,
        primaryColor: Colors.purple,
        stringColor: Colors.purple[300]!,
        keyColor: Colors.purple[300]!,
      ),
    },
  ];

  /// List of example configurations demonstrating different use cases.
  final List<Map<String, dynamic>> _examples = [
    {
      'title': 'Basic JSON Editor',
      'description': 'Simple usage with basic data types',
      'data': {
        'name': 'John Doe',
        'age': 30,
        'isActive': true,
        'address': {
          'street': '123 Main St',
          'city': 'Anytown',
          'zipCode': '12345'
        },
        'hobbies': ['reading', 'coding', 'gaming'],
      },
      'allowCopy': true,
      'readOnly': false,
    },
    {
      'title': 'Configuration Editor',
      'description': 'Complex nested configuration data',
      'data': {
        'app': {
          'name': 'MyApp',
          'version': '1.0.0',
          'debug': false,
        },
        'database': {
          'host': 'localhost',
          'port': 5432,
          'name': 'myapp_db',
          'ssl': true,
        },
        'features': {
          'darkMode': true,
          'notifications': false,
          'analytics': true,
        },
      },
      'allowCopy': true,
      'readOnly': false,
    },
    {
      'title': 'Read-Only Viewer',
      'description': 'Display-only mode for viewing JSON data',
      'data': {
        'user': {
          'id': 12345,
          'username': 'johndoe',
          'email': 'john@example.com',
          'profile': {
            'firstName': 'John',
            'lastName': 'Doe',
            'avatar': 'https://example.com/avatar.jpg',
          },
          'permissions': ['read', 'write', 'admin'],
          'lastLogin': '2024-01-15T10:30:00Z',
        },
      },
      'allowCopy': true,
      'readOnly': true,
    },
    {
      'title': 'Complex Nested Data',
      'description': 'Deep nested structures with arrays and objects',
      'data': {
        'metadata': {
          'created': '2024-01-01T00:00:00Z',
          'updated': '2024-01-15T12:30:00Z',
          'version': '1.2.3',
        },
        'data': {
          'users': [
            {
              'id': 1,
              'name': 'Alice',
              'role': 'admin',
              'settings': {
                'theme': 'dark',
                'language': 'en',
                'notifications': true,
              },
            },
            {
              'id': 2,
              'name': 'Bob',
              'role': 'user',
              'settings': {
                'theme': 'light',
                'language': 'es',
                'notifications': false,
              },
            },
          ],
          'products': [
            {
              'id': 'prod-001',
              'name': 'Widget A',
              'price': 29.99,
              'inStock': true,
              'tags': ['electronics', 'gadgets'],
            },
            {
              'id': 'prod-002',
              'name': 'Widget B',
              'price': 49.99,
              'inStock': false,
              'tags': ['electronics', 'premium'],
            },
          ],
        },
      },
      'allowCopy': true,
      'readOnly': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Create a deep copy of the original examples to preserve them
    _originalExamples = _examples.map((example) {
      return {
        ...example,
        'data': Map<String, dynamic>.from(example['data']),
      };
    }).toList();
  }

  /// Restore the original data for the current example
  void _restoreOriginalData() {
    setState(() {
      _examples[_currentIndex]['data'] = Map<String, dynamic>.from(_originalExamples[_currentIndex]['data']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentExample = _examples[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF2E3638),
      appBar: AppBar(
        title: const Text('Spectre JSON Editor Examples'),
        backgroundColor: const Color(0xFF2F3537),
        foregroundColor: const Color(0xFFC7CED1),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About Spectre',
          ),
        ],
      ),
      body: Column(
        children: [
          // Example and theme selectors
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Example: ',
                            style: TextStyle(
                              color: Color(0xFFC7CED1),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: _currentIndex,
                            dropdownColor: const Color(0xFF2F3537),
                            style: const TextStyle(color: Color(0xFFC7CED1)),
                            items: _examples.asMap().entries.map((entry) {
                              return DropdownMenuItem<int>(
                                value: entry.key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.value['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      entry.value['description'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFFC7CED1).withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (index) {
                              if (index != null) {
                                setState(() {
                                  _currentIndex = index;
                                });
                                // Restore the original data for the new example
                                _restoreOriginalData();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Theme: ',
                            style: TextStyle(
                              color: Color(0xFFC7CED1),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: _currentThemeIndex,
                            dropdownColor: const Color(0xFF2F3537),
                            style: const TextStyle(color: Color(0xFFC7CED1)),
                            items: _themes.asMap().entries.map((entry) {
                              return DropdownMenuItem<int>(
                                value: entry.key,
                                child: Text(
                                  entry.value['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (index) {
                              if (index != null) {
                                setState(() {
                                  _currentThemeIndex = index;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // JSON Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: JsonEditor(
                initialData: currentExample['data'],
                onDataChanged: (newData) {
                  setState(() {
                    _examples[_currentIndex]['data'] = newData;
                  });
                },
                title: currentExample['title'],
                allowCopy: currentExample['allowCopy'],
                readOnly: currentExample['readOnly'],
                theme: _themes[_currentThemeIndex]['theme'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows an information dialog about the Spectre package.
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2F3537),
        title: const Text(
          'Spectre JSON Editor',
          style: TextStyle(color: Color(0xFFC7CED1)),
        ),
        content: const Text(
          'A beautiful and feature-rich JSON editor widget for Flutter with syntax highlighting, tree view, and customizable themes.\n\n'
          'Features:\n'
          '• Dual view mode (text editor and tree view)\n'
          '• Syntax highlighting\n'
          '• Real-time validation\n'
          '• Copy functionality\n'
          '• Customizable themes\n'
          '• Responsive design\n\n'
          'This example demonstrates various use cases and configurations.',
          style: TextStyle(color: Color(0xFFC7CED1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
