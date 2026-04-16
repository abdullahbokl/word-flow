sealed class AiResult<T> {
  const AiResult();
}

final class AiLoading<T> extends AiResult<T> {
  const AiLoading();
}

final class AiLoaded<T> extends AiResult<T> {
  const AiLoaded(this.data);
  final T data;
}

final class AiError<T> extends AiResult<T> {
  const AiError(this.message);
  final String message;
}
