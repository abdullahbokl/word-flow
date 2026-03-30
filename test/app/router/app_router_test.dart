import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/app/router/app_router.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;
  late AppRouter appRouter;

  setUp(() {
    authCubit = MockAuthCubit();
    when(
      () => authCubit.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    appRouter = AppRouter(authCubit);
  });

  test('authenticated user redirects /splash to /workspace', () {
    when(() => authCubit.state).thenReturn(
      const AuthState.authenticated(
        AuthUser(id: 'u-1', email: 'u1@example.com'),
      ),
    );

    final redirect = appRouter.redirectForLocation('/splash');

    expect(redirect, '/workspace');
  });

  test('guest user redirects /splash to /workspace', () {
    when(() => authCubit.state).thenReturn(const AuthState.guest());

    final redirect = appRouter.redirectForLocation('/splash');

    expect(redirect, '/workspace');
  });
}
