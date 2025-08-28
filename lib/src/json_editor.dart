import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

import 'theme/red_panda_theme.dart';
import 'widgets/syntax_highlighted_text.dart';
import 'widgets/json_tree_view.dart';

/// A beautiful and feature-rich JSON editor widget for Flutter.
/// 
/// This widget provides a dual-view JSON editor with syntax highlighting,
/// tree view navigation, real-time validation, and customizable themes.
/// 
/// ## Features
/// 
/// * **Dual View Mode**: Switch between text editor and tree view
/// * **Syntax Highlighting**: Color-coded JSON syntax with customizable themes
/// * **Real-time Validation**: Live JSON validation with error highlighting
/// * **Tree View**: Interactive tree view for easy JSON navigation
/// * **Copy Functionality**: Built-in copy to clipboard support
/// * **Customizable Themes**: Theme system with RedPandaTheme included
/// * **Responsive Design**: Works seamlessly across different screen sizes
/// 
/// ## Example
/// 
/// ```dart
/// JsonEditor(
///   initialData: {'name': 'John Doe', 'age': 30},
///   onDataChanged: (newData) {
///     print('JSON changed: $newData');
///   },
///   title: 'My JSON Data',
///   allowCopy: true,
///   theme: RedPandaTheme(),
/// )
/// ```
class JsonEditor extends StatefulWidget {
  /// The initial JSON data to display in the editor.
  /// 
  /// This data will be formatted and displayed when the widget is first created.
  /// The data should be a valid JSON object (Map<String, dynamic>).
  final Map<String, dynamic> initialData;

  /// Callback function that is called whenever the JSON data changes.
  /// 
  /// This callback receives the updated JSON data as a Map<String, dynamic>.
  /// Use this to handle data changes in your application.
  final Function(Map<String, dynamic>) onDataChanged;

  /// The title displayed in the editor header.
  /// 
  /// Defaults to 'JSON Editor' if not specified.
  final String title;

  /// Whether the editor is in read-only mode.
  /// 
  /// When true, the editor will display the JSON data but prevent editing.
  /// Defaults to false.
  final bool readOnly;

  /// Whether to show copy functionality in the editor.
  /// 
  /// When true, a copy button will be available in the header.
  /// Defaults to false.
  final bool allowCopy;

  /// Callback function called when the editor is collapsed.
  /// 
  /// This is called when the user collapses the editor using the expand/collapse button.
  final VoidCallback? onCollapse;

  /// The initial expansion state of the editor.
  /// 
  /// If null, the editor will start expanded by default.
  final bool? isExpanded;

  /// Callback function called when the expansion state changes.
  /// 
/// This callback receives a boolean indicating whether the editor is expanded.
  final Function(bool)? onExpansionChanged;

  /// Custom theme for the JSON editor.
  /// 
  /// If not specified, the default RedPandaTheme will be used.
  /// You can create custom themes by extending JsonEditorTheme.
  final JsonEditorTheme? theme;

  const JsonEditor({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    this.title = 'JSON Editor',
    this.readOnly = false,
    this.allowCopy = false,
    this.onCollapse,
    this.isExpanded,
    this.onExpansionChanged,
    this.theme,
  });

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _textController;
  late ScrollController _lineNumbersScrollController;
  late ScrollController _textScrollController;
  late FocusNode _textFieldFocusNode;
  late Map<String, dynamic> _currentData;
  late JsonEditorTheme _theme;

  bool _isValidJson = true;
  String _errorMessage = '';
  bool _isExpanded = true;
  Timer? _debounceTimer;
  String _lastHighlightedText = '';

  // Debug variables
  List<String> _debugEntries = [];

  void _addDebugEntry(String entry) {
    _debugEntries.add(entry);
    setState(() {});
  }

