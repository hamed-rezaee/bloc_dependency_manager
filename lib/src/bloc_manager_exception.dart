/// Bloc manager exception class.
class BlocManagerException implements Exception {
  /// Initializes bloc manager exception.
  ///
  /// [message] - The message of the exception.
  BlocManagerException({required this.message});

  /// The message of the exception.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
