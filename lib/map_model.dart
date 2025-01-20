class User {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String status; // Арендодатель или Арендатор

  User({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.status,
  });

  // Конвертировать модель данных в Map, чтобы сохранить в Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }

  // Создать объект User из Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      surname: map['surname'],
      email: map['email'],
      phone: map['phone'],
      status: map['status'],
    );
  }
}

class Property {
  final String id;
  final String name;
  final String city;
  final String street;
  final String house;
  final String apartment;
  final List<Meter> meters; // Список счетчиков для этой недвижимости

  Property({
    required this.id,
    required this.name,
    required this.city,
    required this.street,
    required this.house,
    required this.apartment,
    required this.meters,
  });

  // Конвертировать модель данных в Map, чтобы сохранить в Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'street': street,
      'house': house,
      'apartment': apartment,
      'meters': meters.map((meter) => meter.toMap()).toList(),
    };
  }

  // Создать объект Property из Map
  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      street: map['street'],
      house: map['house'],
      apartment: map['apartment'],
      meters: List<Meter>.from(map['meters'].map((x) => Meter.fromMap(x))),
    );
  }
}

class Meter {
  final String id;
  final String type; // Электричество, вода и т.д.
  final String meterNumber;
  final String reading;
  final String measurement;
  final String consumption;
  final String tariff;
  final DateTime dateRecorded;
  final DateTime lastCheck; // Дата последней поверки

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

  // Конвертировать модель данных в Map, чтобы сохранить в Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'meter_number': meterNumber,
      'reading': reading,
      'measurement': measurement,
      'consumption': consumption,
      'tariff': tariff,
      'date_recorded': dateRecorded.millisecondsSinceEpoch,
      'last_check': lastCheck.millisecondsSinceEpoch,
    };
  }

  // Создать объект Meter из Map
  factory Meter.fromMap(Map<String, dynamic> map) {
    return Meter(
      id: map['id'],
      type: map['type'],
      meterNumber: map['meter_number'],
      reading: map['reading'],
      measurement: map['measurement'],
      consumption: map['consumption'],
      tariff: map['tariff'],
      dateRecorded: DateTime.fromMillisecondsSinceEpoch(map['date_recorded']),
      lastCheck: DateTime.fromMillisecondsSinceEpoch(map['last_check']),
    );
  }
}