  void _clearDebugEntries() {
    _debugEntries.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _lineNumbersScrollController = ScrollController();
    _textScrollController = ScrollController();
    _textFieldFocusNode = FocusNode();
    _currentData = Map<String, dynamic>.from(widget.initialData);
    _theme = widget.theme ?? RedPandaTheme();

    // Initialize text controller with formatted JSON
    _textController = TextEditingController(text: _formatJson(_currentData));
    _lastHighlightedText = _textController.text;

    // Handle expansion state
    if (widget.isExpanded != null) {
      _isExpanded = widget.isExpanded!;
    }

    // Set up scroll synchronization
    _lineNumbersScrollController.addListener(_syncScroll);
    _textScrollController.addListener(_syncScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _lineNumbersScrollController.dispose();
    _textScrollController.dispose();
    _textFieldFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _syncScroll() {
    // Scroll synchronization will be handled by the CustomScrollView
  }

  void _insertSmartIndentation() {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Handle edge cases
    if (cursorPosition < 0 || cursorPosition > text.length) {
      return;
    }

    // Get current line and position
    final lineInfo = _getLineInfo(cursorPosition);
    if (lineInfo == null) return;

    final currentLine = lineInfo['line'] as String;
    final lineStart = lineInfo['lineStart'] as int;
    final cursorInLine = lineInfo['cursorInLine'] as int;
    final currentLineIndex = lineInfo['lineIndex'] as int;

    // Get text before and after cursor
    final beforeCursor = currentLine.substring(0, cursorInLine);
    final afterCursor = currentLine.substring(cursorInLine);

    // Calculate proper indentation based on JSON context
    final contextInfo = _analyzeJsonContext(cursorPosition);
    final newIndentation = _calculateIndentation(contextInfo, beforeCursor);

    // Insert the indentation
    final newText = beforeCursor + newIndentation + afterCursor;
    final newCursorPosition = cursorPosition + newIndentation.length;

    _updateTextAtLine(currentLineIndex, lineStart, currentLine, newText);
    _textController.selection = TextSelection.collapsed(
      offset: newCursorPosition,
    );
  }

  void _decreaseIndentation() {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Handle edge cases
    if (cursorPosition < 0 || cursorPosition > text.length) {
      return;
    }

    // Get current line and position
    final lineInfo = _getLineInfo(cursorPosition);
    if (lineInfo == null) return;

    final currentLine = lineInfo['line'] as String;
    final lineStart = lineInfo['lineStart'] as int;
    final cursorInLine = lineInfo['cursorInLine'] as int;
    final currentLineIndex = lineInfo['lineIndex'] as int;

    // Get text before and after cursor
    final beforeCursor = currentLine.substring(0, cursorInLine);
    final afterCursor = currentLine.substring(cursorInLine);

    // Calculate current indentation
    final currentIndent = beforeCursor.length - beforeCursor.trimLeft().length;

    // Decrease indentation by 2 spaces, but not below 0
    final newIndent = (currentIndent - 2).clamp(0, currentIndent);
    final newIndentation = ' ' * newIndent;

    // Create new line text
    final beforeCursorTrimmed = beforeCursor.trimLeft();
    final newText = newIndentation + beforeCursorTrimmed + afterCursor;
    final newCursorPosition = cursorPosition - (currentIndent - newIndent);

    _updateTextAtLine(currentLineIndex, lineStart, currentLine, newText);
    _textController.selection = TextSelection.collapsed(
      offset: newCursorPosition,
    );
  }

  void _insertNewLineWithIndentation() {
    // Debug: Show that this method is being called
    _addDebugEntry(
      'ENTER KEY PRESSED - _insertNewLineWithIndentation() called',
    );

    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Handle edge cases
    if (cursorPosition < 0 || cursorPosition > text.length) {
      _addDebugEntry('ERROR: Invalid cursor position: $cursorPosition');
      return;
    }

    // Get current line and position
    final lineInfo = _getLineInfo(cursorPosition);
    if (lineInfo == null) {
      _addDebugEntry('ERROR: Could not get line info');
      return;
    }

    final currentLine = lineInfo['line'] as String;
    final cursorInLine = lineInfo['cursorInLine'] as int;
    final currentLineIndex = lineInfo['lineIndex'] as int;

    _addDebugEntry(
      'Line Info: line="$currentLine", cursorInLine=$cursorInLine, lineIndex=$currentLineIndex',
    );

    // Get text before and after cursor
    final beforeCursor = currentLine.substring(0, cursorInLine);
    final afterCursor = currentLine.substring(cursorInLine);

    _addDebugEntry(
      'Before/After: before="$beforeCursor", after="$afterCursor"',
    );

    // Analyze JSON context to determine proper indentation
    final contextInfo = _analyzeJsonContext(cursorPosition);
    _addDebugEntry('Context Info: $contextInfo');

    final newIndentation = _calculateNewLineIndentation(
      contextInfo,
      beforeCursor,
      afterCursor,
    );

    // Create the new text by inserting the new line at the cursor position
    final newText =
        text.substring(0, cursorPosition) +
        '\n' +
        newIndentation +
        text.substring(cursorPosition);
    final newCursorPosition = cursorPosition + 1 + newIndentation.length;

    _addDebugEntry(
      'FINAL: newIndentation="${newIndentation.length} spaces", newCursorPosition=$newCursorPosition',
    );

    // Update the text controller directly
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: newCursorPosition,
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return '{}';
    }
  }

  void _validateAndUpdateJson(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
      setState(() {
        _currentData = decoded;
        _isValidJson = true;
        _errorMessage = '';
      });
      widget.onDataChanged(_currentData);
    } catch (e) {
      setState(() {
        _isValidJson = false;
        _errorMessage = 'Invalid JSON: $e';
      });
    }
  }

