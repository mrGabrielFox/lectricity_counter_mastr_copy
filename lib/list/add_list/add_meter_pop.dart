import 'package:electricity_counter_mastr_copy/model/meter.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AddMeterPopup extends StatefulWidget {
  final String propertyId;
  final String userId;

  const AddMeterPopup(
      {super.key, required this.propertyId, required this.userId});

  @override
  AddMeterPopupState createState() => AddMeterPopupState();
}

class AddMeterPopupState extends State<AddMeterPopup> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _meterNumberController = TextEditingController();
  final TextEditingController _readingController = TextEditingController();
  final TextEditingController _consumptionController = TextEditingController();
  final TextEditingController _tariffController = TextEditingController();

  String _measurement = 'куб.м.';
  final List<String> _measurementOptions = ['куб.м.', 'кВт*ч'];

  String? _typeError;
  String? _meterNumberError;
  String? _readingError;
  String? _tariffError;

  @override
  void dispose() {
    _typeController.dispose();
    _meterNumberController.dispose();
    _readingController.dispose();
    _consumptionController.dispose();
    _tariffController.dispose();
    super.dispose();
  }

  Future<void> _addMeter() async {
    logger.d('Начинаем добавление счетчика');

    String id = FirebaseFirestore.instance.collection('meters').doc().id;

    String type = _typeController.text.trim();
    String meterNumberStr = _meterNumberController.text.trim();
    int meterNumber = int.tryParse(meterNumberStr) ?? -1;
    double reading = double.tryParse(_readingController.text.trim()) ?? -1.0;

    double consumption = 0;
    String consumptionStr = _consumptionController.text.trim();
    if (consumptionStr.isNotEmpty) {
      consumption = double.tryParse(consumptionStr) ?? 0;
    }

    double tariff = double.tryParse(_tariffController.text.trim()) ?? -1.0;

    logger.d(
        'Проверка введенных данных: тип: $type, номер: $meterNumber, показание: $reading, потребление: $consumption, тариф: $tariff');

    if (type.isEmpty) {
      _typeError = 'Поле не может быть пустым.';
    }
    if (meterNumber < 0) {
      _meterNumberError = 'Введите корректный номер счётчика.';
    }
    if (reading < 0) {
      _readingError = 'Введите корректное показание.';
    }
    if (tariff < 0) {
      _tariffError = 'Введите корректный тариф.';
    }

    if (_typeError != null ||
        _meterNumberError != null ||
        _readingError != null ||
        _tariffError != null) {
      logger.e(
          'Ошибка валидации: $_typeError, $_meterNumberError, $_readingError, $_tariffError');
      setState(() {});
      return;
    }

    Meter meter = Meter(
      id: id,
      type: type,
      meterNumber: meterNumber,
      reading: reading,
      measurement: _measurement,
      consumption: consumption,
      tariff: tariff,
      dateRecorded: DateTime.now(),
      lastCheck: DateTime.now(),
    );

    try {
      logger.d('Проверяем существующие счетчики');
      var existingMeters = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('properties')
          .doc(widget.propertyId)
          .collection('meters')
          .where('meterNumber', isEqualTo: meterNumber)
          .get();

      if (existingMeters.docs.isNotEmpty) {
        if (!mounted) return; // Проверка перед использованием context
        _showErrorDialog(context, 'Счетчик с таким номером уже существует.');
        return;
      }

      logger.d('Добавляем счетчик в Firestore');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('properties')
          .doc(widget.propertyId)
          .collection('meters')
          .doc(id)
          .set(meter.toMap());

      logger.d('Счетчик успешно добавлен');
      if (!mounted) return; // Проверка перед использованием context
      Navigator.pop(context);
    } catch (e) {
      logger.e('Ошибка при добавлении счётчика: $e');
      if (!mounted) return; // Проверка перед использованием context
      _showErrorDialog(
          context, 'Ошибка при добавлении счётчика: ${e.toString()}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('ОК'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Добавить Счётчик'),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_typeController, 'Тип счётчика', _typeError),
            _buildTextField(
                _meterNumberController, 'Номер счётчика', _meterNumberError,
                keyboardType: TextInputType.number),
            _buildTextField(_readingController, 'Показание', _readingError,
                keyboardType: TextInputType.numberWithOptions(decimal: true)),
            _buildMeasurementButton(),
            _buildTextField(_tariffController, 'Тариф', _tariffError,
                keyboardType: TextInputType.numberWithOptions(decimal: true)),
            SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: _addMeter,
              child: Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String placeholder, String? error,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border.all(
              color: error != null
                  ? CupertinoColors.systemRed
                  : CupertinoColors.inactiveGray,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          style: TextStyle(fontSize: 16.0),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child:
                Text(error, style: TextStyle(color: CupertinoColors.systemRed)),
          ),
        SizedBox(height: 12.0),
      ],
    );
  }

  Widget _buildMeasurementButton() {
    return CupertinoButton(
      child: Text('Ед. измерения: $_measurement'),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text('Выберите единицу измерения'),
              actions: _measurementOptions.map((String option) {
                return CupertinoActionSheetAction(
                  child: Text(option),
                  onPressed: () {
                    setState(() {
                      _measurement = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              cancelButton: CupertinoActionSheetAction(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }
}
