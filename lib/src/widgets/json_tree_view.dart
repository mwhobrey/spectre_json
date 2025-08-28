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

  @override
  void initState() {
    super.initState();
    // Always expand root node
    _expandedNodes.add('');
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

          // Value
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(color: valueColor, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

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
