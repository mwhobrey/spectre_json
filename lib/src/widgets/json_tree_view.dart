import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../theme/red_panda_theme.dart';
import '../json_editor.dart';

class JsonTreeView extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;
  final bool allowCopy;
  final JsonEditorTheme theme;
  final ExpansionMode expansionMode;
  final int maxExpansionLevel;
  final bool debugMode;

  const JsonTreeView({
    super.key,
    required this.data,
    required this.onDataChanged,
    this.readOnly = false,
    this.allowCopy = false,
    required this.theme,
    this.expansionMode = ExpansionMode.none,
    this.maxExpansionLevel = 2,
    this.debugMode = false,
  });

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<JsonTreeView> {
  // Special value to indicate parsing error
  static const Object _PARSE_ERROR = Object();
  
  final Set<String> _expandedNodes = <String>{};
  String? _editingPath;
  String? _editingKey;
  String? _addingToPath;
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Always expand root node
    _expandedNodes.add('');
    
    // Apply expansion mode
    _applyExpansionMode();
  }

  @override
  void didUpdateWidget(JsonTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if data has changed
    if (oldWidget.data != widget.data) {
      if (widget.debugMode) {
        print('🔍 [SPECTRE DEBUG] Data changed, re-applying expansion mode');
        print('🔍 [SPECTRE DEBUG] Old data keys: ${oldWidget.data.keys.toList()}');
        print('🔍 [SPECTRE DEBUG] New data keys: ${widget.data.keys.toList()}');
      }
      
      // Clear existing expanded nodes and re-apply expansion mode
      _expandedNodes.clear();
      _expandedNodes.add(''); // Always expand root node
      _applyExpansionMode();
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _valueController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  /// Applies the expansion mode to determine which nodes should be expanded by default.
  void _applyExpansionMode() {
    if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] Applying expansion mode: ${widget.expansionMode}');
      print('🔍 [SPECTRE DEBUG] Max expansion level: ${widget.maxExpansionLevel}');
      print('🔍 [SPECTRE DEBUG] Initial data type: ${widget.data.runtimeType}');
      print('🔍 [SPECTRE DEBUG] Initial data keys: ${widget.data.keys.toList()}');
    }
    
    switch (widget.expansionMode) {
      case ExpansionMode.none:
        // Only root node is expanded (already added in initState)
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] ExpansionMode.none - only root expanded');
        }
        break;
        
      case ExpansionMode.objects:
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] ExpansionMode.objects - expanding objects');
        }
        _expandObjects(widget.data, '');
        break;
        
      case ExpansionMode.arrays:
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] ExpansionMode.arrays - expanding arrays');
        }
        _expandArrays(widget.data, '');
        break;
        
      case ExpansionMode.objectsAndArrays:
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] ExpansionMode.objectsAndArrays - expanding both');
        }
        _expandObjects(widget.data, '');
        _expandArrays(widget.data, '');
        break;
        
      case ExpansionMode.all:
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] ExpansionMode.all - expanding everything');
        }
        _expandAll(widget.data, '');
        break;
        
      case ExpansionMode.levels:
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] ExpansionMode.levels - expanding up to level ${widget.maxExpansionLevel}');
        }
        _expandLevels(widget.data, '', 0);
        break;
    }
    
    if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] Final expanded nodes: ${_expandedNodes.toList()}');
    }
  }

  /// Expands all object nodes recursively.
  void _expandObjects(dynamic value, String path) {
    if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] _expandObjects - path: "$path", value type: ${value.runtimeType}');
    }
    
    if (value is Map) {
      _expandedNodes.add(path);
      if (widget.debugMode) {
        print('🔍 [SPECTRE DEBUG] _expandObjects - added Map path: "$path"');
      }
      for (final entry in value.entries) {
        final newPath = path.isEmpty ? entry.key : '$path.${entry.key}';
        _expandObjects(entry.value, newPath);
      }
    } else if (value is List) {
      if (widget.debugMode) {
        print('🔍 [SPECTRE DEBUG] _expandObjects - traversing List at path: "$path"');
      }
      for (int i = 0; i < value.length; i++) {
        final newPath = '$path[$i]';
        _expandObjects(value[i], newPath);
      }
    }
  }

  /// Expands all array nodes recursively.
  void _expandArrays(dynamic value, String path) {
    if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] _expandArrays - path: "$path", value type: ${value.runtimeType}');
    }
    
    if (value is List) {
      _expandedNodes.add(path);
      if (widget.debugMode) {
        print('🔍 [SPECTRE DEBUG] _expandArrays - added List path: "$path"');
      }
      for (int i = 0; i < value.length; i++) {
        final newPath = '$path[$i]';
        _expandArrays(value[i], newPath);
      }
    } else if (value is Map) {
      // Expand the parent object so we can see arrays inside it
      _expandedNodes.add(path);
      if (widget.debugMode) {
        print('🔍 [SPECTRE DEBUG] _expandArrays - added Map path: "$path" (contains arrays)');
      }
      for (final entry in value.entries) {
        final newPath = path.isEmpty ? entry.key : '$path.${entry.key}';
        _expandArrays(entry.value, newPath);
      }
    }
  }

  /// Expands all nodes recursively.
  void _expandAll(dynamic value, String path) {
    if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] _expandAll - path: "$path", value type: ${value.runtimeType}');
    }
    
    if (value is Map || value is List) {
      _expandedNodes.add(path);
      if (widget.debugMode) {
        print('🔍 [SPECTRE DEBUG] _expandAll - added path: "$path"');
      }
    }
    
    if (value is Map) {
      for (final entry in value.entries) {
        final newPath = path.isEmpty ? entry.key : '$path.${entry.key}';
        _expandAll(entry.value, newPath);
      }
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        final newPath = '$path[$i]';
        _expandAll(value[i], newPath);
      }
    }
  }

  /// Expands nodes up to the specified level.
  void _expandLevels(dynamic value, String path, int currentLevel) {
    if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] _expandLevels - path: "$path", currentLevel: $currentLevel, maxLevel: ${widget.maxExpansionLevel}, value type: ${value.runtimeType}');
    }
    
    if (currentLevel < widget.maxExpansionLevel) {
      if (value is Map || value is List) {
        _expandedNodes.add(path);
        if (widget.debugMode) {
          print('🔍 [SPECTRE DEBUG] _expandLevels - added path: "$path" at level $currentLevel');
        }
      }
      
      if (value is Map) {
        for (final entry in value.entries) {
          final newPath = path.isEmpty ? entry.key : '$path.${entry.key}';
          _expandLevels(entry.value, newPath, currentLevel + 1);
        }
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          final newPath = '$path[$i]';
          _expandLevels(value[i], newPath, currentLevel + 1);
        }
      }
    } else if (widget.debugMode) {
      print('🔍 [SPECTRE DEBUG] _expandLevels - reached max level $currentLevel, stopping expansion');
    }
  }

  /// Gets the display name for a path, handling both object properties and array indices.
  String _getDisplayName(String path) {
    // Handle array indices: items[0] -> 0
    if (path.contains('[') && path.contains(']')) {
      final startIndex = path.lastIndexOf('[');
      final endIndex = path.lastIndexOf(']');
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        return path.substring(startIndex + 1, endIndex);
      }
    }
    
    // Handle object properties: settings.theme -> theme
    return path.split('.').last;
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
          if (isExpanded) ...[
            ...value.entries.map((entry) {
              final newPath = path.isEmpty ? entry.key : '$path.${entry.key}';
              return Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildNode(entry.value, newPath),
              );
            }),
            // Add new item button for objects
            if (!widget.readOnly) _buildAddItemButton(path, value, 'object'),
          ],
        ],
      );
    } else if (value is List) {
      final isExpanded = _expandedNodes.contains(path);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNodeHeader(path, value, isExpanded, 'array'),
          if (isExpanded) ...[
            ...value.asMap().entries.map((entry) {
              final newPath = '$path[${entry.key}]';
              return Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildNode(entry.value, newPath),
              );
            }),
            // Add new item button for arrays
            if (!widget.readOnly) _buildAddItemButton(path, value, 'array'),
          ],
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
    final displayName = path.isEmpty ? 'root' : _getDisplayName(path);
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

          // Node Name (editable for non-root nodes)
          if (path.isEmpty)
            Text(
              displayName,
              style: TextStyle(
                color: widget.theme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            )
          else
            _buildEditableKey(path, displayName),

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

  Widget _buildAddItemButton(String path, dynamic parentValue, String type) {
    final isAdding = _addingToPath == path;
    
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: isAdding
            ? _buildAddItemField(path, parentValue, type)
            : GestureDetector(
                onTap: () => _startAddingItem(path, parentValue, type),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: widget.theme.surfaceBackground,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.theme.primaryColor.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: widget.theme.primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type == 'array' ? 'Add item' : 'Add property',
                        style: TextStyle(
                          color: widget.theme.primaryColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAddItemField(String path, dynamic parentValue, String type) {
    final isArray = type == 'array';
    final suggestedKey = _getSuggestedKey(parentValue);
    final suggestedValue = _getSuggestedValue(parentValue);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Key field (for objects only)
        if (!isArray) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _editController,
                  focusNode: _editFocusNode,
                  style: TextStyle(
                    color: widget.theme.primaryColor,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Property name',
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                  onSubmitted: (key) => _finishAddingItem(path, parentValue, type, key, _valueController.text),
                ),
              ),
              const SizedBox(width: 8),
              _buildAddItemActionButton(path, parentValue, type, _editController.text, _valueController.text),
            ],
          ),
          const SizedBox(height: 4),
        ],
        // Value field with type helpers
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: isArray ? _editController : _valueController,
                    style: TextStyle(
                      color: _getValueColor(suggestedValue),
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: isArray ? 'Value' : 'Value (optional)',
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                    onSubmitted: (value) => _finishAddingItem(path, parentValue, type, isArray ? suggestedKey : _editController.text, isArray ? value : _valueController.text),
                  ),
                ),
                const SizedBox(width: 8),
                if (isArray) _buildAddItemActionButton(path, parentValue, type, suggestedKey, _editController.text),
              ],
            ),
            // Type helper buttons (for objects only)
            if (!isArray) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypeHelperButton('[]', 'Empty array', () {
                    // For objects, we need to update the value field
                    // Since we're using a new controller each time, we'll need to handle this differently
                    _setValueFieldText('[]');
                  }),
                  const SizedBox(width: 4),
                  _buildTypeHelperButton('{}', 'Empty object', () {
                    _setValueFieldText('{}');
                  }),
                  const SizedBox(width: 4),
                  _buildTypeHelperButton('null', 'Null value', () {
                    _setValueFieldText('null');
                  }),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAddItemActionButton(String path, dynamic parentValue, String type, String key, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cancel button
        GestureDetector(
          onTap: () => _cancelAddingItem(),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.theme.errorColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Confirm button
        GestureDetector(
          onTap: () => _finishAddingItem(path, parentValue, type, key, value),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.theme.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeHelperButton(String text, String tooltip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.theme.surfaceBackground,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: widget.theme.primaryColor.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: widget.theme.primaryColor,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  void _setValueFieldText(String text) {
    _valueController.text = text;
    setState(() {});
  }

  void _startAddingItem(String path, dynamic parentValue, String type) {
    // Clear any existing editing
    if (_editingPath != null || _editingKey != null) {
      setState(() {
        _editingPath = null;
        _editingKey = null;
      });
    }
    
    setState(() {
      _addingToPath = path;
      if (type == 'array') {
        _editController.text = '';
      } else {
        _editController.text = _getSuggestedKey(parentValue);
        _valueController.text = _getSuggestedValue(parentValue).toString();
      }
    });
    
    // Focus the text field after the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection.fromPosition(
        TextPosition(offset: _editController.text.length),
      );
    });
  }

  void _cancelAddingItem() {
    setState(() {
      _addingToPath = null;
    });
    
    // Clear the controllers
    _editController.clear();
    _valueController.clear();
  }

  void _finishAddingItem(String path, dynamic parentValue, String type, String key, String value) {
    if (_addingToPath != path) return;

    final trimmedKey = key.trim();
    final trimmedValue = value.trim();

    // Debug output removed for production

    // Validate input
    if (type == 'object' && trimmedKey.isEmpty) {
      _showError('Property name cannot be empty');
      return;
    }

    if (type == 'array' && trimmedValue.isEmpty) {
      _showError('Array item value cannot be empty');
      return;
    }

    // Check for duplicate keys in objects
    if (type == 'object' && parentValue is Map && parentValue.containsKey(trimmedKey)) {
      _showError('Property "$trimmedKey" already exists');
      return;
    }

    // Parse the value based on context
    dynamic parsedValue;
    if (type == 'array') {
      parsedValue = _parseArrayValue(trimmedValue, parentValue);
    } else {
      parsedValue = _parseObjectValue(trimmedValue);
    }

    // Check if parsing failed (parsedValue is a special error indicator)
    if (parsedValue == _PARSE_ERROR) {
      return; // Error already shown by the parsing method
    }

    // Adding item with key="$trimmedKey", parsedValue=$parsedValue

    // Add the item to the data structure
    _addItemToPath(widget.data, path, type, trimmedKey, parsedValue);
    widget.onDataChanged(Map<String, dynamic>.from(widget.data));

    setState(() {
      _addingToPath = null;
    });
    
    // Clear the controllers
    _editController.clear();
    _valueController.clear();
  }

  String _getSuggestedKey(dynamic parentValue) {
    if (parentValue is Map) {
      // Find the next available key
      int counter = 1;
      String key = 'property$counter';
      while (parentValue.containsKey(key)) {
        counter++;
        key = 'property$counter';
      }
      return key;
    }
    return 'property1';
  }

  dynamic _getSuggestedValue(dynamic parentValue) {
    if (parentValue is List && parentValue.isNotEmpty) {
      // Return a value of the same type as existing items
      final firstItem = parentValue.first;
      if (firstItem is String) return '';
      if (firstItem is num) return 0;
      if (firstItem is bool) return false;
      if (firstItem is List) return [];
      if (firstItem is Map) return {};
    }
    return '';
  }

  dynamic _parseArrayValue(String value, List parentArray) {
    if (parentArray.isEmpty) {
      // Empty array - try to infer type from the value
      if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
        return value.toLowerCase() == 'true';
      }
      if (int.tryParse(value) != null) {
        return int.parse(value);
      }
      if (double.tryParse(value) != null) {
        return double.parse(value);
      }
      if (value.toLowerCase() == 'null') {
        return null;
      }
      return value;
    }

    // Non-empty array - match the type of existing items
    final firstItem = parentArray.first;
    if (firstItem is String) {
      return value;
    }
         if (firstItem is int) {
       final intValue = int.tryParse(value);
       if (intValue != null) return intValue;
       _showError('Expected integer value');
       return _PARSE_ERROR;
     }
     if (firstItem is double) {
       final doubleValue = double.tryParse(value);
       if (doubleValue != null) return doubleValue;
       _showError('Expected number value');
       return _PARSE_ERROR;
     }
     if (firstItem is bool) {
       if (value.toLowerCase() == 'true') return true;
       if (value.toLowerCase() == 'false') return false;
       _showError('Expected boolean value (true/false)');
       return _PARSE_ERROR;
     }
     if (firstItem is List) {
       if (value.startsWith('[') && value.endsWith(']')) {
         try {
           return jsonDecode(value);
         } catch (e) {
           _showError('Invalid array format');
           return _PARSE_ERROR;
         }
       }
       _showError('Expected array format [item1, item2, ...]');
       return _PARSE_ERROR;
     }
     if (firstItem is Map) {
       if (value.startsWith('{') && value.endsWith('}')) {
         try {
           return jsonDecode(value);
         } catch (e) {
           _showError('Invalid object format');
           return _PARSE_ERROR;
         }
       }
       _showError('Expected object format {key: value}');
       return _PARSE_ERROR;
     }

    return value;
  }

  dynamic _parseObjectValue(String value) {
    if (value.isEmpty) return '';
    
    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
      return value.toLowerCase() == 'true';
    }
    if (int.tryParse(value) != null) {
      return int.parse(value);
    }
    if (double.tryParse(value) != null) {
      return double.parse(value);
    }
    if (value.toLowerCase() == 'null') {
      return null;
    }
         if (value.startsWith('[') && value.endsWith(']')) {
       try {
         return jsonDecode(value);
       } catch (e) {
         _showError('Invalid array format');
         return _PARSE_ERROR;
       }
     }
     if (value.startsWith('{') && value.endsWith('}')) {
       try {
         return jsonDecode(value);
       } catch (e) {
         _showError('Invalid object format');
         return _PARSE_ERROR;
       }
     }
    
    return value;
  }

  void _addItemToPath(Map<String, dynamic> data, String path, String type, String key, dynamic value) {
    final parts = _parsePath(path);
    dynamic current = data;
    
    // Navigate to the target (skip if path is empty - we're at root)
    if (parts.isNotEmpty) {
      for (final part in parts) {
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
    }
    
    // Current target = $current
    
    // Add the item
    if (type == 'object' && current is Map) {
      (current as Map<String, dynamic>)[key] = value;
    } else if (type == 'array' && current is List) {
      // Cast the value to the correct type to avoid type mismatch
      current.add(value as dynamic);
    } else {
      // Invalid target type: ${current.runtimeType}
    }
    
    // Final data = $data
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEditableKey(String path, String currentKey) {
    final isEditingKey = _editingKey == path;
    
    return isEditingKey
        ? _buildKeyEditField(path, currentKey)
        : GestureDetector(
            onTap: widget.readOnly ? null : () => _startEditingKey(path, currentKey),
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
                currentKey,
                style: TextStyle(
                  color: widget.theme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
  }

  Widget _buildKeyEditField(String path, String currentKey) {
    return SizedBox(
      width: 120, // Fixed width for key editing
      child: TextField(
        controller: _editController,
        focusNode: _editFocusNode,
        style: TextStyle(
          color: widget.theme.primaryColor,
          fontWeight: FontWeight.w500,
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
        onSubmitted: (newKey) => _finishEditingKey(path, currentKey, newKey),
        onEditingComplete: () => _finishEditingKey(path, currentKey, _editController.text),
      ),
    );
  }

  Widget _buildLeafNode(String path, dynamic value) {
    final displayName = _getDisplayName(path);
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

          // Key Name (editable)
          Expanded(
            flex: 2,
            child: _buildEditableKey(path, displayName),
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
            _buildDeleteButton(path, displayName),
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

  Widget _buildDeleteButton(String path, String displayName) {
    return GestureDetector(
      onTap: () => _deleteItem(path, displayName),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.theme.surfaceBackground,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.delete,
          color: widget.theme.errorColor,
          size: 14,
        ),
      ),
    );
  }

  void _deleteItem(String path, String displayName) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete "$displayName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteItem(path);
              },
              style: TextButton.styleFrom(
                foregroundColor: widget.theme.errorColor,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteItem(String path) {
    final parts = _parsePath(path);
    dynamic current = widget.data;
    
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
    
    // Delete the item
    final lastPart = parts.last;
    if (lastPart is String && current is Map && current.containsKey(lastPart)) {
      current.remove(lastPart);
      widget.onDataChanged(Map<String, dynamic>.from(widget.data));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "$lastPart"'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (lastPart is int && current is List && lastPart >= 0 && lastPart < current.length) {
      current.removeAt(lastPart);
      widget.onDataChanged(Map<String, dynamic>.from(widget.data));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted item at index $lastPart'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startEditing(String path, dynamic value) {
    // Clear any existing editing
    if (_editingKey != null || _addingToPath != null) {
      setState(() {
        _editingKey = null;
        _addingToPath = null;
      });
    }
    
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

  void _startEditingKey(String path, String currentKey) {
    // Clear any existing editing
    if (_editingPath != null || _addingToPath != null) {
      setState(() {
        _editingPath = null;
        _addingToPath = null;
      });
    }
    
    setState(() {
      _editingKey = path;
      _editController.text = currentKey;
    });
    
    // Focus the text field after the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocusNode.requestFocus();
      _editController.selection = TextSelection.fromPosition(
        TextPosition(offset: _editController.text.length),
      );
    });
  }

  void _finishEditingKey(String path, String oldKey, String newKey) {
    if (_editingKey != path) return;

    final trimmedKey = newKey.trim();
    if (trimmedKey.isEmpty || trimmedKey == oldKey) {
      setState(() {
        _editingKey = null;
      });
      return;
    }

    // Check if the new key already exists in the parent object (excluding the current key)
    final parentPath = _getParentPath(path);
    final parent = parentPath.isEmpty ? widget.data : _getValueAtPath(widget.data, parentPath);
    
    if (parent is Map && parent.containsKey(trimmedKey) && trimmedKey != oldKey) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Key "$trimmedKey" already exists'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _editingKey = null;
      });
      return;
    }

    // Rename the key in the data structure
    _renameKeyAtPath(widget.data, path, oldKey, trimmedKey);
    widget.onDataChanged(Map<String, dynamic>.from(widget.data));

    setState(() {
      _editingKey = null;
    });
  }

  String _getParentPath(String path) {
    final parts = path.split('.');
    if (parts.length <= 1) return '';
    return parts.take(parts.length - 1).join('.');
  }

  void _renameKeyAtPath(Map<String, dynamic> data, String path, String oldKey, String newKey) {
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
    
    // Rename the key
    final lastPart = parts.last;
    if (lastPart is String && current is Map && current.containsKey(lastPart)) {
      final value = current[lastPart];
      current.remove(lastPart);
      current[newKey] = value;
    }
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
      // Skip empty segments
      if (segment.isEmpty) continue;
      
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
