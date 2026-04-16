import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/features/lexicon/domain/repositories/category_repository.dart';
import 'package:wordflow/features/lexicon/presentation/cubit/category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({
    required CategoryRepository categoryRepository,
  })  : _categoryRepository = categoryRepository,
        super(const CategoryInitial());

  final CategoryRepository _categoryRepository;
  StreamSubscription? _subscription;

  Future<void> loadTags() async {
    emit(const CategoryLoading());
    await _subscription?.cancel();
    _subscription = _categoryRepository.watchCustomTags().listen((result) {
      result.fold(
        (failure) => emit(CategoryError(failure.toString())),
        (tags) => emit(CategoryLoaded(tags)),
      );
    });
  }

  Future<void> addTag(String name) async {
    final result = await _categoryRepository.addCustomTag(name).run();
    result.fold(
      (failure) => emit(CategoryError(failure.toString())),
      (_) => null, // Stream will update UI
    );
  }

  Future<void> deleteTag(int tagId) async {
    final result = await _categoryRepository.deleteCustomTag(tagId).run();
    result.fold(
      (failure) => emit(CategoryError(failure.toString())),
      (_) => null, // Stream will update UI
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
