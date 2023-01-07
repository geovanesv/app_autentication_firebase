// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  const Badge({
    Key? key,
    required this.child,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            // cria margens em torno do número para aumentar o círculo de background
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color ?? Theme.of(context).colorScheme.secondary,
            ),
            // força o tamanho mínimo para o container (círculo de fundo)
            constraints: const BoxConstraints(minHeight: 16, minWidth: 16),
            child: Text(
              value,
              // alinha o texto no centro do container
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
