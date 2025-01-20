import 'dart:ui';
import 'package:electricity_counter_mastr_copy/list/add_list/add_meter_pop.dart';
import 'package:electricity_counter_mastr_copy/list/add_list/add_property_screen.dart';
import 'package:electricity_counter_mastr_copy/list/add_list/meter_list.dart';
import 'package:electricity_counter_mastr_copy/model/background.dart';
import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/example_menu_landlord.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageLandlord extends StatefulWidget {
  final CustomUser user;
  final String? favoritePropertyId;

  const HomePageLandlord(
      {super.key, required this.user, this.favoritePropertyId});

  @override
  HomePageLandlordState createState() => HomePageLandlordState();
}

class HomePageLandlordState extends State<HomePageLandlord> {
  String? selectedPropertyId;
  String? selectedPropertyName;
  bool isLoading = true; // Переменная состояния загрузки

  @override
  void initState() {
    super.initState(); // Вызов метода initState родительского класса

    // Инициализация selectedPropertyId с идентификатором любимой собственности
    selectedPropertyId = widget.favoritePropertyId;

    // Получение имени собственности по заданному идентификатору
    _selectPropertyName();

    // Загрузка счетчиков для первой собственности (или другой логики)
    _selectFirstProperty();
  }

  void _selectPropertyName() async {
    // Проверка, установлен ли идентификатор выбранной собственности
    if (selectedPropertyId != null) {
      try {
        // Асинхронный запрос к Firestore для получения документа собственности
        DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
            .collection('users') // Коллекция пользователей
            .doc(widget.user.uid) // Документ текущего пользователя
            .collection('properties') // Коллекция свойств пользователя
            .doc(
                selectedPropertyId) // Документ выбранной собственности по идентификатору
            .get(); // Выполнение запроса на получение документа

        // Проверка, существует ли полученный документ
        if (propertyDoc.exists) {
          // Обновление состояния с именем собственности, если документ существует
          setState(() {
            selectedPropertyName =
                propertyDoc['name']; // Извлечение имени из документа
          });
        }
      } catch (e) {
        // Обработка ошибок, если возникли проблемы с получением документа
        if (kDebugMode) {
          print(
              "Ошибка при получении имени собственности: $e"); // Вывод сообщения об ошибке в режиме отладки
        }
      }
    }
  }

  void _selectFirstProperty() async {
    // Проверка, выбран ли идентификатор собственности
    if (selectedPropertyId != null) {
      try {
        // Получение документа собственности из Firestore по идентификатору пользователя и идентификатору собственности
        DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
            .collection('users') // Коллекция пользователей
            .doc(widget.user.uid) // Документ пользователя
            .collection('properties') // Коллекция свойств пользователя
            .doc(selectedPropertyId) // Документ выбранной собственности
            .get(); // Запрос на получение документа

        // Проверка, существует ли документ собственности
        if (propertyDoc.exists) {
          // Обновление состояния с названием собственности, если документ существует
          setState(() {
            selectedPropertyName = propertyDoc[
                'name']; // Получение имени собственности из документа
          });
        }
      } catch (e) {
        // Обработка ошибок, если возникли проблемы с получением документа
        if (kDebugMode) {
          print(
              "Error fetching property: $e"); // Вывод сообщения об ошибке в режиме отладки
        }
      } finally {
        // Блок finally выполняется в любом случае, независимо от результата
        setState(() {
          isLoading =
              false; // Установка состояния загрузки в false после завершения операции
        });
      }
    }
  }

