import 'package:flutter/material.dart';

enum MessageType { info, sucess, error }

class SnackBarMessage {
  final String messageText;
  final MessageType messageType;

  SnackBarMessage({required BuildContext context, required this.messageText, required this.messageType, int durationInSeconds = 2, SnackBarAction? action}) {
    IconData iconImage;

    if (messageType == MessageType.info) {
      iconImage = Icons.info;
    } else if (messageType == MessageType.error) {
      iconImage = Icons.error_outline;
    } else {
      iconImage = Icons.check_circle_outline;
    }

    // remove o snackbar anterior
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Row(
            children: [
              Icon(iconImage, color: Colors.white),
              const SizedBox(width: 5),
              Flexible(child: Text(messageText)),
            ],
          ),
          duration: Duration(seconds: durationInSeconds),
          backgroundColor: messageType == MessageType.error ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
          action: action),
    );
  }
}
