// Импортируем необходимые пакеты и экраны
import 'package:electricity_counter_mastr_copy/screens/home_page_landlord.dart';
import 'package:electricity_counter_mastr_copy/screens/home_page_tenant.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import '../model/castom_user.dart';
import 'package:provider/provider.dart';

// Класс AuthWrapper отвечает за обертку аутентификации
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем StreamBuilder для отслеживания изменений состояния аутентификации
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Подписка на изменения аутентификации
      builder: (context, snapshot) {
        // Проверка состояния соединения
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CupertinoActivityIndicator()); // Индикатор загрузки
        }

        // Если пользователь аутентифицирован
        if (snapshot.hasData) {
          return _handleUser(snapshot.data!, context); // Обработка пользователя
        } else {
          return LoginScreen(); // Показ экрана входа, если пользователь не аутентифицирован
        }
      },
    );
  }

  // Метод для обработки данных аутентифицированного пользователя
  Widget _handleUser(User user, BuildContext context) {
    // Используем FutureBuilder для получения данных пользователя из Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(), // Получение документа пользователя
      builder: (context, snapshot) {
        // Проверка состояния соединения
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CupertinoActivityIndicator()); // Индикатор загрузки
        }

        // Проверка на наличие ошибки при получении данных
        if (snapshot.hasError) {
          return Center(
              child: Text('Ошибка загрузки данных')); // Сообщение об ошибке
        }

        // Проверка на наличие данных и их существование
        if (snapshot.hasData && snapshot.data!.exists) {
          final userDoc = snapshot.data!; // Получаем данные документа
          String name = userDoc['name'] ?? 'Неизвестно'; // Получаем имя
          String surname =
              userDoc['surname'] ?? 'Неизвестно'; // Получаем фамилию
          String phone = userDoc['phone'] ?? 'Неизвестно'; // Получаем телефон
          String status =
              userDoc['status'] ?? 'Неизвестно'; // Получаем статус пользователя

          // Приводим данные к типу Map<String, dynamic>?
          final data = userDoc.data() as Map<String, dynamic>?;

          // Проверка на наличие поля favoritePropertyIds
          String? favoritePropertyIdString =
              data != null && data.containsKey('favoritePropertyId')
                  ? data['favoritePropertyId'] as String?
                  : null;

          // Преобразование строки в список, если она не пустая
          List<String> favoritePropertyId = favoritePropertyIdString != null &&
                  favoritePropertyIdString.isNotEmpty
              ? favoritePropertyIdString
                  .split(',')
                  .map((id) => id.trim())
                  .toList()
              : []; // Значение по умолчанию, если поле отсутствует или пустое

          // Создаем объект CustomUser  и обновляем Provider
          CustomUser customUser = CustomUser.fromFirebaseUser(user,
              name: name,
              surname: surname,
              phone: phone,
              status: status,
              favoritePropertyId: favoritePropertyId);
          Provider.of<CustomUser>(context, listen: false).update(
              customUser); // Обновление состояния пользователя в Provider

          // В зависимости от статуса пользователя, возвращаем соответствующий экран
          if (status == "Арендодатель") {
            return HomePageLandlord(user: customUser); // Экран для арендодателя
          } else {
            return HomePageTenant(user: customUser); // Экран для арендатора
          }
        } else {
          return Center(
              child: Text(
                  'Данные пользователя не найдены')); // Сообщение, если данные не найдены
        }
      },
    );
  }
}
