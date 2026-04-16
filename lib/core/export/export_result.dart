sealed class ExportResult {
  const ExportResult();
}

class ExportSuccess extends ExportResult {
  const ExportSuccess(this.path);
  final String path;
}

class ExportFailure extends ExportResult {
  const ExportFailure(this.message);
  final String message;
}
