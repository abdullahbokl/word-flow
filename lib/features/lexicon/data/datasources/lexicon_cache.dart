import 'package:lexitrack/core/cache/local_cache.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';

class LexiconCache {
  const LexiconCache(this._cache);
  final LocalCache _cache;

  static const _filterKey = 'lexicon_filter';
  static const _sortKey = 'lexicon_sort';

  WordFilter getFilter() {
    final index = _cache.getInt(_filterKey);
    if (index == null || index >= WordFilter.values.length) {
      return WordFilter.all;
    }
    return WordFilter.values[index];
  }

  Future<void> saveFilter(WordFilter filter) async {
    await _cache.setInt(_filterKey, filter.index);
  }

  WordSort getSort() {
    final index = _cache.getInt(_sortKey);
    if (index == null || index >= WordSort.values.length) {
      return WordSort.frequencyDesc;
    }
    return WordSort.values[index];
  }

  Future<void> saveSort(WordSort sort) async {
    await _cache.setInt(_sortKey, sort.index);
  }
}
