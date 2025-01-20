import 'package:electricity_counter_mastr_copy/list/add_list/meter_list_tenant.dart';
import 'package:flutter/cupertino.dart'; // Импортируем библиотеку Cupertino для iOS-стиля
import 'package:cloud_firestore/cloud_firestore.dart'; // Импортируем библиотеку для работы с Firestore
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Импортируем библиотеку Material для использования виджетов Material

// Класс экрана для отображения доступной недвижимости для приглашенных пользователей
class InvitedPropertiesScreen extends StatelessWidget {
  final String invitedUserUid; // UID приглашенного пользователя
  final FirebaseFirestore firestore; // Добавляем параметр для Firestore

  // Конструктор, который принимает UID приглашенного пользователя и экземпляр Firestore
  const InvitedPropertiesScreen({
    super.key,
    required this.invitedUserUid,
    required this.firestore, // Передаем экземпляр Firestore
  });

  @override
  Widget build(BuildContext context) {
    // Основной метод построения виджета
    return CupertinoPageScaffold(
      // Создаем обертку для страницы с навигационной панелью
      navigationBar: CupertinoNavigationBar(
        middle:
            Text("Доступная недвижимость"), // Заголовок навигационной панели
      ),
      child: StreamBuilder<QuerySnapshot>(
        // Стрим для получения данных о свойствах из Firestore
        stream: firestore
            .collection('users') // Коллекция пользователей
            .where('invitedTenants',
                arrayContains:
                    invitedUserUid) // Фильтруем пользователей по UID приглашенного пользователя
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
                    'Нет доступной недвижимости.')); // Сообщение о том, что недвижимости нет
          }

          final properties = snapshot.data!.docs; // Получаем список свойств
          return ListView.builder(
            // Используем ListView.builder для создания списка свойств
            itemCount: properties.length, // Количество элементов в списке
            itemBuilder: (context, index) {
              // Создаем элемент списка для каждого свойства
              final property = properties[index].data()
                  as Map<String, dynamic>; // Получаем данные свойства
              return ListTile(
                title: Text(property['name'] ??
                    'Без названия'), // Заголовок с именем свойства
                subtitle: Text(
                    property['city'] ?? 'Не указано'), // Подзаголовок с городом
                onTap: () {
                  // Обработчик нажатия на элемент списка
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MeterListTenant(
                        firestore: firestore, // Передаем экземпляр Firestore
                        propertyId:
                            properties[index].id, // Передаем ID свойства
                        landlordUid: invitedUserUid, // Передаем UID владельца
                        selectedMeters: [], // Передаем пустой список выбранных счетчиков
                        onSelect: (String meterId) {
                          // Логика обработки выбора счетчика
                          if (kDebugMode) {
                            print('Выбран счетчик: $meterId');
                          }
                        },
                        userId:
                            invitedUserUid, // Передаем UID приглашенного пользователя
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
