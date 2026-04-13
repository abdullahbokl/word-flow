import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';

abstract interface class LexiconPreferences {
  WordFilter getFilter();
  WordSort getSort();
  Future<void> saveFilter(WordFilter filter);
  Future<void> saveSort(WordSort sort);
}
