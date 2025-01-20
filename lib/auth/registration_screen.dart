import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/home_page_landlord.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Импортируйте Material для использования цветов
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class RegistrationScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedStatus; // Убедитесь, что это поле не final

  RegistrationScreen({super.key});

  Future<void> _registerUser(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog(context, 'Пароли не совпадают');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User user = userCredential.user!;

      // Создайте экземпляр CastomUser
      CustomUser newUser = CustomUser(
        uid: user.uid,
        name: '',
        surname: '',
        email: user.email!,
        phone: '',
        status:
            _selectedStatus ?? 'Арендатор', // Установить статус по умолчанию
      );

      // Сохранение данных пользователя в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      // Проверка на смонтированность виджета
      if (context.mounted) {
        // Переход к экрану свойств после успешной регистрации
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => HomePageLandlord(user: newUser),
          ),
        );
      }
    } catch (e) {
      // Проверка на смонтированность виджета перед показом диалога
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('ОК'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Регистрация'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: themeProvider.isDarkTheme ? Colors.black : Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black),
              ),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Пароль',
                obscureText: true,
                style: TextStyle(
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black),
              ),
              CupertinoTextField(
                controller: _confirmPasswordController,
                placeholder: 'Повторите пароль',
                obscureText: true,
                style: TextStyle(
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black),
              ),
              SizedBox(height: 20),
              CupertinoSegmentedControl<String>(
                children: {
                  'Арендатор': Text('Арендатор'),
                  'Арендодатель': Text('Арендодатель'),
                },
                onValueChanged: (value) {
                  _selectedStatus = value;
                },
                groupValue: _selectedStatus,
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () => _registerUser(context),
                child: Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
