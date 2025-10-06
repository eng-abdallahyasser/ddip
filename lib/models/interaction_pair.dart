import 'package:ddip/models/drug_info.dart';

class InteractionPair {
  final String description;
  final String severity;
  final DrugInfo drug1;
  final DrugInfo drug2;

  InteractionPair({
    required this.description,
    required this.severity,
    required this.drug1,
    required this.drug2,
  });

  factory InteractionPair.fromJson(Map<String, dynamic> json) {
    return InteractionPair(
      description: json['description'] ?? 'No description available',
      severity: json['severity'] ?? 'Unknown',
      drug1: DrugInfo.fromJson(json['interactionConcept'][0]),
      drug2: DrugInfo.fromJson(json['interactionConcept'][1]),
    );
  }
}