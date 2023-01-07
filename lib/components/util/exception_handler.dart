class ExceptionHandler implements Exception {
  final String handledMessage;
  final int statusCode;

  ExceptionHandler({
    required this.handledMessage,
    required this.statusCode,
  });

  @override
  String toString() {
    return '$handledMessage\nCódigo do erro: $statusCode';
  }
}
