import 'package:flutter/foundation.dart';

/// A higher-order function that wraps async operations with error handling
Future<T> catchError<T>({
  required Future<T> Function() operation,
  Function(dynamic error)? onError,
  Function(T result)? onSuccess,
  T? defaultValue,
}) async {
  try {
    final result = await operation();
    onSuccess?.call(result);
    return result;
  } catch (error) {
    onError?.call(error);
    if (defaultValue != null) {
      return defaultValue;
    }
    rethrow;
  }
}

/// A higher-order function for void operations with error handling
Future<void> catchErrorVoid({
  required Future<void> Function() operation,
  Function(dynamic error)? onError,
  VoidCallback? onSuccess,
}) async {
  try {
    await operation();
    onSuccess?.call();
  } catch (error) {
    onError?.call(error);
    rethrow;
  }
}

/// A higher-order function that returns a boolean indicating success/failure
Future<bool> catchErrorBool<T>({
  required Future<T> Function() operation,
  Function(dynamic error)? onError,
  Function(T result)? onSuccess,
}) async {
  try {
    final result = await operation();
    onSuccess?.call(result);
    return true;
  } catch (error) {
    onError?.call(error);
    return false;
  }
}

/// A higher-order function for operations that return nullable results
Future<T?> catchErrorNullable<T>({
  required Future<T> Function() operation,
  Function(dynamic error)? onError,
  Function(T result)? onSuccess,
}) async {
  try {
    final result = await operation();
    onSuccess?.call(result);
    return result;
  } catch (error) {
    onError?.call(error);
    return null;
  }
}

/// Extension methods for easier error handling
extension ErrorHandlerExtensions<T> on Future<T> {
  /// Wraps a Future with error handling
  Future<T> withErrorHandler({
    Function(dynamic error)? onError,
    Function(T result)? onSuccess,
    T? defaultValue,
  }) {
    return catchError(
      operation: () => this,
      onError: onError,
      onSuccess: onSuccess,
      defaultValue: defaultValue,
    );
  }

  /// Wraps a Future with error handling and returns nullable
  Future<T?> withErrorHandlerNullable({
    Function(dynamic error)? onError,
    Function(T result)? onSuccess,
  }) {
    return catchErrorNullable(
      operation: () => this,
      onError: onError,
      onSuccess: onSuccess,
    );
  }

  /// Wraps a Future with error handling and returns boolean
  Future<bool> withErrorHandlerBool({
    Function(dynamic error)? onError,
    Function(T result)? onSuccess,
  }) {
    return catchErrorBool(
      operation: () => this,
      onError: onError,
      onSuccess: onSuccess,
    );
  }
}

/// Extension for void futures
extension ErrorHandlerVoidExtensions on Future<void> {
  /// Wraps a void Future with error handling
  Future<void> withErrorHandlerVoid({
    Function(dynamic error)? onError,
    VoidCallback? onSuccess,
  }) {
    return catchErrorVoid(
      operation: () => this,
      onError: onError,
      onSuccess: onSuccess,
    );
  }
}
