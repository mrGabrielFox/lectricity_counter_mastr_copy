import 'package:electricity_counter_mastr_copy/list/add_list/meter_list_tenant.dart';
import 'package:electricity_counter_mastr_copy/model/background.dart';
import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/example_menu_tenant.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class HomePageTenant extends StatefulWidget {
  final CustomUser user;
  final String? favoritePropertyId;

  const HomePageTenant(
      {super.key, required this.user, this.favoritePropertyId});

  @override
  HomePageTenantState createState() => HomePageTenantState();
}

class HomePageTenantState extends State<HomePageTenant> {
  String? selectedPropertyId;
  String? selectedPropertyName;
  List<String> selectedMeters = []; // Список выбранных счетчиков
  bool isLoading = true; // Переменная состояния загрузки

  @override
  void initState() {
    super.initState();
    _loadLandlordAndMeters(); // Новый метод для загрузки данных
  }

  Future<void> _loadLandlordAndMeters() async {
    try {
      // Получаем ссылку на документ арендатора в Firestore
      DocumentReference tenantRef =
          FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

      // Извлекаем документ арендатора
      DocumentSnapshot tenantDoc = await tenantRef.get();

      // Проверяем, существует ли документ арендатора
      if (tenantDoc.exists) {
        // Извлекаем данные из документа и приводим их к типу Map
        final data = tenantDoc.data() as Map<String, dynamic>?;

        // Проверяем наличие данных
        if (data != null) {
          if (kDebugMode) {
            print("Данные пользователя: $data");
          } // Отладочное сообщение, выводим данные пользователя

          // Обработка invitedTenants
          List<dynamic> invitedTenants = data['invitedTenants'] ??
              []; // Получаем список приглашенных арендаторов или пустой список, если null

          // Проходим по каждому приглашенному арендатору
          for (var tenant in invitedTenants) {
            // Проверяем, что landlordUid и propertyId не равны null
            if (tenant['landlordUid'] != null && tenant['propertyId'] != null) {
              String landlordUid =
                  tenant['landlordUid']; // Получаем идентификатор арендодателя
              String propertyId =
                  tenant['propertyId']; // Получаем идентификатор собственности

              // Загружаем имя собственности и список счетчиков для данной собственности
              await _selectPropertyName(propertyId, landlordUid);
              await _loadMetrList(propertyId, landlordUid);

              // Обновляем состояние, устанавливая выбранное свойство
              setState(() {
                selectedPropertyId =
                    propertyId; // Устанавливаем выбранное свойство
                if (kDebugMode) {
                  print("Выбрано свойство с ID: $propertyId");
                } // Отладочное сообщение о выбранном свойстве
              });
            }
          }

          // Если у нас нет выбранного свойства, выводим сообщение
          if (selectedPropertyId == null) {
            if (kDebugMode) {
              print("Нет доступных свойств для выбора.");
            }
          }
        } else {
          if (kDebugMode) {
            print("Данные документа равны null.");
          } // Сообщение, если данные пустые
        }
      } else {
        if (kDebugMode) {
          print("Документ арендатора не существует.");
        } // Сообщение, если документ не найден
      }
    } catch (e) {
      // Обработка ошибок при выполнении функции
      if (kDebugMode) {
        print(
            "Ошибка при загрузке данных арендатора: $e"); // Выводим сообщение об ошибке в режиме отладки
      }
    } finally {
      setState(() {
        isLoading = false; // Устанавливаем состояние загрузки в false
      });
      if (kDebugMode) {
        print("Загрузка данных завершена.");
      } // Отладочное сообщение о завершении загрузки
    }
  }

  Future<void> _selectPropertyName(
      String propertyId, String landlordUid) async {
    // Проверяем, что идентификатор собственности не пустой
    if (propertyId.isNotEmpty) {
      try {
        // Получаем документ собственности из Firestore
        DocumentSnapshot propertyDoc = await FirebaseFirestore.instance
            .collection('users') // Доступ к коллекции пользователей
            .doc(
                landlordUid) // Используем uid арендодателя для доступа к его документу
            .collection(
                'properties') // Доступ к коллекции свойств данного арендодателя
            .doc(
                propertyId) // Используем идентификатор собственности для доступа к конкретному документу
            .get(); // Получаем документ

        // Проверяем, существует ли документ собственности
        if (propertyDoc.exists) {
          // Если документ существует, обновляем состояние с именем собственности
          setState(() {
            selectedPropertyName =
                propertyDoc['name']; // Извлекаем имя собственности из документа
          });
        }
      } catch (e) {
        // Обрабатываем возможные ошибки при получении документа
        if (kDebugMode) {
          print(
              "Ошибка при получении имени собственности: $e"); // Выводим сообщение об ошибке в режиме отладки
        }
      }
    }
  }

