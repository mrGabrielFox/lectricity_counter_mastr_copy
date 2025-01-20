// import 'package:flutter/material.dart';

// class MeterCard extends StatelessWidget {
//   final String meterType;
//   final String meterNumber;
//   final double currentValue; // Текущее значение счетчика
//   final DateTime lastUpdated; // Дата последнего обновления

//   MeterCard({
//     required this.meterType,
//     required this.meterNumber,
//     required this.currentValue,
//     required this.lastUpdated,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4.0,
//       margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '$meterType (Номер: $meterNumber)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Текущее значение: $currentValue',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 4.0),
//             Text(
//               'Последнее обновление: ${lastUpdated.toLocal().toString().split(' ')[0]}', // Форматируем дату
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
