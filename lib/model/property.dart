import 'package:electricity_counter_mastr_copy/map_model.dart';

class Property {
  final String id;
  final String name;
  final String city;
  final String street;
  final String house;
  final String apartment;
  final List<Meter> meters; // Список счетчиков для этой недвижимости
  final List<String>
      invitedTenants; // Список uid арендаторов, приглашенных в эту недвижимость

  Property({
    required this.id,
    required this.name,
    required this.city,
    required this.street,
    required this.house,
    required this.apartment,
    this.meters = const [], // Инициализация пустым списком
    this.invitedTenants = const [], // Инициализация пустым списком
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
      'invitedTenants':
          invitedTenants, // Добавить поле приглашенных арендаторов
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
      invitedTenants: List<String>.from(map['invitedTenants'] ?? []),
    );
  }
  // Метод copyWith для создания нового объекта с измененными значениями
  Property copyWith({
    String? id,
    String? name,
    String? city,
    String? street,
    String? house,
    String? apartment,
    List<Meter>? meters, // Добавлено для изменения списка счетчиков
    List<String>?
        invitedTenants, // Добавлено для изменения списка приглашенных арендаторов
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      street: street ?? this.street,
      house: house ?? this.house,
      apartment: apartment ?? this.apartment,
      meters: meters ?? this.meters, // Используем новое значение или текущее
      invitedTenants: invitedTenants ??
          this.invitedTenants, // Используем новое значение или текущее
    );
  }
}
