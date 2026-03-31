import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/utils/porter_stemmer.dart';

void main() {
  final stemmer = PorterStemmer();

  group('PorterStemmer', () {
    test('Step 1a: plurals and -ss-', () {
      expect(stemmer.stem('caresses'), 'caress');
      expect(stemmer.stem('ponies'), 'poni');
      expect(stemmer.stem('ties'), 'ti');
      expect(stemmer.stem('caress'), 'caress');
      expect(stemmer.stem('cats'), 'cat');
    });

    test('Step 1b: -eed, -ed, -ing', () {
      expect(stemmer.stem('feed'), 'feed');
      expect(stemmer.stem('agreed'), 'agre');
      expect(stemmer.stem('plastered'), 'plaster');
      expect(stemmer.stem('bled'), 'bled');
      expect(stemmer.stem('motoring'), 'motor');
      expect(stemmer.stem('sing'), 'sing');
    });

    test('Step 1b extra: cleanup after -ed/-ing removal', () {
      expect(stemmer.stem('conflated'), 'conflat');
      expect(stemmer.stem('troubled'), 'troubl');
      expect(stemmer.stem('sized'), 'size');
      expect(stemmer.stem('hopping'), 'hop');
      expect(stemmer.stem('tanned'), 'tan');
      expect(stemmer.stem('falling'), 'fall');
      expect(stemmer.stem('hissing'), 'hiss');
      expect(stemmer.stem('fizzed'), 'fizz');
      expect(stemmer.stem('failing'), 'fail');
      expect(stemmer.stem('filing'), 'file');
    });

    test('Step 1c: y to i', () {
      expect(stemmer.stem('happy'), 'happi');
      expect(stemmer.stem('sky'), 'sky');
    });

    test('Step 2: common suffixes', () {
      expect(stemmer.stem('relational'), 'relat');
      expect(stemmer.stem('conditional'), 'condit');
      expect(stemmer.stem('rational'), 'ration');
      expect(stemmer.stem('valenci'), 'valenc');
      expect(stemmer.stem('hesitanci'), 'hesit');
      expect(stemmer.stem('digitizer'), 'digit');
      expect(stemmer.stem('conformabli'), 'conform');
      expect(stemmer.stem('radicalli'), 'radic');
      expect(stemmer.stem('differentli'), 'differ');
      expect(stemmer.stem('vileli'), 'vile');
      expect(stemmer.stem('analogousli'), 'analog');
      expect(stemmer.stem('vietnamization'), 'vietnam');
      expect(stemmer.stem('predication'), 'predic');
      expect(stemmer.stem('operator'), 'oper');
      expect(stemmer.stem('feudalism'), 'feudal');
      expect(stemmer.stem('decisiveness'), 'decis');
      expect(stemmer.stem('hopefulness'), 'hope');
      expect(stemmer.stem('callousness'), 'callous');
      expect(stemmer.stem('formaliti'), 'formal');
      expect(stemmer.stem('sensitiviti'), 'sensit');
      expect(stemmer.stem('sensibiliti'), 'sensibl');
    });

    test('Irregular/Common variants', () {
      expect(stemmer.stem('running'), 'run');
      expect(stemmer.stem('runs'), 'run');
      expect(
        stemmer.stem('runner'),
        'runner',
      ); // "runner" should actually stem to "runner" in Porter unless Step 4 handles it
      expect(stemmer.stem('walked'), 'walk');
      expect(stemmer.stem('walking'), 'walk');
      expect(stemmer.stem('walks'), 'walk');
    });
  });
}
