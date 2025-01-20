// import 'package:electricity_counter/list/add_list/add_meter_pop.dart';
// import 'package:electricity_counter/list/add_list/add_property_screen.dart';
// import 'package:electricity_counter/list/add_list/meter_list.dart';
// import 'package:electricity_counter/model/background.dart';
// import 'package:electricity_counter/model/castom_user.dart';
// import 'package:electricity_counter/screens/example_menu_landlord.dart';
// import 'package:electricity_counter/services/theme_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'tenant_property_screen.dart';

// class PropertyScreen extends StatefulWidget {
//   final CustomUser user; // Используем CastomUser

//   const PropertyScreen({super.key, required this.user});

//   @override
//   PropertyScreenState createState() => PropertyScreenState();
// }

// class PropertyScreenState extends State<PropertyScreen> {
//   String? selectedPropertyId;
//   String? selectedPropertyName;

//   // Метод для отображения выбора недвижимости
//   void _showPropertySelection(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoActionSheet(
//           title: Text('Выберите недвижимость'),
//           actions: [
//             StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(widget.user.uid) // Используем uid из CastomUser
//                   .collection('properties')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CupertinoActionSheetAction(
//                     child: Text('Загрузка...'),
//                     onPressed: () {},
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return CupertinoActionSheetAction(
//                     child: Text('Ошибка: ${snapshot.error}'),
//                     onPressed: () {},
//                   );
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return CupertinoActionSheetAction(
//                     child: Text('Недвижимость отсутствует'),
//                     onPressed: () {},
//                   );
//                 }

//                 return Column(
//                   children: snapshot.data!.docs.map((doc) {
//                     Map<String, dynamic>? data =
//                         doc.data() as Map<String, dynamic>?;
//                     String name = data?['name'] ?? 'Без названия';

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedPropertyId = doc.id;
//                           selectedPropertyName = name;
//                         });
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 10.0),
//                         width: double.infinity,
//                         color: selectedPropertyId == doc.id
//                             ? CupertinoColors.systemGrey.withOpacity(0.3)
//                             : CupertinoColors.transparent,
//                         child: Center(child: Text(name)),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//             CupertinoActionSheetAction(
//               child: Text('Добавить недвижимость'),
//               onPressed: () {
//                 Navigator.pop(context);
//                 _showAddPropertyPopup(context);
//               },
//             ),
//           ],
//           cancelButton: CupertinoActionSheetAction(
//             child: Text('Отмена'),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         );
//       },
//     );
//   }

//   // Метод для открытия попапа добавления недвижимости
//   void _showAddPropertyPopup(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (context) {
//         return AddPropertyPopup(
//           user: widget.user, // Передаем CastomUser
//           onPropertyAdded: () {
//             setState(() {
//               selectedPropertyId = null;
//               selectedPropertyName = null;
//             });
//           },
//         );
//       },
//     );
//   }

//   // Метод для добавления счетчика
//   void _addMeter() {
//     if (selectedPropertyId != null) {
//       showCupertinoModalPopup(
//         context: context,
//         builder: (context) {
//           return AddMeterPopup(
//             propertyId: selectedPropertyId!,
//             userId: widget.user.uid, // Используем uid из CastomUser
//           );
//         },
//       );
//     } else {
//       showCupertinoDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return CupertinoAlertDialog(
//             title: Text('Ошибка'),
//             content: Text('Сначала выберите недвижимость.'),
//             actions: [
//               CupertinoDialogAction(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   // Метод для приглашения арендатора
//   void _inviteTenant() {
//     if (selectedPropertyId != null) {
//       showCupertinoDialog(
//         context: context,
//         builder: (BuildContext context) {
//           final TextEditingController tenantUidController =
//               TextEditingController();
//           return CupertinoAlertDialog(
//             title: Text('Пригласить арендатора'),
//             content: CupertinoTextField(
//               controller: tenantUidController,
//               placeholder: 'Введите UID арендатора',
//             ),
//             actions: [
//               CupertinoDialogAction(
//                 child: Text('Пригласить'),
//                 onPressed: () async {
//                   final tenantUid = tenantUidController.text;
//                   await inviteTenant(selectedPropertyId!, tenantUid);
//                   // ignore: use_build_context_synchronously
//                   Navigator.pop(context);
//                 },
//               ),
//               CupertinoDialogAction(
//                 child: Text('Отмена'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   // Метод для отправки приглашения арендатора
//   Future<void> inviteTenant(String propertyId, String tenantUid) async {
//     try {
//       DocumentReference propertyRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.user.uid) // uid арендодателя
//           .collection('properties')
//           .doc(propertyId);

//       await propertyRef.update({
//         'invitedTenants': FieldValue.arrayUnion([tenantUid]),
//       });

//       // Отправка уведомления (если используется FCM)
//       // await sendNotification(tenantUid, propertyId);
//     } catch (e) {
//       if (kDebugMode) {
//         print("Ошибка при отправке приглашения: $e");
//       }
//     }
//   }

//   // Метод для навигации к экрану арендаторов
//   void _navigateToTenantProperties() {
//     Navigator.push(
//       context,
//       CupertinoPageRoute(
//         builder: (context) =>
//             TenantPropertyScreen(user: widget.user), // Передаем CastomUser
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     return CupertinoPageScaffold(
//       child: Background(
//         isDarkTheme: themeProvider.isDarkTheme,
//         child: Column(
//           children: [
//             CupertinoNavigationBar(
//               leading: selectedPropertyId != null
//                   ? CupertinoButton(
//                       padding: EdgeInsets.zero,
//                       onPressed: () => _addMeter,
//                       child: Icon(CupertinoIcons.add),
//                     )
//                   : Container(),
//               middle: Text(selectedPropertyName ?? 'Недвижимость'),
//               trailing: ExampleMenuLandlord(
//                 user: widget.user, // Передаем CastomUser
//                 showAddPropertyPopup: _showAddPropertyPopup,
//                 addMeter: _addMeter,
//                 toggleTheme: (bool value) => themeProvider.toggleTheme(value),
//                 isDarkTheme: themeProvider.isDarkTheme,
//                 inviteTenant: _inviteTenant, // Передаем метод для приглашения
//                 // navigateToTenantProperties:
//                 //     _navigateToTenantProperties, // Передаем метод для навигации
//                 builder: (_, showMenu) => CupertinoButton(
//                   padding: EdgeInsets.zero,
//                   onPressed: showMenu,
//                   child: Icon(CupertinoIcons.ellipsis),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: selectedPropertyId == null
//                   ? Center(child: Text('Пожалуйста, выберите недвижимость.'))
//                   : MeterList(
//                       firestore: FirebaseFirestore.instance,
//                       selectedMeters: [],
//                       onSelect: (String meterId) {
//                         // Обработчик выбора счетчика
//                       },
//                       propertyId: selectedPropertyId!,
//                       userId: widget.user.uid, // Используем uid из CastomUser
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
