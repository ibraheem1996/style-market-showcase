class MappingException implements Exception {
  final String message;

  const MappingException(this.message);

  @override
  String toString() => 'MappingException: $message';
}
