import 'package:flutter/material.dart';
import 'package:word_flow/core/errors/failures.dart';

extension FailureMapper on Failure {
  String get title {
    return switch (this) {
      DatabaseFailure() => 'Database Error',
      SyncFailure() => 'Sync Pending',
      ServerFailure() => 'Connection Issue',
      AuthFailure() => 'Session Expired',
      ConnectionFailure() => 'You are Offline',
      _ => 'Something Went Wrong',
    };
  }

  String get friendlyMessage {
    return switch (this) {
      DatabaseFailure() =>
        'Something went wrong loading your words. Tap to retry.',
      SyncFailure() =>
        "Couldn't sync your changes. They're saved locally and will retry.",
      ServerFailure() => 'Server error. Please check your connection.',
      AuthFailure() => 'Your session has expired. Please sign in again.',
      ConnectionFailure() => 'Check your internet connection and try again.',
      _ => message.isNotEmpty ? message : 'An unexpected error occurred.',
    };
  }

  IconData get icon {
    return switch (this) {
      DatabaseFailure() => Icons.storage_rounded,
      SyncFailure() => Icons.cloud_off_rounded,
      ServerFailure() => Icons.cloud_circle_rounded,
      AuthFailure() => Icons.account_circle_rounded,
      ConnectionFailure() => Icons.wifi_off_rounded,
      _ => Icons.error_outline_rounded,
    };
  }
}
