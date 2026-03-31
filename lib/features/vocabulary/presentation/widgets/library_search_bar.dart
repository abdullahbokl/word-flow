import 'package:flutter/material.dart';

class LibrarySearchBar extends StatefulWidget {
  const LibrarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isFocused
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.15)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isFocused
                ? scheme.primary.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search your words...',
            hintStyle: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused ? scheme.primary : scheme.onSurfaceVariant,
              size: 22,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      widget.onClear();
                      setState(() {}); // Reflect clear state
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {}); // Toggle clear button
          },
          onTapOutside: (_) => _focusNode.unfocus(),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }
}
