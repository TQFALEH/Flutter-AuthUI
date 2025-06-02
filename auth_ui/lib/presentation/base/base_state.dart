import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  @protected
  void showLoading() {
    if (!mounted) return;
    setState(() => _isLoading = true);
  }

  @protected
  void hideLoading() {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @protected
  void showError(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    showErrorSnackBar(message);
  }

  @protected
  void clearError() {
    if (!mounted) return;
    setState(() => _error = null);
  }

  @protected
  void showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @protected
  void showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @protected
  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }
}
