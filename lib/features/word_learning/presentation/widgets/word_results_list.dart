import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/word_results_animated_item.dart';

class WordResultsList extends StatefulWidget {

  const WordResultsList({
    super.key,
    required this.words,
    required this.pendingWordTexts,
    this.enabled = true,
  });
  final List<ProcessedWord> words;
  final Set<String> pendingWordTexts;
  final bool enabled;

  @override
  State<WordResultsList> createState() => _WordResultsListState();
}

class _WordResultsListState extends State<WordResultsList> {
  static const _exitDuration = Duration(milliseconds: 700);
  static const _insertDuration = Duration(milliseconds: 600);

  GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  late List<ProcessedWord> _visibleWords;

  @override
  void initState() {
    super.initState();
    _visibleWords = _targetWords(widget.words, widget.pendingWordTexts);
  }

  @override
  void didUpdateWidget(covariant WordResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldHardReset(oldWidget)) {
      setState(() {
        _listKey = GlobalKey<SliverAnimatedListState>();
        _visibleWords = _targetWords(widget.words, widget.pendingWordTexts);
      });
      return;
    }

    final newlyPending = widget.pendingWordTexts.difference(oldWidget.pendingWordTexts);
    for (final text in newlyPending) {
      _removeByText(text, animated: true);
    }

    final noLongerPending = oldWidget.pendingWordTexts.difference(widget.pendingWordTexts);
    for (final text in noLongerPending) {
      final sourceWord = widget.words.where((w) => w.wordText == text).firstOrNull;
      if (sourceWord != null && !_visibleWords.any((w) => w.wordText == text)) _insertAt(sourceWord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _visibleWords.length,
      itemBuilder: (context, index, animation) => _buildItem(index, animation),
    );
  }

  Widget _buildItem(int index, Animation<double> animation, {ProcessedWord? wordOverride}) {
    final word = wordOverride ?? _visibleWords[index];
    return WordResultsAnimatedItem(
      animation: animation,
      word: word,
      isPending: widget.pendingWordTexts.contains(word.wordText),
      isLast: _visibleWords.isNotEmpty && identical(_visibleWords.last, word),
      enabled: widget.enabled,
    );
  }

  void _removeByText(String text, {required bool animated}) {
    final index = _visibleWords.indexWhere((w) => w.wordText == text);
    if (index < 0) return;
    final removed = _visibleWords.removeAt(index);

    final state = _listKey.currentState;
    if (state == null) return;

    state.removeItem(
      index,
      (context, animation) =>
          _buildItem(index, animation, wordOverride: removed),
      duration: animated ? _exitDuration : Duration.zero,
    );
  }

  void _insertAt(ProcessedWord word) {
    final target = _targetWords(widget.words, widget.pendingWordTexts);
    final i = target.indexWhere((w) => w.wordText == word.wordText);
    final safeIndex = i < 0 ? _visibleWords.length : i;
    _visibleWords.insert(safeIndex, word);

    final state = _listKey.currentState;
    if (state == null) return;

    state.insertItem(safeIndex, duration: _insertDuration);
  }

  bool _shouldHardReset(WordResultsList oldWidget) {
    if (oldWidget.pendingWordTexts.isNotEmpty || widget.pendingWordTexts.isNotEmpty) {
      return false;
    }
    if (oldWidget.words.length != widget.words.length) return true;
    for (var i = 0; i < oldWidget.words.length; i++) {
      if (oldWidget.words[i].wordText != widget.words[i].wordText ||
          oldWidget.words[i].totalCount != widget.words[i].totalCount ||
          oldWidget.words[i].isKnown != widget.words[i].isKnown) {
        return true;
      }
    }
    return false;
  }

  List<ProcessedWord> _targetWords(List<ProcessedWord> source, Set<String> pending) =>
      source.where((w) => !pending.contains(w.wordText)).toList(growable: true);
}
