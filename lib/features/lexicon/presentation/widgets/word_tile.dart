import 'package:flutter/material.dart';

import '../../../../core/domain/entities/word_entity.dart';

const _knownColor = Color(0xFF2E7D32);

class WordTile extends StatefulWidget {
  const WordTile({
    required this.word,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  final WordEntity word;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final word = widget.word;

    return Dismissible(
      key: ValueKey(word.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: colorScheme.onErrorContainer),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.text,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _Badge(
                                label: 'Seen ${word.frequency}x',
                                icon: Icons.visibility_outlined,
                                color: colorScheme.primary,
                              ),
                              if (word.isKnown) ...[
                                const SizedBox(width: 8),
                                const _Badge(
                                  label: 'Mastered',
                                  icon: Icons.auto_awesome,
                                  color: Colors.amber,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onToggle,
                          icon: Icon(
                            word.isKnown
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: word.isKnown ? _knownColor : colorScheme.outline,
                            size: 28,
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),

                // Compact view definition snippet
                if (!_isExpanded &&
                    word.definitions != null &&
                    word.definitions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      word.definitions!.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                // Expandable Content
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _isExpanded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (word.definitions != null &&
                            word.definitions!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.menu_book_rounded,
                            content: word.definitions!,
                            color: colorScheme.primary,
                          ),
                        if (word.examples != null && word.examples!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.lightbulb_outline_rounded,
                            content: word.examples!,
                            fontStyle: FontStyle.italic,
                            color: Colors.orange[700],
                          ),
                        if (word.translations != null &&
                            word.translations!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.translate_rounded,
                            content: word.translations!,
                            color: Colors.teal[600],
                          ),
                        if (word.synonyms != null && word.synonyms!.isNotEmpty)
                          _DetailRow(
                            icon: Icons.link_rounded,
                            content: word.synonyms!,
                            color: Colors.deepPurple[400],
                          ),
                        if (word.meaning != null && word.meaning!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notes_rounded,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    word.meaning!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        const Divider(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.content,
    this.color,
    this.fontStyle,
  });

  final IconData icon;
  final List<String> content;
  final Color? color;
  final FontStyle? fontStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color:
                    color ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                _getLabel(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color?.withValues(alpha: 0.8) ??
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...content.map((item) => Padding(
                padding: const EdgeInsets.only(left: 22.0, bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: color ?? theme.colorScheme.onSurfaceVariant)),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color ?? theme.colorScheme.onSurfaceVariant,
                          fontStyle: fontStyle,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _getLabel() {
    if (icon == Icons.menu_book_rounded) return 'Definitions';
    if (icon == Icons.lightbulb_outline_rounded) return 'Examples';
    if (icon == Icons.translate_rounded) return 'Translations';
    if (icon == Icons.link_rounded) return 'Similar Words';
    return '';
  }
}
