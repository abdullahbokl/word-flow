import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class StopwordsLoader {
  final Map<String, Set<String>> _cache = {};

  Future<Set<String>> load(String language) async {
    final lang = language.toLowerCase();
    if (_cache.containsKey(lang)) {
      return _cache[lang]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/stopwords/$lang.json',
      );
      final List<dynamic> list = json.decode(jsonString);
      final set = list.cast<String>().toSet();
      _cache[lang] = set;
      return set;
    } catch (e) {
      // Fallback to empty if not found or error
      return {};
    }
  }

  void clearCache() => _cache.clear();
}
