import 'package:flutter/material.dart';

void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
        SnackBar(
            content: Text(message),
            action: action,
            behavior: SnackBarBehavior.floating,
        ),
    );
}

class SheetMessenger extends StatelessWidget {
    const SheetMessenger({super.key, required this.child});

    final Widget child;

    @override
    Widget build(BuildContext context) {
        return ScaffoldMessenger(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: child,
            ),
        );
    }
}