  void _addMeter() {
    // Проверка, выбран ли идентификатор собственности
    if (selectedPropertyId != null) {
      // Открытие модального окна для добавления счетчика, если собственность выбрана
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return AddMeterPopup(
            propertyId:
                selectedPropertyId!, // Передача идентификатора собственности
            userId: widget.user.uid, // Передача идентификатора пользователя
          );
        },
      );
    } else {
      // Если идентификатор собственности не выбран, отображение диалогового окна с ошибкой
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Ошибка'), // Заголовок диалогового окна
            content:
                Text('Сначала выберите недвижимость.'), // Сообщение об ошибке
            actions: [
              CupertinoDialogAction(
                child: Text('OK'), // Кнопка для закрытия диалогового окна
                onPressed: () {
                  Navigator.pop(context); // Закрытие диалогового окна
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showPropertySelection(BuildContext context) {
    // Отображение модального окна с выбором собственности
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Начальный размер модального окна
          minChildSize: 0.3, // Минимальный размер модального окна
          maxChildSize: 0.8, // Максимальный размер модального окна
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.0)), // Закругленные верхние углы
                border: Border.all(
                    color: Color.fromARGB(128, 179, 179, 179),
                    width: 1.0), // Граница контейнера
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(51, 0, 0, 0), // Цвет тени
                    blurRadius: 10.0, // Размытие тени
                    offset: Offset(0, -2), // Смещение тени
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 10.0, sigmaY: 10.0), // Эффект размытия фона
                  child: Container(
                    color: Colors.transparent, // Прозрачный цвет фона
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Минимальный размер колонки
                      children: <Widget>[
                        // Хэндлер для свайпа
                        Container(
                          height: 5,
                          width: 40,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                                128, 179, 179, 179), // Цвет хэндлера
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Выберите собственность', // Заголовок
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(CupertinoIcons.clear,
                                    color: Colors.black), // Кнопка закрытия
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Закрытие модального окна
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            // Подключаемся к потоку данных Firestore
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.uid)
                                .collection('properties')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child:
                                        CupertinoActivityIndicator()); // Индикатор загрузки
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Ошибка: ${snapshot.error}')); // Обработка ошибок
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                    child: Text(
                                        'Нет доступных свойств')); // Нет данных
                              }

                              return ListView(
                                controller:
                                    scrollController, // Прокрутка для DraggableScrollableSheet
                                children: snapshot.data!.docs.map((doc) {
                                  Map<String, dynamic>? data = doc.data() as Map<
                                      String,
                                      dynamic>?; // Получение данных документа
                                  String name = data?['name'] ??
                                      'Unnamed'; // Название собственности

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPropertyId =
                                            doc.id; // Сохранение выбранного ID
                                        selectedPropertyName =
                                            name; // Сохранение выбранного имени

                                        // Обновление favoritePropertyId в CustomUser
                                        context
                                                .read<CustomUser>()
                                                .favoritePropertyId =
                                            doc.id as List<String>?;

                                        // Обновление Firestore
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.user.uid)
                                            .update({
                                          'favoritePropertyIds': context
                                              .read<CustomUser>()
                                              .favoritePropertyId
                                        });
                                      });
                                      Navigator.pop(
                                          context); // Закрытие модального окна после выбора
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      color: selectedPropertyId == doc.id
                                          ? Color.fromRGBO(169, 169, 169,
                                              0.3) // Выделение выбранного элемента
                                          : Colors.transparent,
                                      child: Center(
                                          child: Text(
                                              name)), // Отображение имени собственности
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPropertyPopup(BuildContext context) {
    // Отображение модального окна для добавления собственности
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AddPropertyPopup(
          user: widget.user, // Передача текущего пользователя в модальное окно
          onPropertyAdded: (String propertyId) async {
            // Обработчик, вызываемый при добавлении собственности

            // Обновление поля favoritePropertyId в коллекции users
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user.uid)
                .update({'favoritePropertyId': propertyId});

            setState(() {
              // Установка выбранного идентификатора собственности
              selectedPropertyId = propertyId;
              // Установка имени собственности
              selectedPropertyName =
                  propertyId; // Здесь вы можете получить имя собственности, если это необходимо
            });

            _selectFirstProperty(); // Обновление списка свойств
          },
        );
      },
    );
  }

  void _inviteTenant() {
    // Проверка, выбран ли идентификатор собственности
    if (selectedPropertyId != null) {
      // Открытие диалогового окна для приглашения арендатора
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          // Создание контроллера для текстового поля ввода UID арендатора
          final TextEditingController tenantUidController =
              TextEditingController();

          return CupertinoAlertDialog(
            title: Text('Invite Tenant'), // Заголовок диалогового окна
            content: CupertinoTextField(
              controller:
                  tenantUidController, // Привязка контроллера к текстовому полю
              placeholder:
                  'Enter tenant UID', // Подсказка для ввода UID арендатора
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Invite'), // Кнопка для отправки приглашения
                onPressed: () async {
                  // Получение введенного UID арендатора
                  final tenantUid = tenantUidController.text;

                  // Вызов метода для приглашения арендатора к собственности
                  await _inviteTenantToProperty(selectedPropertyId!, tenantUid);

                  // Закрытие диалогового окна после отправки приглашения
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('Cancel'), // Кнопка для отмены
                onPressed: () {
                  // Закрытие диалогового окна при нажатии на "Cancel"
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _inviteTenantToProperty(
      String propertyId, String tenantUid) async {
    try {
      // Ссылка на документ арендатора
      DocumentReference tenantRef =
          FirebaseFirestore.instance.collection('users').doc(tenantUid);

      // Создаем объект для хранения информации о приглашении
      Map<String, String> invitationData = {
        'landlordUid': widget.user.uid, // UID арендодателя
        'propertyId': propertyId, // ID недвижимости
      };

      // Обновляем массив invitedTenants у арендатора
      await tenantRef.update({
        'invitedTenants': FieldValue.arrayUnion([invitationData]),
        'favoritePropertyIds': FieldValue.arrayUnion(
            [propertyId]), // Добавляем propertyId в favoritePropertyIds
      });

      // Дополнительно можно обновить массив invitedTenants у арендодателя, если это необходимо
      DocumentReference propertyRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('properties')
          .doc(propertyId);

      await propertyRef.update({
        'invitedTenants': FieldValue.arrayUnion([tenantUid]),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Ошибка при отправке приглашения: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получение текущего состояния темы из провайдера
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      child: Background(
        isDarkTheme:
            themeProvider.isDarkTheme, // Передача состояния темы в Background
        child: Column(
          children: [
            // Навигационная панель с возможностью выбора собственности
            CupertinoNavigationBar(
              leading: CupertinoButton(
                padding: EdgeInsets.zero, // Убираем отступы
                onPressed: () {
                  _showPropertySelection(
                      context); // Вызываем метод выбора собственности
                },
                child: Row(
                  children: [
                    // Отображение имени выбранной собственности или текст по умолчанию
                    Text(selectedPropertyName ?? 'Select Property'),
                    Icon(CupertinoIcons.chevron_down,
                        size: 16), // Иконка стрелки вниз
                  ],
                ),
              ),
              middle: Text('Properties'), // Заголовок навигационной панели
              trailing: ExampleMenuLandlord(
                user: widget.user, // Передаем текущего пользователя
                showAddPropertyPopup:
                    _showAddPropertyPopup, // Метод для показа попапа добавления собственности
                addMeter: _addMeter, // Метод для добавления счетчика
                toggleTheme: (bool value) => themeProvider
                    .toggleTheme(value), // Метод для переключения темы
                isDarkTheme: themeProvider.isDarkTheme, // Состояние темы
                inviteTenant: _inviteTenant, // Метод для приглашения арендатора
                builder: (_, showMenu) => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: showMenu, // Вызов меню при нажатии
                  child: Icon(CupertinoIcons.ellipsis), // Иконка для меню
                ),
              ),
            ),
            Expanded(
              child: //isLoading // Проверка состояния загрузки
                  //     ? Center(
                  //         child: CupertinoActivityIndicator(), // Индикатор загрузки
                  //       )
                  selectedPropertyId ==
                          null // Проверка, выбрана ли собственность
                      ? Center(
                          child: Text(
                              'Please select a property.')) // Сообщение, если собственность не выбрана
                      : MeterList(
                          firestore: FirebaseFirestore
                              .instance, // Передача экземпляра Firestore
                          selectedMeters: [], // Список выбранных счетчиков
                          onSelect: (String meterId) {
                            // Обработка выбора счетчика
                          },
                          propertyId:
                              selectedPropertyId!, // Идентификатор выбранной собственности
                          userId: widget.user.uid, // Идентификатор пользователя
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