  void _onTextChanged(String text) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Validate JSON immediately
    _validateAndUpdateJson(text);

    // Debounce syntax highlighting
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && text != _lastHighlightedText) {
        setState(() {
          _lastHighlightedText = text;
        });
      }
    });
  }

  void _updateTreeData(Map<String, dynamic> newData) {
    setState(() {
      _currentData = newData;
      _textController.text = _formatJson(_currentData);
      _lastHighlightedText = _textController.text;
      _isValidJson = true;
      _errorMessage = '';
    });
    widget.onDataChanged(_currentData);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _formatJson(_currentData)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _textController.text = data!.text!;
      _validateAndUpdateJson(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _theme.editorBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _theme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Content
          if (_isExpanded) ...[
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(),
                children: [_buildTreeView(), _buildRawJsonView()],
              ),
            ),

            // Error Message
            if (!_isValidJson) _buildErrorMessage(),

            // Debug Info
            if (_debugEntries.isNotEmpty) _buildDebugInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _theme.headerBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: _theme.foreground,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),

          // View Toggle
          _buildViewToggle(),

          const SizedBox(width: 12),

          // Action Buttons
          if (!widget.readOnly) ...[
            _buildActionButton(
              icon: Icons.copy,
              tooltip: 'Copy JSON',
              onPressed: _copyToClipboard,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.paste,
              tooltip: 'Paste JSON',
              onPressed: _pasteFromClipboard,
            ),
          ],

          const SizedBox(width: 8),
          _buildActionButton(
            icon: _isExpanded ? Icons.expand_less : Icons.expand_more,
            tooltip: _isExpanded ? 'Collapse' : 'Expand',
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onExpansionChanged?.call(_isExpanded);
              if (!_isExpanded) {
                widget.onCollapse?.call();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _theme.surfaceBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _theme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Tree', 0),
          Container(width: 1, height: 24, color: _theme.borderColor),
          _buildToggleButton('Raw', 1),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _theme.onPrimary : _theme.foreground,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: _theme.surfaceBackground,
          borderRadius: BorderRadius.circular(4),
        ),
        child: IconButton(
          icon: Icon(icon, color: _theme.foreground, size: 16),
          onPressed: onPressed,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ),
    );
  }

  Widget _buildTreeView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 300),
          child: IntrinsicHeight(
            child: JsonTreeView(
              data: _currentData,
              onDataChanged: _updateTreeData,
              readOnly: widget.readOnly,
              allowCopy: widget.allowCopy,
              theme: _theme,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRawJsonView() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // JSON Editor with Line Numbers
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _theme.editorBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _isValidJson ? _theme.borderColor : _theme.errorColor,
                  width: 1,
                ),
              ),
              child: widget.readOnly
                  ? _buildReadOnlyView()
                  : _buildEditableView(),
            ),
          ),

          // Action Buttons
          if (!widget.readOnly) ...[
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SyntaxHighlightedText(text: _textController.text, theme: _theme),
    );
  }

  Widget _buildEditableView() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: CustomScrollView(
        controller: _lineNumbersScrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: _theme.lineNumbersBackground,
                    border: Border(
                      right: BorderSide(color: _theme.borderColor, width: 1),
                    ),
                  ),
                  child: _buildLineNumbersOverlay(),
                ),
                // Text editor
                Expanded(
                  child: Focus(
                    focusNode: _textFieldFocusNode,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          // Handle enter key with custom indentation
                          _insertNewLineWithIndentation();
                          // Prevent the default behavior
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.tab) {
                          // Handle tab key with context-aware indentation
                          if (HardwareKeyboard.instance.isShiftPressed) {
                            // Shift+Tab: Decrease indentation
                            _decreaseIndentation();
                          } else {
                            // Tab: Increase indentation
                            _insertSmartIndentation();
                          }
                          // Prevent default tab behavior
                          return KeyEventResult.handled;
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.bracketLeft) {
                          // Auto-close brackets
                          _insertAutoClosingBracket('[');
                          return KeyEventResult.handled;
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.braceLeft) {
                          // Auto-close braces
                          _insertAutoClosingBrace('{');
                          return KeyEventResult.handled;
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.quote) {
                          // Auto-close quotes
                          _insertAutoClosingQuote('"');
                          return KeyEventResult.handled;
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.bracketRight) {
                          // Handle closing bracket with proper indentation
                          _handleClosingBracket(']');
                          return KeyEventResult.handled;
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.braceRight) {
                          // Handle closing brace with proper indentation
                          _handleClosingBrace('}');
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: _theme.foreground,
                        height: 1.4,
                      ),
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 12, right: 12),
                      ),
                      cursorColor: _theme.cursorColor,
                      onChanged: _onTextChanged,
                      // Enable better keyboard shortcuts
                      enableInteractiveSelection: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      // Add custom keyboard shortcuts
                      onTapOutside: (event) {
                        _textFieldFocusNode.unfocus();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumbersOverlay() {
    final lines = _textController.text.split('\n');
    final lineHeight = 13.0 * 1.4; // Match text editor line height

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        lines.length,
        (index) => SizedBox(
          height: lineHeight,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: _theme.foreground.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _textController.text = _formatJson(_currentData);
              _validateAndUpdateJson(_textController.text);
            },
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Format', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.primaryColor,
              foregroundColor: _theme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentData = {};
                _textController.text = '{}';
                _isValidJson = true;
                _errorMessage = '';
              });
              widget.onDataChanged(_currentData);
            },
            icon: const Icon(Icons.clear, size: 14),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _validateAndUpdateJson(_textController.text);
              if (_isValidJson) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON is valid!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle, size: 14),
            label: const Text('Validate', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValidJson ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _theme.errorColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.error, color: _theme.errorColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: _theme.errorColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Debug Info (${_debugEntries.length} entries)',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.clear, color: Colors.blue.shade600, size: 16),
                onPressed: _clearDebugEntries,
                tooltip: 'Clear debug info',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.blue.shade600, size: 16),
                onPressed: () {
                  final debugText = _debugEntries.join('\n');
                  Clipboard.setData(ClipboardData(text: debugText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debug info copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copy debug info',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 200, // Fixed height for scrollable area
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _debugEntries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          entry,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _getLineInfo(int cursorPosition) {
    final text = _textController.text;
    final lines = text.split('\n');
    int charCount = 0;

    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i].length;
      if (charCount + lineLength + 1 > cursorPosition) {
        final lineStart = charCount;
        final cursorInLine = cursorPosition - lineStart;

        return {
          'line': lines[i],
          'lineStart': lineStart,
          'cursorInLine': cursorInLine.clamp(0, lineLength),
          'lineIndex': i,
        };
      }
      charCount += lineLength + 1; // +1 for newline
    }

    // Handle cursor at the end of the last line
    if (lines.isNotEmpty) {
      final lastLine = lines.last;
      final lineStart = charCount - lastLine.length - 1;
      return {
        'line': lastLine,
        'lineStart': lineStart,
        'cursorInLine': lastLine.length,
        'lineIndex': lines.length - 1,
      };
    }

    return null;
  }

  Map<String, dynamic> _analyzeJsonContext(int cursorPosition) {
    final text = _textController.text;
    final contextInfo = <String, dynamic>{
      'braceLevel': 0,
      'bracketLevel': 0,
      'isInsideString': false,
      'isAfterColon': false,
      'isAfterComma': false,
      'isAfterOpeningBrace': false,
      'isAfterOpeningBracket': false,
      'isBeforeClosingBrace': false,
      'isBeforeClosingBracket': false,
      'currentIndent': 0,
    };

    // Scan backwards from cursor to analyze context
    int braceCount = 0;
    int bracketCount = 0;
    bool inString = false;
    bool escapeNext = false;

    for (int i = cursorPosition - 1; i >= 0; i--) {
      final char = text[i];

      if (escapeNext) {
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        escapeNext = true;
        continue;
      }

      if (char == '"' && !escapeNext) {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (char == '{') {
        braceCount++;
        if (braceCount == 1) {
          contextInfo['isAfterOpeningBrace'] = true;
        }
      } else if (char == '}') {
        braceCount--;
      } else if (char == '[') {
        bracketCount++;
        if (bracketCount == 1) {
          contextInfo['isAfterOpeningBracket'] = true;
        }
      } else if (char == ']') {
        bracketCount--;
      } else if (char == ':') {
        contextInfo['isAfterColon'] = true;
        // Don't break - continue scanning to count brackets
      } else if (char == ',') {
        contextInfo['isAfterComma'] = true;
        // Don't break - continue scanning to count brackets
      }
    }

    // Scan forwards from cursor to check for closing braces/brackets
    inString = false;
    escapeNext = false;

    for (int i = cursorPosition; i < text.length; i++) {
      final char = text[i];

      if (escapeNext) {
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        escapeNext = true;
        continue;
      }

      if (char == '"' && !escapeNext) {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (char == '}' || char == ']') {
        contextInfo['isBeforeClosingBrace'] = char == '}';
        contextInfo['isBeforeClosingBracket'] = char == ']';
        break;
      } else if (!char.trim().isEmpty && char != '\n') {
        break; // Found non-whitespace, non-newline character
      }
    }

    contextInfo['braceLevel'] = braceCount;
    contextInfo['bracketLevel'] = bracketCount;

    // Calculate current indentation
    final lineInfo = _getLineInfo(cursorPosition);
    if (lineInfo != null) {
      final currentLine = lineInfo['line'] as String;
      final cursorInLine = lineInfo['cursorInLine'] as int;
      final beforeCursor = currentLine.substring(0, cursorInLine);
      contextInfo['currentIndent'] =
          beforeCursor.length - beforeCursor.trimLeft().length;
    }

    return contextInfo;
  }

  String _calculateIndentation(
    Map<String, dynamic> contextInfo,
    String beforeCursor,
  ) {
    final currentIndent = contextInfo['currentIndent'] as int;
    final isAfterColon = contextInfo['isAfterColon'] as bool;
    final isAfterComma = contextInfo['isAfterComma'] as bool;
    final isAfterOpeningBrace = contextInfo['isAfterOpeningBrace'] as bool;
    final isAfterOpeningBracket = contextInfo['isAfterOpeningBracket'] as bool;

    // If we're after a colon, we're likely starting a value
    if (isAfterColon) {
      return ' ' * (currentIndent + 2);
    }

    // If we're after a comma, maintain current indentation
    if (isAfterComma) {
      return ' ' * currentIndent;
    }

    // If we're after an opening brace/bracket, increase indentation
    if (isAfterOpeningBrace || isAfterOpeningBracket) {
      return ' ' * (currentIndent + 2);
    }

    // Default: increase indentation by 2 spaces
    return ' ' * (currentIndent + 2);
  }

  String _calculateNewLineIndentation(
    Map<String, dynamic> contextInfo,
    String beforeCursor,
    String afterCursor,
  ) {
    final currentIndent = contextInfo['currentIndent'] as int;
    final isAfterColon = contextInfo['isAfterColon'] as bool;
    final isAfterComma = contextInfo['isAfterComma'] as bool;
    final isAfterOpeningBrace = contextInfo['isAfterOpeningBrace'] as bool;
    final isAfterOpeningBracket = contextInfo['isAfterOpeningBracket'] as bool;
    final isBeforeClosingBrace = contextInfo['isBeforeClosingBrace'] as bool;
    final isBeforeClosingBracket =
        contextInfo['isBeforeClosingBracket'] as bool;
    final bracketLevel = contextInfo['bracketLevel'] as int;

    // If we're before a closing brace/bracket AND not in an array context, decrease indentation
    if ((isBeforeClosingBrace || isBeforeClosingBracket) && bracketLevel == 0) {
      _addDebugEntry(
        'RESULT: Before closing brace/bracket (not in array) - returning ${(currentIndent - 2).clamp(0, currentIndent)} spaces',
      );
      return ' ' * (currentIndent - 2).clamp(0, currentIndent);
    }

    // Check if the current line ends with an opening brace/bracket
    final trimmedBefore = beforeCursor.trim();
    if (trimmedBefore.endsWith('{') || trimmedBefore.endsWith('[')) {
      _addDebugEntry(
        'RESULT: Line ends with opening brace/bracket - returning ${currentIndent + 2} spaces',
      );
      return ' ' * (currentIndent + 2);
    }

    // Check if the next line starts with a closing brace/bracket
    final trimmedAfter = afterCursor.trim();
    if (trimmedAfter.startsWith('}') || trimmedAfter.startsWith(']')) {
      _addDebugEntry(
        'RESULT: Next line starts with closing brace/bracket - returning ${(currentIndent - 2).clamp(0, currentIndent)} spaces',
      );
      return ' ' * (currentIndent - 2).clamp(0, currentIndent);
    }

    // Special handling for array elements (check this BEFORE general comma handling)
    if (bracketLevel > 0) {
      // We're inside an array - calculate proper array indentation
      final arrayIndent = _calculateArrayIndentation();

      debugPrint(
        'Array context - bracketLevel: $bracketLevel, arrayIndent: $arrayIndent, currentIndent: $currentIndent',
      );
      _addDebugEntry(
        'Array: bracketLevel=$bracketLevel, arrayIndent=$arrayIndent, currentIndent=$currentIndent',
      );
      debugPrint(
        'Array context - isAfterComma: $isAfterComma, trimmedBefore: "$trimmedBefore", afterCursor: "$afterCursor"',
      );
      _addDebugEntry(
        'Array: isAfterComma=$isAfterComma, trimmedBefore="$trimmedBefore", afterCursor="$afterCursor"',
      );

      // Check if the current line ends with a comma (indicating we're between array elements)
      final lineInfo = _getLineInfo(_textController.selection.baseOffset);
      bool currentLineEndsWithComma = false;
      int currentLineIndent = 0;
      if (lineInfo != null) {
        final currentLineIndex = lineInfo['lineIndex'] as int;
        final lines = _textController.text.split('\n');
        final currentLine = lines[currentLineIndex];
        final trimmedCurrentLine = currentLine.trim();
        currentLineEndsWithComma = trimmedCurrentLine.endsWith(',');
        // Calculate the indentation of the current line
        currentLineIndent = currentLine.length - currentLine.trimLeft().length;
        debugPrint(
          'Current line check: "$trimmedCurrentLine" ends with comma: $currentLineEndsWithComma, indent: $currentLineIndent',
        );
        _addDebugEntry(
          'Current Line: "$trimmedCurrentLine" ends with comma: $currentLineEndsWithComma, indent: $currentLineIndent',
        );
      }

      // Debug: Show all lines for context
      final allLines = _textController.text.split('\n');
      _addDebugEntry('All lines:');
      for (int i = 0; i < allLines.length; i++) {
        _addDebugEntry('  Line $i: "${allLines[i]}"');
      }

      // If the current line ends with a comma, maintain the same indentation level
      if (currentLineEndsWithComma) {
        final result = ' ' * currentLineIndent;
        debugPrint(
          'Array current line ends with comma - maintaining current line indentation: ${result.length} spaces',
        );
        _addDebugEntry(
          'RESULT: Current line ends with comma - returning ${result.length} spaces',
        );
        return result;
      }

      // If we're at the end of a line that ends with a quote, we're at the end of a string value
      if (afterCursor.isEmpty && trimmedBefore.endsWith('"')) {
        // We're at the end of a string value in an array
        // Insert a new line with the same indentation as the array elements
        final result = ' ' * (arrayIndent + 2);
        debugPrint(
          'Array string end - returning indentation: ${result.length} spaces',
        );
        return result;
      }

      // If we're after a comma in an array, maintain the array element indentation
      if (isAfterComma) {
        final result = ' ' * (arrayIndent + 2);
        debugPrint(
          'Array after comma - returning indentation: ${result.length} spaces',
        );
        return result;
      }

      // If the current line ends with a comma, maintain the same indentation level
      if (currentLineEndsWithComma) {
        final result = ' ' * currentLineIndent;
        debugPrint(
          'Array current line ends with comma - maintaining current line indentation: ${result.length} spaces',
        );
        _addDebugEntry(
          'RESULT: Current line ends with comma - returning ${result.length} spaces',
        );
        return result;
      }

      // If we're at the beginning of a new array element, use the array indentation
      if (trimmedBefore.isEmpty) {
        final result = ' ' * (arrayIndent + 2);
        debugPrint(
          'Array new element - returning indentation: ${result.length} spaces',
        );
        _addDebugEntry(
          'RESULT: New array element - returning ${result.length} spaces',
        );
        return result;
      }

      // Default for array elements: use array indentation + 2 spaces
      final result = ' ' * (arrayIndent + 2);
      debugPrint(
        'Array default - returning indentation: ${result.length} spaces',
      );
      _addDebugEntry(
        'RESULT: Array default - returning ${result.length} spaces',
      );
      return result;
    }

    // General logic (only if not in array)
    // If we're after a comma, maintain current indentation (check this first)
    if (isAfterComma) {
      _addDebugEntry(
        'RESULT: After comma - maintaining current indentation: ${currentIndent} spaces',
      );
      return ' ' * currentIndent;
    }

    // If we're after a colon, we're starting a new value
    if (isAfterColon) {
      _addDebugEntry(
        'RESULT: After colon - increasing indentation: ${currentIndent + 2} spaces',
      );
      return ' ' * (currentIndent + 2);
    }

    // If we're after an opening brace/bracket, increase indentation
    if (isAfterOpeningBrace || isAfterOpeningBracket) {
      return ' ' * (currentIndent + 2);
    }

    // Default: maintain current indentation
    return ' ' * currentIndent;
  }

  int _calculateArrayIndentation() {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    debugPrint('_calculateArrayIndentation: cursorPosition=$cursorPosition');
    _addDebugEntry(
      '_calculateArrayIndentation: cursorPosition=$cursorPosition',
    );

    // Find the opening bracket of the current array by scanning backwards
    int bracketCount = 0;
    bool inString = false;
    bool escapeNext = false;

    for (int i = cursorPosition - 1; i >= 0; i--) {
      final char = text[i];

      if (escapeNext) {
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        escapeNext = true;
        continue;
      }

      if (char == '"' && !escapeNext) {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (char == ']') {
        bracketCount++;
      } else if (char == '[') {
        bracketCount--;
        if (bracketCount == 0) {
          // Found the opening bracket of the array that contains our cursor
          // Find the line containing this bracket and calculate its indentation
          final lines = text.split('\n');
          int charCount = 0;

          for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
            final line = lines[lineIndex];
            final lineLength = line.length;

            if (charCount <= i && i < charCount + lineLength) {
              // Found the line containing the bracket
              final bracketInLine = i - charCount;
              final beforeBracket = line.substring(0, bracketInLine);
              // Calculate indentation to align with the array opening bracket
              final indent =
                  beforeBracket.length - beforeBracket.trimLeft().length;
              debugPrint(
                'Array indentation calculated: $indent spaces from line: "$line" (bracket at position $bracketInLine)',
              );
              _addDebugEntry(
                'Array bracket found: "$line" at position $bracketInLine, indent: $indent',
              );
              return indent;
            }

            charCount += lineLength + 1; // +1 for newline
          }
        }
      }
    }

    // Fallback: use current indentation
    final lineInfo = _getLineInfo(cursorPosition);
    if (lineInfo != null) {
      final currentLine = lineInfo['line'] as String;
      final cursorInLine = lineInfo['cursorInLine'] as int;
      final beforeCursor = currentLine.substring(0, cursorInLine);
      final fallbackIndent =
          beforeCursor.length - beforeCursor.trimLeft().length;
      debugPrint(
        'Array indentation fallback: $fallbackIndent spaces from current line: "$currentLine"',
      );
      _addDebugEntry(
        'Array indentation fallback: $fallbackIndent spaces from current line: "$currentLine"',
      );
      return fallbackIndent;
    }

    debugPrint('Array indentation default: 0 spaces');
    return 0; // Default to 0 spaces for top-level arrays
  }

  void _updateTextAtLine(
    int lineIndex,
    int lineStart,
    String oldLine,
    String newLine,
  ) {
    final text = _textController.text;
    final lines = text.split('\n');

    if (lineIndex < lines.length) {
      lines[lineIndex] = newLine;
      _textController.text = lines.join('\n');
    }
  }

  void _insertAutoClosingBracket(String openingChar) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Determine the correct closing character based on the opening character
    String closingChar;
    if (openingChar == '[') {
      closingChar = ']';
    } else if (openingChar == '{') {
      closingChar = '}';
    } else {
      closingChar = openingChar; // Fallback
    }

    // Insert opening bracket and closing bracket
    final newText =
        text.substring(0, cursorPosition) +
        openingChar +
        closingChar +
        text.substring(cursorPosition);
    _textController.text = newText;

    // Move cursor between the brackets
    _textController.selection = TextSelection.collapsed(
      offset: cursorPosition + 1,
    );
  }

  void _insertAutoClosingBrace(String openingChar) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Insert opening brace and closing brace
    final newText =
        text.substring(0, cursorPosition) +
        openingChar +
        '}' +
        text.substring(cursorPosition);
    _textController.text = newText;

    // Move cursor between the braces
    _textController.selection = TextSelection.collapsed(
      offset: cursorPosition + 1,
    );
  }

  void _insertAutoClosingQuote(String quoteChar) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Check if we're already inside a string
    bool inString = false;
    bool escapeNext = false;

    for (int i = 0; i < cursorPosition; i++) {
      if (escapeNext) {
        escapeNext = false;
        continue;
      }
      if (text[i] == '\\') {
        escapeNext = true;
        continue;
      }
      if (text[i] == '"') {
        inString = !inString;
      }
    }

    if (inString) {
      // We're inside a string, just insert the quote
      final newText =
          text.substring(0, cursorPosition) +
          quoteChar +
          text.substring(cursorPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    } else {
      // We're outside a string, insert opening and closing quotes
      final newText =
          text.substring(0, cursorPosition) +
          quoteChar +
          quoteChar +
          text.substring(cursorPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    }
  }

  void _handleClosingBracket(String closingChar) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Check if the next character is already the closing bracket
    if (cursorPosition < text.length && text[cursorPosition] == closingChar) {
      // Just move the cursor past it
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    } else {
      // Insert the closing bracket
      final newText =
          text.substring(0, cursorPosition) +
          closingChar +
          text.substring(cursorPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    }
  }

  void _handleClosingBrace(String closingChar) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset;

    // Check if the next character is already the closing brace
    if (cursorPosition < text.length && text[cursorPosition] == closingChar) {
      // Just move the cursor past it
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    } else {
      // Insert the closing brace
      final newText =
          text.substring(0, cursorPosition) +
          closingChar +
          text.substring(cursorPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    }
  }
}


