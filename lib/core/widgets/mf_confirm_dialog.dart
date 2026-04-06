import 'package:flutter/material.dart';

Future<bool> showMfConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
  String cancelLabel = 'Cancelar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
