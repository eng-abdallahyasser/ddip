class DrugInfo {
  final String name;
  final String rxcui;

  DrugInfo({required this.name, required this.rxcui});

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      name: json['minConceptItem']['name'] ?? 'Unknown',
      rxcui: json['minConceptItem']['rxcui'] ?? '',
    );
  }
}