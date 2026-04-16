import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordflow/core/constants/app_dimensions.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/core/theme/design_tokens.dart';
import 'package:wordflow/core/widgets/app_text.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    required this.word,
    required this.onToggle,
    required this.onDelete,
    required this.onExclude,
    required this.onEdit,
    this.onAILookup,
    super.key,
  });

  final WordEntity word;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onExclude;
  final VoidCallback onEdit;
  final VoidCallback? onAILookup;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final word = widget.word;

    return Dismissible(
      key: ValueKey(word.id),
      // L->R excludes, R->L marks known
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          widget.onExclude();
        } else {
          widget.onToggle();
        }
      },
      background: _buildBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.error,
        icon: Icons.block_rounded,
        label: 'Exclude',
      ),
      secondaryBackground: _buildBackground(
        alignment: Alignment.centerRight,
        color: AppColors.statusKnown,
        icon: Icons.check_circle_outline_rounded,
        label: word.isKnown ? 'Mark Unknown' : 'Mark Known',
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppTokens.space8,
          horizontal: AppDimensions.pagePadding,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTokens.radius16),
          boxShadow: AppTokens.shadowLow,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(AppTokens.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space16),
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
                          AppText.title(
                            word.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: word.isKnown
                                ? AppColors.statusKnown
                                : colorScheme.onSurface,
                          ),
                          if (word.category != null ||
                              word.tags.isNotEmpty) ...[
                            const SizedBox(height: AppTokens.space8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (word.category != null)
                                    _Chip(
                                      label: word.category!.name,
                                      color: AppColors.primary,
                                    ),
                                  if (word.tags.isNotEmpty) ...[
                                    if (word.category != null)
                                      const SizedBox(width: AppTokens.space8),
                                    ...word.tags.map((tag) => Padding(
                                          padding: const EdgeInsets.only(
                                              right: AppTokens.space4),
                                          child: _Chip(
                                            label: tag.name,
                                            color: AppColors.accent,
                                            isSmall: true,
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.onAILookup != null)
                          IconButton(
                            onPressed: widget.onAILookup,
                            icon: const Icon(Icons.auto_awesome, size: 20),
                            color: AppColors.primary,
                            tooltip: 'AI Lookup',
                            visualDensity: VisualDensity.compact,
                          ),
                        Icon(
                          _isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
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
                    padding: const EdgeInsets.only(top: AppTokens.space12),
                    child: AppText.body(
                      word.definitions!.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                // Expandable Content
                AnimatedSize(
                  duration: AppTokens.durNormal,
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _isExpanded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (word.definitions != null &&
                            word.definitions!.isNotEmpty)
                          _DetailSection(
                            icon: Icons.menu_book_rounded,
                            title: 'Definitions',
                            content: word.definitions!,
                            color: AppColors.primary,
                          ),
                        if (word.examples != null && word.examples!.isNotEmpty)
                          _DetailSection(
                            icon: Icons.lightbulb_outline_rounded,
                            title: 'Examples',
                            content: word.examples!,
                            fontStyle: FontStyle.italic,
                            color: Colors.orange[700]!,
                          ),
                        if (word.translations != null &&
                            word.translations!.isNotEmpty)
                          _DetailSection(
                            icon: Icons.translate_rounded,
                            title: 'Translations',
                            content: word.translations!,
                            color: Colors.teal[600]!,
                          ),
                        if (word.synonyms != null && word.synonyms!.isNotEmpty)
                          _DetailSection(
                            icon: Icons.link_rounded,
                            title: 'Similar Words',
                            content: word.synonyms!,
                            color: Colors.deepPurple[400]!,
                          ),
                        if (word.meaning != null && word.meaning!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin:
                                const EdgeInsets.only(top: AppTokens.space16),
                            padding: const EdgeInsets.all(AppTokens.space12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radius12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notes_rounded,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppText.caption(
                                    word.meaning!,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppTokens.space16),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: widget.onDelete,
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: widget.onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: AppTokens.durNormal).scale(
            begin: const Offset(0.95, 0.95),
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(
        vertical: AppTokens.space8,
        horizontal: AppDimensions.pagePadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            AppText.label(label, color: color, fontWeight: FontWeight.bold),
          ] else ...[
            AppText.label(label, color: color, fontWeight: FontWeight.bold),
            const SizedBox(width: 8),
            Icon(icon, color: color),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.isSmall = false,
  });

  final String label;
  final Color color;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radius8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: AppText.caption(
        label,
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: isSmall ? 10 : 12,
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    this.fontStyle,
  });

  final IconData icon;
  final String title;
  final List<String> content;
  final Color color;
  final FontStyle? fontStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              AppText.label(
                title,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...content.map((item) => Padding(
                padding: const EdgeInsets.only(left: 22.0, bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: color)),
                    Expanded(
                      child: AppText.body(
                        item,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: fontStyle,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
