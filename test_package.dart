import 'package:flutter/material.dart';
import 'package:spectre_json/spectre_json.dart';

/// Simple test app to verify the Spectre package functionality
void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spectre Package Test',
      theme: ThemeData.dark(),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Map<String, dynamic> _testData = {
    'name': 'Test User',
    'age': 25,
    'isActive': true,
    'address': {
      'street': '123 Test St',
      'city': 'Test City',
      'zipCode': '12345'
    },
    'hobbies': ['testing', 'coding', 'debugging'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3638),
      appBar: AppBar(
        title: const Text('Spectre Package Test'),
        backgroundColor: const Color(0xFF2F3537),
        foregroundColor: const Color(0xFFC7CED1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spectre JSON Editor Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC7CED1),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This test verifies that the Spectre package is working correctly.',
              style: TextStyle(
                fontSize: 16,
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
                  print('Data changed: $newData');
                },
                title: 'Test JSON Editor',
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
