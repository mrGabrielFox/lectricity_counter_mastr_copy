import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MeterList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final List<String> selectedMeters;
  final Function(String) onSelect;
  final String propertyId;
  final String userId;

  const MeterList({
    super.key,
    required this.firestore,
    required this.selectedMeters,
    required this.onSelect,
    required this.propertyId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('users')
          .doc(userId)
          .collection('properties')
          .doc(propertyId)
          .collection('meters')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Счётчики отсутствуют'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildMeterCard(context, data, doc.id);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMeterCard(
      BuildContext context, Map<String, dynamic> data, String docId) {
    String dateRecorded = data['dateRecorded'] != null
        ? DateFormat('dd.MM.yyyy HH:mm')
            .format((data['dateRecorded'] as Timestamp).toDate())
        : 'Не указано';

    String lastCheck = data['lastCheck'] != null
        ? DateFormat('dd.MM.yyyy HH:mm')
            .format((data['lastCheck'] as Timestamp).toDate())
        : 'Не указано';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.tertiaryLabel,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data['type'] ?? 'Не указан'} (Номер: ${data['meterNumber'] ?? 'Не указан'})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Показание: ${data['reading']?.toString() ?? 'Не указано'}'),
              Text('Измерение: ${data['measurement'] ?? 'Не указано'}'),
              Text('Дата записи: $dateRecorded'),
              Text('Последняя проверка: $lastCheck'),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: PullDownButton(
              itemBuilder: (context) => [
                const PullDownMenuDivider.large(),
                PullDownMenuActionsRow.medium(
                  items: [
                    PullDownMenuItem(
                      onTap: () => _showInfoDialog(context, docId),
                      title: 'Info',
                      icon: CupertinoIcons.info_circle,
                    ),
                    PullDownMenuItem(
                      onTap: () => _showInputDialog(
                          context, docId, data['reading'] ?? 0),
                      title: 'Edit',
                      icon: CupertinoIcons.pencil,
                    ),
                    PullDownMenuItem(
                      onTap: () => _deleteMeter(context, docId),
                      title: 'Delete',
                      isDestructive: true,
                      icon: CupertinoIcons.delete_simple,
                    ),
                  ],
                ),
              ],
              buttonBuilder: (context, showMenu) => CupertinoButton(
                onPressed: showMenu,
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.ellipsis_circle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(
      BuildContext context, String docId, double currentReading) {
    final TextEditingController readingController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Внести показания'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: readingController,
              placeholder: 'Новое показание',
              keyboardType: TextInputType.number,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                double newReading =
                    double.tryParse(readingController.text) ?? 0;
                if (newReading > 0) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('properties')
                      .doc(propertyId)
                      .collection('meters')
                      .doc(docId)
                      .update({
                    'reading': currentReading + newReading,
                    'lastCheck': DateTime.now(),
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text('Применить'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String meterId) async {
    try {
      DocumentSnapshot meterDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('properties')
          .doc(propertyId)
          .collection('meters')
          .doc(meterId)
          .get();

      final meterData = meterDoc.data() as Map<String, dynamic>?;

      if (meterData != null) {
        String dateRecorded = meterData['dateRecorded'] != null
            ? DateFormat('dd.MM.yyyy HH:mm')
                .format((meterData['dateRecorded'] as Timestamp).toDate())
            : 'Не указано';

        String lastCheck = meterData['lastCheck'] != null
            ? DateFormat('dd.MM.yyyy HH:mm')
                .format((meterData['lastCheck'] as Timestamp).toDate())
            : 'Не указано';

        // Проверяем, смонтирован ли виджет перед показом диалога
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Информация о счетчике'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Тип: ${meterData['type'] ?? 'Не указано'}'),
                    Text('Номер: ${meterData['meterNumber'] ?? 'Не указано'}'),
                    Text(
                        'Показание: ${meterData['reading']?.toString() ?? 'Не указано'}'),
                    Text(
                        'Тариф: ${meterData['tariff']?.toString() ?? 'Не указано'}'),
                    Text(
                        'Измерение: ${meterData['measurement'] ?? 'Не указано'}'),
                    Text(
                        'Потребление: ${meterData['consumption']?.toString() ?? 'Не указано'}'),
                    Text('Дата записи: $dateRecorded'),
                    Text('Последняя проверка: $lastCheck'),
                  ],
                ),
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
      }
    } catch (e) {
      debugPrint("Ошибка при получении данных: $e");
    }
  }

  void _deleteMeter(BuildContext context, String meterId) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Удалить счетчик'),
          content: Text('Вы уверены, что хотите удалить этот счетчик?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Закрытие диалога
              },
              child: Text('Отмена'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                try {
                  await firestore
                      .collection('users')
                      .doc(userId)
                      .collection('properties')
                      .doc(propertyId)
                      .collection('meters')
                      .doc(meterId)
                      .delete();

                  if (context.mounted) {
                    Navigator.of(context)
                        .pop(); // Закрытие диалога сразу после удаления
                    _showSuccessNotification(
                        context, 'Счетчик успешно удалён.');
                  }
                } catch (e) {
                  // Используйте логирование вместо print
                  debugPrint("Ошибка при удалении счетчика: $e");
                }
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.activeGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }
}
