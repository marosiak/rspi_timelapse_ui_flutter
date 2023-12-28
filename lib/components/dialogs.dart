import 'package:flutter/material.dart';

typedef OnAcceptedCallback = void Function();

class RemoveFilesDialog extends StatelessWidget {
  final OnAcceptedCallback onAccepted;

  const RemoveFilesDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: const Text('Are you sure?'),
      content: const Text(
          'This action will remove all images except last 10, there will be no way to retrieve it back'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onAccepted();
            Navigator.pop(context, 'Remove');
          },
          child: const Text('Remove'),
        ),
      ],
    );
  }
}

class RemoveFilesButton extends StatelessWidget {
  const RemoveFilesButton({
    super.key,
    required this.askToRemoveImages,
  });

  final OnAcceptedCallback askToRemoveImages;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            RemoveFilesDialog(
                onAccepted: askToRemoveImages),
      ),
      child: const Text("Remove all images"),
    );
  }
}
