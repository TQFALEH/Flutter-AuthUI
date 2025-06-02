import 'package:flutter/material.dart';

/// ويدجت لإغلاق لوحة المفاتيح عند الضغط في أي مكان
class DismissKeyboardWrapper extends StatelessWidget {
  final Widget child;

  const DismissKeyboardWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
