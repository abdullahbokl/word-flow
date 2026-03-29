import 'package:flutter/material.dart';

class LibrarySearchBar extends StatelessWidget {

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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search words...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: onClear,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
