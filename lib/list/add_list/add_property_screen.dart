import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/model/property.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPropertyPopup extends StatefulWidget {
  final CustomUser user;
  final Function onPropertyAdded;

  const AddPropertyPopup(
      {super.key, required this.user, required this.onPropertyAdded});

  @override
  AddPropertyPopupState createState() => AddPropertyPopupState();
}

class AddPropertyPopupState extends State<AddPropertyPopup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();

  void _addProperty() async {
    String name = _nameController.text.trim();
    String city = _cityController.text.trim();
    String street = _streetController.text.trim();
    String house = _houseController.text.trim();
    String apartment = _apartmentController.text.trim();

    if (name.isEmpty ||
        city.isEmpty ||
        street.isEmpty ||
        house.isEmpty ||
        apartment.isEmpty) {
      _showErrorDialog('Пожалуйста, заполните все поля.');
      return;
    }

    // Проверка на допустимость значений
    if (!RegExp(r'^\d+$').hasMatch(house) ||
        !RegExp(r'^\d*$').hasMatch(apartment)) {
      _showErrorDialog('Номер дома и квартиры должны быть числом.');
      return;
    }

    try {
      // Создаем новый объект Property без id
      Property newProperty = Property(
        id: '', // Пустая строка, id будет установлен позже
        name: name,
        city: city,
        street: street,
        house: house,
        apartment: apartment,
      );

      // Добавляем новую недвижимость в Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('properties')
          .add(newProperty.toMap());

      // Обновляем id объекта на id созданного документа
      newProperty = newProperty.copyWith(id: docRef.id);

      // Опционально: можно сохранить обновленный объект обратно в Firestore
      await docRef.set(newProperty.toMap(), SetOptions(merge: true));

      // Вызываем коллбэк для обновления состояния
      widget.onPropertyAdded(newProperty.id);
      Navigator.pop(context); // Закрываем диалог
    } catch (e) {
      _showErrorDialog('Ошибка при добавлении недвижимости: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Добавить недвижимость'),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'Название недвижимости',
            ),
            SizedBox(height: 8.0),
            CupertinoTextField(
              controller: _cityController,
              placeholder: 'Город',
            ),
            SizedBox(height: 8.0),
            CupertinoTextField(
              controller: _streetController,
              placeholder: 'Улица',
            ),
            SizedBox(height: 8.0),
            CupertinoTextField(
              controller: _houseController,
              placeholder: 'Номер дома',
            ),
            SizedBox(height: 8.0),
            CupertinoTextField(
              controller: _apartmentController,
              placeholder: 'Номер квартиры',
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: _addProperty, // Вызываем метод без передачи контекста
          child: Text('Добавить'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Отмена'),
        ),
      ],
    );
  }
}
