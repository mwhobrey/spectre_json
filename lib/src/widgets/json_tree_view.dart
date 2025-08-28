import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../theme/red_panda_theme.dart';

class JsonTreeView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;
  final bool allowCopy;
  final JsonEditorTheme theme;

  const JsonTreeView({
    super.key,
    required this.data,
    required this.onDataChanged,
    this.readOnly = false,
    this.allowCopy = false,
    required this.theme,
  });

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<JsonTreeView> {
  final Set<String> _expandedNodes = <String>{};
  String? _editingPath;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Always expand root node
    _expandedNodes.add('');
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildNode(widget.data, '');
  }

  Widget _buildNode(dynamic value, String path) {
    if (value is Map) {
      final isExpanded = _expandedNodes.contains(path);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNodeHeader(path, value, isExpanded, 'object'),
          if (isExpanded)
            ...value.entries.map((entry) {
              final newPath = path.isEmpty ? entry.key : '$path.${entry.key}';
              return Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildNode(entry.value, newPath),
              );
            }),
        ],
      );
    } else if (value is List) {
      final isExpanded = _expandedNodes.contains(path);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNodeHeader(path, value, isExpanded, 'array'),
          if (isExpanded)
            ...value.asMap().entries.map((entry) {
              final newPath = '$path[${entry.key}]';
              return Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildNode(entry.value, newPath),
              );
            }),
        ],
      );
    } else {
      return _buildLeafNode(path, value);
    }
  }

  Widget _buildNodeHeader(
    String path,
    dynamic value,
    bool isExpanded,
    String type,
  ) {
    final displayName = path.isEmpty ? 'root' : path.split('.').last;
    final itemCount = value is List ? value.length : (value as Map).length;
    final typeIcon = type == 'array' ? Icons.list : Icons.folder;
    final typeColor = type == 'array'
        ? widget.theme.primaryColor
        : widget.theme.primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Expand/Collapse Icon
          GestureDetector(
            onTap: () {
              setState(() {
                if (_expandedNodes.contains(path)) {
                  _expandedNodes.remove(path);
                } else {
                  _expandedNodes.add(path);
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.theme.surfaceBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: widget.theme.foreground,
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Type Icon
          Icon(typeIcon, color: typeColor, size: 16),

          const SizedBox(width: 8),

          // Node Name
          Text(
            displayName,
            style: TextStyle(
              color: widget.theme.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),

          const SizedBox(width: 8),

          // Item Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: widget.theme.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$itemCount items',
              style: TextStyle(
                color: widget.theme.foreground.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ),

          const Spacer(),

          // Action Buttons
          if (!widget.readOnly) ...[
            _buildCopyButton(value, displayName),
          ] else if (widget.allowCopy) ...[
            _buildCopyButton(value, displayName),
          ],
        ],
      ),
    );
  }

  Widget _buildLeafNode(String path, dynamic value) {
    final displayName = path.split('.').last;
    final valueColor = _getValueColor(value);
    final displayValue = _getDisplayValue(value);
    final isEditing = _editingPath == path;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: widget.theme.surfaceBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Indent to align with parent nodes
          const SizedBox(width: 32),

          // Key Name
          Expanded(
            flex: 2,
            child: Text(
              displayName,
              style: TextStyle(color: widget.theme.primaryColor, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // Value (editable or display)
          Expanded(
            flex: 3,
            child: isEditing
                ? _buildEditField(path, value)
                : GestureDetector(
                    onTap: widget.readOnly ? null : () => _startEditing(path, value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      decoration: BoxDecoration(
                        color: widget.readOnly 
                            ? Colors.transparent 
                            : widget.theme.editorBackground,
                        borderRadius: BorderRadius.circular(2),
                        border: widget.readOnly 
                            ? null 
                            : Border.all(color: widget.theme.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        displayValue,
                        style: TextStyle(color: valueColor, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          // Action Buttons
          if (!widget.readOnly) ...[
            _buildEditButton(path, value, displayName),
            _buildCopyButton(value, displayName),
          ] else if (widget.allowCopy) ...[
            _buildCopyButton(value, displayName),
          ],
        ],
      ),
    );
  }

  Widget _buildEditField(String path, dynamic value) {
    return TextField(
      controller: _editController,
      focusNode: _editFocusNode,
      style: TextStyle(
        color: _getValueColor(value),
        fontSize: 13,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: widget.theme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: widget.theme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: widget.theme.editorBackground,
      ),
      onSubmitted: (newValue) => _finishEditing(path, newValue),
      onEditingComplete: () => _finishEditing(path, _editController.text),
    );
  }

  Widget _buildEditButton(String path, dynamic value, String displayName) {
    final isEditing = _editingPath == path;
    
    return GestureDetector(
      onTap: isEditing ? () => _finishEditing(path, _editController.text) : () => _startEditing(path, value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.theme.surfaceBackground,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          isEditing ? Icons.check : Icons.edit,
          color: widget.theme.primaryColor,
          size: 14,
        ),
      ),
    );
  }

  void _startEditing(String path, dynamic value) {
    setState(() {
      _editingPath = path;
      _editController.text = _getEditableValue(value);
    });
    
    // Focus the text field after the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection.fromPosition(
        TextPosition(offset: _editController.text.length),
      );
    });
  }

  void _finishEditing(String path, String newValue) {
    if (_editingPath != path) return;

    final oldValue = _getValueAtPath(widget.data, path);
    final parsedValue = _parseValue(newValue, oldValue);
    
    if (parsedValue != null) {
      _updateValueAtPath(widget.data, path, parsedValue);
      widget.onDataChanged(Map<String, dynamic>.from(widget.data));
    }

    setState(() {
      _editingPath = null;
    });
  }

  String _getEditableValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  dynamic _parseValue(String text, dynamic originalValue) {
    final trimmed = text.trim();
    
    // Handle null
    if (trimmed.toLowerCase() == 'null') return null;
    
    // Handle booleans
    if (trimmed.toLowerCase() == 'true') return true;
    if (trimmed.toLowerCase() == 'false') return false;
    
    // Handle numbers
    if (originalValue is int) {
      final intValue = int.tryParse(trimmed);
      if (intValue != null) return intValue;
    }
    if (originalValue is double || originalValue is int) {
      final doubleValue = double.tryParse(trimmed);
      if (doubleValue != null) return doubleValue;
    }
    
    // Handle strings (remove quotes if present)
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    
    // Default to string
    return trimmed;
  }

  dynamic _getValueAtPath(Map<String, dynamic> data, String path) {
    final parts = _parsePath(path);
    dynamic current = data;
    
    for (final part in parts) {
      if (part is String) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          return null;
        }
      } else if (part is int) {
        if (current is List && part >= 0 && part < current.length) {
          current = current[part];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    
    return current;
  }

  void _updateValueAtPath(Map<String, dynamic> data, String path, dynamic newValue) {
    final parts = _parsePath(path);
    dynamic current = data;
    
    // Navigate to the parent of the target
    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (part is String) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          return; // Path not found
        }
      } else if (part is int) {
        if (current is List && part >= 0 && part < current.length) {
          current = current[part];
        } else {
          return; // Path not found
        }
      } else {
        return; // Invalid path
      }
    }
    
    // Update the value
    final lastPart = parts.last;
    if (lastPart is String && current is Map && current.containsKey(lastPart)) {
      current[lastPart] = newValue;
    } else if (lastPart is int && current is List && lastPart >= 0 && lastPart < current.length) {
      current[lastPart] = newValue;
    }
  }

  List<dynamic> _parsePath(String path) {
    final List<dynamic> parts = [];
    final segments = path.split('.');
    
    for (final segment in segments) {
      // Check if segment contains array index
      final bracketIndex = segment.indexOf('[');
      if (bracketIndex != -1) {
        // Extract the key part
        final key = segment.substring(0, bracketIndex);
        if (key.isNotEmpty) {
          parts.add(key);
        }
        
        // Extract the index part
        final indexStr = segment.substring(bracketIndex + 1, segment.lastIndexOf(']'));
        final index = int.tryParse(indexStr);
        if (index != null) {
          parts.add(index);
        }
      } else {
        parts.add(segment);
      }
    }
    
    return parts;
  }

  Widget _buildCopyButton(dynamic value, String displayName) {
    return PopupMenuButton<String>(
      tooltip: 'Copy options',
      onSelected: (String option) {
        String textToCopy;
        String feedbackMessage;

        switch (option) {
          case 'node':
            try {
              final keyValuePair = {displayName: value};
              textToCopy = jsonEncode(keyValuePair);
            } catch (e) {
              textToCopy = '{"$displayName": "${value.toString()}"}';
            }
            feedbackMessage = 'Copied: $displayName (as JSON)';
            break;
          case 'key':
            textToCopy = displayName;
            feedbackMessage = 'Copied: key "$displayName"';
            break;
          case 'value':
            if (value is String) {
              textToCopy = value;
            } else if (value is num || value is bool || value == null) {
              textToCopy = value.toString();
            } else {
              try {
                textToCopy = jsonEncode(value);
              } catch (e) {
                textToCopy = value.toString();
              }
            }
            feedbackMessage = 'Copied: value of "$displayName"';
            break;
          default:
            return;
        }

        Clipboard.setData(ClipboardData(text: textToCopy));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedbackMessage),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'node',
          child: Row(
            children: [
              Icon(Icons.copy, size: 16, color: widget.theme.primaryColor),
              const SizedBox(width: 8),
              const Text('Copy as JSON', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'key',
          child: Row(
            children: [
              Icon(Icons.label, size: 16, color: widget.theme.keyColor),
              const SizedBox(width: 8),
              const Text('Copy key only', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'value',
          child: Row(
            children: [
              Icon(
                Icons.data_object,
                size: 16,
                color: widget.theme.stringColor,
              ),
              const SizedBox(width: 8),
              const Text('Copy value only', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.theme.surfaceBackground,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.copy, color: widget.theme.primaryColor, size: 14),
      ),
    );
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is List) return '[${value.length} items]';
    if (value is Map) return '{${value.length} items}';
    return value.toString();
  }

  Color _getValueColor(dynamic value) {
    if (value == null) return widget.theme.nullColor;
    if (value is String) return widget.theme.stringColor;
    if (value is num) return widget.theme.numberColor;
    if (value is bool) return widget.theme.booleanColor;
    return widget.theme.foreground;
  }
}
