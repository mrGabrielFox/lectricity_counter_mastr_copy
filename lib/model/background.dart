import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final bool isDarkTheme;
  final Widget child;

  const Background({super.key, required this.isDarkTheme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isDarkTheme
                ? 'assets/images/dark_background2.jpg'
                : 'assets/images/light_background2.jpg',
          ),
          fit: BoxFit.cover, // Убедитесь, что изображение заполняет весь экран
        ),
      ),
      child: child,
    );
  }
}
