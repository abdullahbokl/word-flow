import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/core/common/enums/state_status.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';

void main() {
  group('BlocStatus', () {
    test('initial state returns correct status', () {
      const state = BlocStatus<String>.initial(data: 'data');
      expect(state.status, StateStatus.initial);
      expect(state.isInitial, true);
      expect(state.data, 'data');
    });

    test('loading state returns correct status', () {
      const state = BlocStatus<int>.loading();
      expect(state.isLoading, true);
      expect(state.isInitial, false);
    });

    test('success state requires data', () {
      const state = BlocStatus<String>.success(data: 'success');
      expect(state.isSuccess, true);
      expect(state.data, 'success');
      expect(state.isFailed, false);
    });

    test('failure state requires error message', () {
      const state = BlocStatus<void>.failure(error: 'Something went wrong');
      expect(state.isFailed, true);
      expect(state.error, 'Something went wrong');
    });

    test('empty state preserves optional data', () {
      const state = BlocStatus<List<int>>.empty(data: []);
      expect(state.isEmpty, true);
      expect(state.data, []);
    });

    test('Equatable props include status, error, and data', () {
      const a = BlocStatus<String>.success(data: 'x');
      const b = BlocStatus<String>.success(data: 'x');
      const c = BlocStatus<String>.success(data: 'y');
      expect(a == b, true);
      expect(a == c, false);
    });
  });
}
