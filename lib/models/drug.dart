
import 'package:cloud_firestore/cloud_firestore.dart';

class Drug {
  final String id;
  final String enName;
  final String arName;
  final double? oldPrice;
  final double price;
  final String active;
  final List<String> activeIngredients;
  final String? company;
  final String? description;
  final String? units;
  final String? dosageForm;
  final String? barcode;
  final bool imported;
  final DateTime? dateUpdated;

  Drug({
    required this.id,
    required this.enName,
    required this.arName,
    this.oldPrice,
    required this.price,
    required this.active,
    required this.activeIngredients,
    this.company,
    this.description,
    this.units,
    this.dosageForm,
    this.barcode,
    required this.imported,
    this.dateUpdated,
  });

  // Parse active string into list of ingredients.
  // Strategy: split on '+' then trim. Keep parentheses as part of the token.
  static List<String> parseActiveIngredients(String? active) {
    if (active == null) return [];
    return active.split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  factory Drug.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw == null ? '' : idRaw.toString();

    final enName = (json['name'] ?? json['enName'] ?? '').toString();
    final arName = (json['arabic'] ?? json['arName'] ??'').toString();

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final oldPrice = parseDouble(json['oldprice']);
    final price = parseDouble(json['price']) ?? 0.0;

    final active = (json['active'] ?? '').toString();
    final activeIngredients = parseActiveIngredients(active);

    final company = json['company']?.toString();
    final description = json['description']?.toString();

    // units may be numeric in sample.json
    final unitsRaw = json['units'];
    final units = unitsRaw?.toString();

    final dosageForm = json['dosage_form']?.toString();
    final barcode = json['barcode']?.toString();

  final importedRaw = json['imported']?.toString();
  final imported = importedRaw != null && importedRaw.toLowerCase() == 'imported';

    DateTime? dateUpdated;
    final dateRaw = json['Date_updated'] ?? json['date_updated'] ?? json['dateUpdated'];
    if (dateRaw != null) {
      if (dateRaw is int) {
        dateUpdated = DateTime.fromMillisecondsSinceEpoch(dateRaw);
      } else if (dateRaw is String) {
        final asInt = int.tryParse(dateRaw);
        if (asInt != null) {
          dateUpdated = DateTime.fromMillisecondsSinceEpoch(asInt);
        } else {
          dateUpdated = DateTime.tryParse(dateRaw);
        }
      }
    }

    return Drug(
      id: id,
      enName: enName,
      arName: arName,
      oldPrice: oldPrice,
      price: price,
      active: active,
      activeIngredients: activeIngredients,
      company: company,
      description: description,
      units: units,
      dosageForm: dosageForm,
      barcode: barcode,
      imported: imported,
      dateUpdated: dateUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enName': enName,
      'arName': arName,
      if (oldPrice != null) 'oldPrice': oldPrice,
      'price': price,
      'active': active,
      'activeIngredients': activeIngredients,
      if (company != null) 'company': company,
      if (description != null) 'description': description,
      if (units != null) 'units': units,
      if (dosageForm != null) 'dosageForm': dosageForm,
      if (barcode != null) 'barcode': barcode,
      'imported': imported,
      if (dateUpdated != null) 'dateUpdated': Timestamp.fromDate(dateUpdated!),
    };
  }

  @override
  String toString(){
    return 'Drug{id: $id, \nenName: $enName, \narName: $arName, \noldPrice: $oldPrice, \nprice: $price, \nactive: $active, \nactiveIngredients: $activeIngredients, \ncompany: $company, description: $description, units: $units, dosageForm: $dosageForm, barcode: $barcode, imported: $imported, dateUpdated: $dateUpdated}';
  }
}
