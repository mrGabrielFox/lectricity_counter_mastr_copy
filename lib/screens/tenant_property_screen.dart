import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем библиотеку для работы с Firestore
import 'package:electricity_counter_mastr_copy/list/add_list/meter_list_tenant.dart';
import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:flutter/cupertino.dart'; // Импортируем библиотеку Cupertino для iOS-стиля
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Импортируем библиотеку Material для использования виджетов Material

// Класс экрана для арендаторов, который отображает доступные свойства
class TenantPropertyScreen extends StatelessWidget {
  final CustomUser user; // Храним информацию о пользователе

  // Конструктор, который принимает пользователя
  const TenantPropertyScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Основной метод построения виджета
    return CupertinoPageScaffold(
      // Создаем обертку для страницы с навигационной панелью
      navigationBar: CupertinoNavigationBar(
        middle:
            Text('Доступная недвижимость'), // Заголовок навигационной панели
        trailing: CupertinoButton(
          padding: EdgeInsets.zero, // Убираем отступы
          onPressed: () {
            // Обработчик нажатия на кнопку "Назад"
            Navigator.pop(context); // Закрываем текущий экран
          },
          child: Icon(CupertinoIcons.clear), // Иконка кнопки "Назад"
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        // Стрим для получения данных о свойствах из Firestore
        stream: FirebaseFirestore.instance
            .collection('users') // Коллекция пользователей
            .doc(user.uid) // Документ текущего пользователя
            .collection('properties') // Коллекция свойств пользователя
            .where('invitedTenants',
                arrayContains: user
                    .uid) // Фильтруем свойства, в которых есть текущий пользователь
            .snapshots(), // Подписываемся на обновления данных
        builder: (context, snapshot) {
          // Обработчик состояния данных
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Если данные еще загружаются
            return Center(
                child:
                    CupertinoActivityIndicator()); // Показываем индикатор загрузки
          }

          if (snapshot.hasError) {
            // Если произошла ошибка при получении данных
            return Center(
                child: Text(
                    'Ошибка: ${snapshot.error}')); // Показываем сообщение об ошибке
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Если данных нет или они пустые
            return Center(
                child: Text(
                    'Вас еще не пригласили.')); // Сообщение о том, что приглашений нет
          }

          // Если данные успешно загружены, отображаем список свойств
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              // Проходим по каждому документу (свойству)
              Map<String, dynamic>? data = doc.data()
                  as Map<String, dynamic>?; // Получаем данные документа
              String propertyName =
                  data?['name'] ?? 'Без названия'; // Извлекаем имя свойства

              return GestureDetector(
                // Обработчик нажатия на элемент списка
                onTap: () {
                  // Переход на экран со списком счетчиков для выбранного свойства
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MeterListTenant(
                        propertyId: doc.id, // Передаем ID свойства
                        landlordUid: user.uid, // Передаем ID пользователя
                        userId: user.uid, // Передаем ID пользователя
                        selectedMeters: [], // Передаем пустой список счетчиков
                        onSelect: (String meterId) {
                          // Обработка выбора счетчика
                          if (kDebugMode) {
                            print("Выбран счетчик: $meterId");
                          }
                        },
                        firestore:
                            FirebaseFirestore.instance, // Передаем Firestore
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(8.0), // Отступы для карточки
                  child: Padding(
                    padding: EdgeInsets.all(16.0), // Отступы внутри карточки
                    child: Text(
                      propertyName, // Отображаем имя свойства
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold), // Стиль текста
                    ),
                  ),
                ),
              );
            }).toList(), // Преобразуем список документов в список виджетов
          );
        },
      ),
    );
  }
}
