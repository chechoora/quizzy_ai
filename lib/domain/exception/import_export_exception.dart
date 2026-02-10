class ImportExportException implements Exception {
  final String message = 'Import/Export failed';

  const ImportExportException();
}

class ImportLimitExceededException extends ImportExportException {
  const ImportLimitExceededException(this.type, this.limit) : super();

  @override
  String toString() => 'Import limit exceeded for $type: $limit';

  final ImportExportType type;
  final int limit;
}

enum ImportExportType {
  deck,
  card;
}
