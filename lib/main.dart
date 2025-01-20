import 'package:electricity_counter_mastr_copy/auth/auth_wrapper.dart';
import 'package:electricity_counter_mastr_copy/model/background.dart';
import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: ChangeNotifierProvider<CustomUser>(
        create: (context) => CustomUser(
          uid: '',
          name: '',
          surname: '',
          email: '',
          phone: '',
          status: '',
        ), // Инициализация CastomUser
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return CupertinoApp(
      title: 'Управление недвижимостью',
      theme: themeProvider.isDarkTheme
          ? CupertinoThemeData(
              brightness: Brightness.dark,
              primaryColor: CupertinoColors.activeBlue,
            )
          : CupertinoThemeData(
              brightness: Brightness.light,
              primaryColor: CupertinoColors.activeBlue,
            ),
      home: Background(
        isDarkTheme: themeProvider.isDarkTheme,
        child: const AuthWrapper(), // Используйте AuthWrapper
      ),
    );
  }
}
