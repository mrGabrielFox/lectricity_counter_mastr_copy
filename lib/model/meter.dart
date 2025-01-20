class Meter {
  final String id;
  final String type; //имя счетчика
  final int meterNumber; //серийный номер счетчика
  final double reading; //параметр счетчика
  final String
      measurement; //при создании счетчика должны выбрать из выпадающего меню: куб.м. или кВт*ч
  final double consumption; //новое показание счетчика
  final double tariff; //стоимость за 1 единицу счетчика
  final DateTime dateRecorded; //устанавливается дата 1 раз в ручную
  final DateTime
      lastCheck; //устанавливается автоматически при внесении новых показаний

  Meter({
    required this.id,
    required this.type,
    required this.meterNumber,
    required this.reading,
    required this.measurement,
    required this.consumption,
    required this.tariff,
    required this.dateRecorded,
    required this.lastCheck,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'meterNumber': meterNumber,
      'reading': reading,
      'measurement': measurement,
      'consumption': consumption,
      'tariff': tariff,
      'dateRecorded': dateRecorded,
      'lastCheck': lastCheck,
    };
  }
}
