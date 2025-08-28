import 'package:flutter/material.dart';
import 'package:spectre/spectre.dart';

/// Test app to verify the indentation fix
void main() {
  runApp(const IndentationTestApp());
}

class IndentationTestApp extends StatelessWidget {
  const IndentationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indentation Test',
      theme: ThemeData.dark(),
      home: const IndentationTestPage(),
    );
  }
}

class IndentationTestPage extends StatefulWidget {
  const IndentationTestPage({super.key});

  @override
  State<IndentationTestPage> createState() => _IndentationTestPageState();
}

class _IndentationTestPageState extends State<IndentationTestPage> {
  Map<String, dynamic> _testData = {
    'name': 'Test User',
    'address': {
      'street': '123 Main St',
      'city': 'Test City',
    },
    'hobbies': ['reading', 'coding'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3638),
      appBar: AppBar(
        title: const Text('Indentation Test'),
        backgroundColor: const Color(0xFF2F3537),
        foregroundColor: const Color(0xFFC7CED1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indentation Test - Press Enter after "street" to test fix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC7CED1),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Instructions:\n'
              '1. Click on the "Raw" tab\n'
              '2. Place cursor after "street": "123 Main St",\n'
              '3. Press Enter\n'
              '4. Should indent with 4 spaces (not 6)',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFC7CED1),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: JsonEditor(
                initialData: _testData,
                onDataChanged: (newData) {
                  setState(() {
                    _testData = newData;
                  });
                },
                title: 'Indentation Test',
                allowCopy: true,
                theme: RedPandaTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
