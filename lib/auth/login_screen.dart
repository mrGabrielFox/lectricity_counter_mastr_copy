import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electricity_counter_mastr_copy/auth/registration_screen.dart';
import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/home_page_landlord.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Future<void> _loginUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String name = userDoc['name'] ?? '';
        String surname = userDoc['surname'] ?? '';
        String phone = userDoc['phone'] ?? '';
        String status = userDoc['status'] ?? '';

        CustomUser customUser = CustomUser(
          uid: userCredential.user!.uid,
          name: name,
          surname: surname,
          email: userCredential.user!.email ?? '',
          phone: phone,
          status: status,
        );

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => HomePageLandlord(user: customUser),
            ),
          );
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Пользователь не найден в базе данных.');
        }
      }
    } catch (e) {
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Вход'),
      ),
      child: Container(
        color: themeProvider.isDarkTheme ? Colors.black : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  placeholder: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color:
                        themeProvider.isDarkTheme ? Colors.white : Colors.black,
                  ),
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                ),
                CupertinoTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  placeholder: 'Пароль',
                  obscureText: true,
                  style: TextStyle(
                    color:
                        themeProvider.isDarkTheme ? Colors.white : Colors.black,
                  ),
                  onSubmitted: (_) => _loginUser(context),
                ),
                SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: () => _loginUser(context),
                  child: Text('Войти'),
                ),
                SizedBox(height: 20),
                CupertinoButton(
                  child: Text('Нет аккаунта? Зарегистрироваться'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => RegistrationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
