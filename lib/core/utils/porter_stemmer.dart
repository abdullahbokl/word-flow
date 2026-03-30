/// A Dart implementation of the Porter Stemming Algorithm.
/// Reference: https://tartarus.org/martin/PorterStemmer/def.txt
class PorterStemmer {
  /// Stems a word to its root form.
  String stem(String word) {
    if (word.length <= 2) return word;

    String res = word.toLowerCase();

    // Step 1a
    res = _step1a(res);

    // Step 1b
    res = _step1b(res);

    // Step 1c
    res = _step1c(res);

    // Step 2
    res = _step2(res);

    // Step 3
    res = _step3(res);

    // Step 4
    res = _step4(res);

    // Step 5a
    res = _step5a(res);

    // Step 5b
    res = _step5b(res);

    return res;
  }

  String _step1a(String w) {
    if (w.endsWith('sses')) return w.substring(0, w.length - 2);
    if (w.endsWith('ies')) return '${w.substring(0, w.length - 3)}i';
    if (w.endsWith('ss')) return w;
    if (w.endsWith('s')) return w.substring(0, w.length - 1);
    return w;
  }

  String _step1b(String w) {
    if (w.endsWith('eed')) {
      if (_countMeasure(w.substring(0, w.length - 3)) > 0) {
        return w.substring(0, w.length - 1);
      }
      return w;
    }

    if (w.endsWith('ed')) {
      final stem = w.substring(0, w.length - 2);
      if (_hasVowel(stem)) return _cleanup1b(stem);
      return w;
    }

    if (w.endsWith('ing')) {
      final stem = w.substring(0, w.length - 3);
      if (_hasVowel(stem)) return _cleanup1b(stem);
      return w;
    }

    return w;
  }

  String _cleanup1b(String stem) {
    if (stem.endsWith('at') || stem.endsWith('bl') || stem.endsWith('iz')) {
      return '${stem}e';
    }
    // Double consonant check (but not l, s, z)
    if (_isDoubleConsonant(stem) &&
        !stem.endsWith('l') &&
        !stem.endsWith('s') &&
        !stem.endsWith('z')) {
      return stem.substring(0, stem.length - 1);
    }
    // Early measure check
    if (_countMeasure(stem) == 1 && _isCVC(stem)) {
      return '${stem}e';
    }
    return stem;
  }

  String _step1c(String w) {
    if (w.endsWith('y') && _hasVowel(w.substring(0, w.length - 1))) {
      return '${w.substring(0, w.length - 1)}i';
    }
    return w;
  }

  String _step2(String w) {
    const suffixes = {
      'ational': 'ate',
      'tional': 'tion',
      'enci': 'ence',
      'anci': 'ance',
      'izer': 'ize',
      'bli': 'ble',
      'alli': 'al',
      'entli': 'ent',
      'eli': 'e',
      'ousli': 'ous',
      'ization': 'ize',
      'ation': 'ate',
      'ator': 'ate',
      'alism': 'al',
      'iveness': 'ive',
      'fulness': 'ful',
      'ousness': 'ous',
      'aliti': 'al',
      'iviti': 'ive',
      'biliti': 'ble',
    };

    for (final entry in suffixes.entries) {
      if (w.endsWith(entry.key)) {
        final stem = w.substring(0, w.length - entry.key.length);
        if (_countMeasure(stem) > 0) return '$stem${entry.value}';
        return w;
      }
    }
    return w;
  }

  String _step3(String w) {
    const suffixes = {
      'icate': 'ic',
      'ative': '',
      'alize': 'al',
      'iciti': 'ic',
      'ical': 'ic',
      'ful': '',
      'ness': '',
    };

    for (final entry in suffixes.entries) {
      if (w.endsWith(entry.key)) {
        final stem = w.substring(0, w.length - entry.key.length);
        if (_countMeasure(stem) > 0) return '$stem${entry.value}';
        return w;
      }
    }
    return w;
  }

  String _step4(String w) {
    const suffixes = [
      'al', 'ance', 'ence', 'er', 'ic', 'able', 'ible', 'ant', 'ement',
      'ment', 'ent', 'ou', 'ism', 'ate', 'iti', 'ous', 'ive', 'ize'
    ];

    for (final s in suffixes) {
      if (w.endsWith(s)) {
        final stem = w.substring(0, w.length - s.length);
        if (_countMeasure(stem) > 1) return stem;
        return w;
      }
    }

    if (w.endsWith('ion')) {
        final stem = w.substring(0, w.length - 3);
        if (_countMeasure(stem) > 1 && (stem.endsWith('s') || stem.endsWith('t'))) {
            return stem;
        }
    }

    return w;
  }

  String _step5a(String w) {
    if (w.endsWith('e')) {
      final stem = w.substring(0, w.length - 1);
      final m = _countMeasure(stem);
      if (m > 1 || (m == 1 && !_isCVC(stem))) return stem;
    }
    return w;
  }

  String _step5b(String w) {
    if (_countMeasure(w) > 1 && _isDoubleConsonant(w) && w.endsWith('l')) {
      return w.substring(0, w.length - 1);
    }
    return w;
  }

  // Helper methods for Porter algorithm

  bool _isConsonant(String w, int i) {
    final c = w[i];
    if ('aeiou'.contains(c)) return false;
    if (c == 'y') {
      if (i == 0) return true;
      return !_isConsonant(w, i - 1);
    }
    return true;
  }

  /// The measure m of a word is defined as follows:
  /// [C](VC)^m[V]
  /// where C is a sequence of consonants and V is a sequence of vowels.
  int _countMeasure(String w) {
    int m = 0;
    int i = 0;
    final len = w.length;

    // skip initial consonants
    while (i < len && _isConsonant(w, i)) {
      i++;
    }

    while (i < len) {
      // found a vowel sequence, skip it
      while (i < len && !_isConsonant(w, i)) {
        i++;
      }
      if (i >= len) break;

      // found a consonant sequence, this completes one (VC)
      while (i < len && _isConsonant(w, i)) {
        i++;
      }
      m++;
    }

    return m;
  }

  bool _hasVowel(String w) {
    for (int i = 0; i < w.length; i++) {
        if (!_isConsonant(w, i)) return true;
    }
    return false;
  }

  bool _isDoubleConsonant(String w) {
    if (w.length < 2) return false;
    if (w[w.length - 1] != w[w.length - 2]) return false;
    return _isConsonant(w, w.length - 1);
  }

  bool _isCVC(String w) {
    final len = w.length;
    if (len < 3) return false;
    if (!_isConsonant(w, len - 1) || 'wxy'.contains(w[len - 1])) return false;
    if (_isConsonant(w, len - 2)) return false;
    if (!_isConsonant(w, len - 3)) return false;
    return true;
  }
}
