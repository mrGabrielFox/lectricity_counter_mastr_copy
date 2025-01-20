import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация пользователя
  Future<User?> registerUser(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Вход пользователя
  Future<User?> loginUser(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Добавление недвижимости
  Future<void> addProperty(
      String userId, Map<String, dynamic> propertyData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('properties')
        .add({
      'ownerId': userId,
      ...propertyData,
    });
  }

  // Получение списка недвижимости
  Stream<List<Map<String, dynamic>>> getProperties(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('properties')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Получение списка недвижимости для приглашенного пользователя
  Stream<List<Map<String, dynamic>>> getInvitedProperties(
      String invitedUserId) {
    return _firestore
        .collection('properties')
        .where('invitedTenants', arrayContains: invitedUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Добавление счетчика
  Future<void> addMeter(
      String userId, String propertyId, Map<String, dynamic> meterData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('properties')
        .doc(propertyId)
        .collection('meters')
        .add({
      'propertyId': propertyId,
      ...meterData,
    });
  }

  // Получение списка счетчиков
  Stream<List<Map<String, dynamic>>> getMeters(
      String userId, String propertyId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('properties')
        .doc(propertyId)
        .collection('meters')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
