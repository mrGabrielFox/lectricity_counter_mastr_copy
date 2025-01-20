import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class BlurredCupertinoPopup extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const BlurredCupertinoPopup(
      {super.key, required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Закругляем все углы
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                  red: 0,
                  green: 0,
                  blue: 0,
                  alpha:
                      128), // Используем withValues с именованными аргументами
              borderRadius: BorderRadius.circular(16), // Закругляем все углы
            ),
            child: CupertinoAlertDialog(
              title: Text("Заголовок"), // Заголовок вашего попапа
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child, // Ваш контент
                ],
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: onClose,
                  child: Text("Закрыть"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
