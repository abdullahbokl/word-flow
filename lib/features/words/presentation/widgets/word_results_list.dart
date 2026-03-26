import 'package:flutter/material.dart';
import '../../../../core/widgets/word_card.dart';
import '../../../../core/utils/script_processor.dart';

class WordResultsList extends StatelessWidget {
  final List<ProcessedWord> words;
  final Function(String wordText) onToggle;

  const WordResultsList({
    super.key,
    required this.words,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: words.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final word = words[index];
            return WordCard(
              text: word.wordText,
              count: word.totalCount,
              isKnown: false,
              onToggle: () => onToggle(word.wordText),
            );
          },
        ),
      ],
    );
  }
}
