import 'dart:ui';
import 'package:electricity_counter_mastr_copy/model/background.dart';
import 'package:electricity_counter_mastr_copy/model/castom_user.dart';
import 'package:electricity_counter_mastr_copy/screens/card_screen.dart';
import 'package:electricity_counter_mastr_copy/services/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserSettingsScreen extends StatefulWidget {
  final CustomUser user;

  const UserSettingsScreen({super.key, required this.user});

  @override
  UserSettingsScreenState createState() =>
      UserSettingsScreenState(); // Изменено
}

class UserSettingsScreenState extends State<UserSettingsScreen> {
  // Изменено
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;
  late TextEditingController _statusController;

  bool _isEditingName = false;
  bool _isEditingSurname = false;
  bool _isEditingPhone = false;
  bool _isEditingStatus = false;

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _phoneController = TextEditingController(text: widget.user.phone);
    _statusController = TextEditingController(text: widget.user.status);
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Проверка на смонтированность
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _updateUserData(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'surname': _surnameController.text,
        'phone': _phoneController.text,
        'status': _statusController.text,
      });
      if (mounted) {
        // Проверка на смонтированность
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Данные обновлены')));
      }
    } catch (e) {
      if (mounted) {
        // Проверка на смонтированность
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка обновления данных')));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Код для загрузки изображения в Firestore или Firebase Storage
    }
  }

  Widget _buildEditableRow(
    String label,
    TextEditingController controller,
    bool isEditing,
    Function onEditToggle, {
    double labelWidth = 100.0,
    double textFieldWidth = 200.0,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        if (isEditing)
          SizedBox(
            width: textFieldWidth,
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Введите $label',
              textAlign: TextAlign.left,
            ),
          )
        else
          SizedBox(
            // Заменено на SizedBox
            width: textFieldWidth,
            child: Text(
              controller.text,
              textAlign: textAlign,
            ),
          ),
        IconButton(
          icon: isEditing
              ? Icon(CupertinoIcons.check_mark)
              : Icon(CupertinoIcons.pen),
          onPressed: () {
            if (isEditing) {
              _updateUserData(widget.user.uid);
              onEditToggle();
            } else {
              onEditToggle();
            }
          },
        ),
        if (isEditing)
          IconButton(
            icon: Icon(CupertinoIcons.clear),
            onPressed: () {
              controller.text = '';
              onEditToggle();
            },
          ),
      ],
    );
  }

  Widget _buildThemeButton(
      String assetPath, bool isDarkTheme, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme(isDarkTheme);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isDarkTheme == themeProvider.isDarkTheme
              ? Border.all(color: Colors.purple, width: 2)
              : null,
        ),
        padding: EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return CupertinoPageScaffold(
      child: Background(
        isDarkTheme: themeProvider.isDarkTheme,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Пользователь не найден'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            _nameController.text = userData['name'] ?? '';
            _surnameController.text = userData['surname'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _statusController.text = userData['status'] ?? '';

            return Column(
              children: [
                CupertinoNavigationBar(
                  middle: Text('Настройки пользователя'),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _signOut,
                    child: Icon(Icons.exit_to_app),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Color.fromARGB((0.8 * 255).toInt(), 255, 255, 255),
                      // Изменено
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (userData['profileImageUrl'] != null &&
                                              userData['profileImageUrl']
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                              userData['profileImageUrl'])
                                          : AssetImage(
                                                  'assets/default_avatar.png')
                                              as ImageProvider,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildEditableRow(
                                  'Имя', _nameController, _isEditingName, () {
                                setState(() {
                                  _isEditingName = !_isEditingName;
                                });
                              }),
                              SizedBox(height: 10),
                              _buildEditableRow('Фамилия', _surnameController,
                                  _isEditingSurname, () {
                                setState(() {
                                  _isEditingSurname = !_isEditingSurname;
                                });
                              }),
                              SizedBox(height: 10),
                              _buildEditableRow(
                                  'Email',
                                  TextEditingController(
                                      text: userData['email']),
                                  false,
                                  () {}),
                              SizedBox(height: 10),
                              _buildEditableRow(
                                  'Телефон', _phoneController, _isEditingPhone,
                                  () {
                                setState(() {
                                  _isEditingPhone = !_isEditingPhone;
                                });
                              }),
                              SizedBox(height: 10),
                              _buildEditableRow(
                                  'Статус', _statusController, _isEditingStatus,
                                  () {
                                setState(() {
                                  _isEditingStatus = !_isEditingStatus;
                                });
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                CupertinoButton(
                  child: Text('Открыть карточку'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => CardScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Выбор темы:',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildThemeButton(
                        'assets/icons/light_button2.png', false, context),
                    _buildThemeButton(
                        'assets/icons/dark_button2.png', true, context),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