  Future<void> _loadMetrList(String propertyId, String landlordUid) async {
    try {
      // Получаем список счетчиков для данной собственности
      QuerySnapshot meterSnapshot = await FirebaseFirestore.instance
          .collection('users') // Начинаем с коллекции 'users'
          .doc(landlordUid) // Получаем документ пользователя по UID
          .collection(
              'properties') // Переходим к коллекции 'properties' для данного пользователя
          .doc(propertyId) // Получаем документ собственности по ID
          .collection(
              'meters') // Предполагаем, что счетчики хранятся в подколлекции 'meters'
          .get(); // Выполняем запрос для получения данных

      // Обработка полученных данных
      if (meterSnapshot.docs.isNotEmpty) {
        setState(() {
          // Если счетчики найдены, обновляем состояние приложения
          selectedMeters = meterSnapshot.docs.map((doc) => doc.id).toList();
          // Здесь вы можете сохранить список идентификаторов счетчиков или их данные
        });
      } else {
        // Если счетчики не найдены, выводим сообщение в режиме отладки
        if (kDebugMode) {
          print("Счетчики не найдены для данной собственности.");
        }
      }
    } catch (e) {
      // Обработка ошибок, если что-то пошло не так при запросе данных
      if (kDebugMode) {
        print("Ошибка при загрузке списка счетчиков: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем доступ к провайдеру темы, чтобы определить текущую тему приложения
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      child: Background(
        isDarkTheme: themeProvider
            .isDarkTheme, // Передаем информацию о теме в виджет Background
        child: Column(
          children: [
            // Навигационная панель с кнопкой выбора собственности
            CupertinoNavigationBar(
              leading: CupertinoButton(
                padding: EdgeInsets.zero, // Убираем отступы у кнопки
                onPressed: () {
                  // Здесь можно добавить логику для выбора собственности
                },
                child: Row(
                  children: [
                    // Текст с названием выбранной собственности или сообщение о необходимости выбора
                    Text(selectedPropertyName ?? ''),
                    Icon(CupertinoIcons.chevron_down,
                        size: 16), // Иконка стрелки вниз
                  ],
                ),
              ),
              middle: Text('Собственности'), // Заголовок навигационной панели
              trailing: ExampleMenuTenant(
                user: widget.user, // Передаем информацию о пользователе в меню
                toggleTheme: (bool value) => themeProvider
                    .toggleTheme(value), // Функция для переключения темы
                isDarkTheme: themeProvider.isDarkTheme, // Текущая тема
                builder: (_, showMenu) => CupertinoButton(
                  padding: EdgeInsets.zero, // Убираем отступы у кнопки
                  onPressed: showMenu, // Вызываем меню при нажатии на кнопку
                  child: Icon(CupertinoIcons.ellipsis), // Иконка для меню
                ),
              ),
            ),
            Expanded(
              child: isLoading // Проверяем, загружаются ли данные
                  ? Center(
                      child: CupertinoActivityIndicator(), // Индикатор загрузки
                    )
                  : MeterListTenant(
                      landlordUid: widget.user.uid, // Передаем UID владельца
                      propertyId:
                          selectedPropertyId!, // Передаем ID выбранной собственности
                      selectedMeters:
                          selectedMeters, // Передаем список счетчиков
                      onSelect: (String meterId) {
                        // Обработка выбора счетчика
                        if (kDebugMode) {
                          debugPrintStack(
                              label:
                                  "Выбран счетчик: $meterId"); // Логируем ID выбранного счетчика
                          debugPrintStack(
                              label:
                                  "UID владельца: ${widget.user.uid}"); // Логируем UID владельца
                          debugPrintStack(
                              label:
                                  "ID выбранной собственности: $selectedPropertyId"); // Логируем ID собственности
                          debugPrintStack(
                              label:
                                  "Список выбранных счетчиков: $selectedMeters"); // Логируем список выбранных счетчиков
                        }
                      },
                      firestore: FirebaseFirestore
                          .instance, // Передаем экземпляр Firestore
                      userId: widget.user.uid, // Передаем ID пользователя
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
