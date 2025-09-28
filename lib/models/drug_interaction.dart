enum InteractionSeverity { severe, moderate, mild }

class DrugInteraction {
  final String activeIngredientA;
  final String activeIngredientB;
  final InteractionSeverity severity; // Severe, Moderate, Mild
  final String description;
  final String mechanism;
  final String management;
  final String evidenceLevel;

  DrugInteraction({
    required this.activeIngredientA,
    required this.activeIngredientB,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.management,
    required this.evidenceLevel,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    InteractionSeverity parseSeverity(String? s) {
      switch ((s ?? '').toLowerCase()) {
        case 'severe':
        case 'high':
          return InteractionSeverity.severe;
        case 'moderate':
        case 'medium':
          return InteractionSeverity.moderate;
        default:
          return InteractionSeverity.mild;
      }
    }

    return DrugInteraction(
      activeIngredientA: json['drugAId']?.toString() ?? '',
      activeIngredientB: json['drugBId']?.toString() ?? '',
      severity: parseSeverity(json['severity']?.toString()),
      description: json['description']?.toString() ?? '',
      mechanism: json['mechanism']?.toString() ?? '',
      management: json['management']?.toString() ?? '',
      evidenceLevel: json['evidenceLevel']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    String severityToString(InteractionSeverity s) {
      switch (s) {
        case InteractionSeverity.severe:
          return 'severe';
        case InteractionSeverity.moderate:
          return 'moderate';
        case InteractionSeverity.mild:
          return 'mild';
      }
    }

    return {
      'drugAId': activeIngredientA,
      'drugBId': activeIngredientB,
      'severity': severityToString(severity),
      'description': description,
      'mechanism': mechanism,
      'management': management,
      'evidenceLevel': evidenceLevel,
    };
  }
}
