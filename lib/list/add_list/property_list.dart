import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyList extends StatelessWidget {
  final User user;

  const PropertyList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('properties')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Недвижимость отсутствует'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

            String name = data?['name'] ?? 'Без названия';

            return GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: CupertinoColors.systemGrey)),
                ),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
