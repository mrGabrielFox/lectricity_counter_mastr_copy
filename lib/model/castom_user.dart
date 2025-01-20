import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomUser with ChangeNotifier {
  final String uid;
  String name;
  String surname;
  String email;
  String phone;
  String status; // Арендодатель или Арендатор
  List<String>?
      favoritePropertyId; // Список избранных идентификаторов собственности

  CustomUser({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.status,
    this.favoritePropertyId,
  });

  // Обновленный метод для создания объекта CustomUser  из User
  factory CustomUser.fromFirebaseUser(
    User user, {
    required String name,
    required String surname,
    required String phone,
    required String status,
    String email = '',
    List<String>? favoritePropertyId,
  }) {
    return CustomUser(
      uid: user.uid,
      name: name,
      surname: surname,
      email: user.email ?? email,
      phone: phone,
      status: status,
      favoritePropertyId: favoritePropertyId,
    );
  }

  // Остальные методы остаются без изменений
  void update(CustomUser updatedUser) {
    name = updatedUser.name;
    surname = updatedUser.surname;
    email = updatedUser.email;
    phone = updatedUser.phone;
    status = updatedUser.status;
    favoritePropertyId = updatedUser.favoritePropertyId;

    notifyListeners(); // Уведомить слушателей об изменении
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'status': status,
      'favoritePropertyIds': favoritePropertyId ?? [],
    };
  }

  factory CustomUser.fromMap(Map<String, dynamic> map) {
    return CustomUser(
      uid: map['uid'],
      name: map['name'],
      surname: map['surname'],
      email: map['email'],
      phone: map['phone'],
      status: map['status'],
      favoritePropertyId: List<String>.from(map['favoritePropertyIds'] ?? []),
    );
  }

  void updateFavoritePropertyId(String propertyId) {
    favoritePropertyId ??= [];

    if (favoritePropertyId!.contains(propertyId)) {
      favoritePropertyId!.remove(propertyId);
    } else {
      favoritePropertyId!.add(propertyId);
    }

    notifyListeners();
  }

  void updateUserData({
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? status,
    List<String>? favoritePropertyId,
  }) {
    if (name != null) this.name = name;
    if (surname != null) this.surname = surname;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (status != null) this.status = status;
    if (favoritePropertyId != null) {
      this.favoritePropertyId = favoritePropertyId;
    }

    notifyListeners();
  }
}
