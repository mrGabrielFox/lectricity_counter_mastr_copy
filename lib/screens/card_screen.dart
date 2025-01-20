import 'package:electricity_counter_mastr_copy/model/background.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return CupertinoPageScaffold(
      child: Background(
        isDarkTheme: themeProvider.isDarkTheme,
        child: SingleChildScrollView(
          // Добавляем прокрутку
          child: Column(
            children: [
              _buildAppBar(context),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              _buildCard(height: 200, width: 300),
              // Добавьте больше карточек, если необходимо
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return _buildCard(height: 100, width: double.infinity);
  }

  Card _buildCard({required double height, required double width}) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.fromLTRB(
          16, 16, 16, 4), // Увеличиваем отступы для визуального комфорта
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(16.0),
        ),
        // Здесь можно оставить пустым или добавить какой-либо элемент, если необходимо
        child: Center(child: Text('')), // Пустой текст
      ),
    );
  }
}
