class MultiDrugInteractionResult {
  final List<FullInteractionType> interactions;

  MultiDrugInteractionResult({required this.interactions});

  factory MultiDrugInteractionResult.fromJson(Map<String, dynamic> json) {
    final List<FullInteractionType> interactions = [];
    final fullInteractionTypeGroup = json['fullInteractionTypeGroup'];

    if (fullInteractionTypeGroup != null && fullInteractionTypeGroup is List) {
      for (var group in fullInteractionTypeGroup) {
        final fullInteractionType = group['fullInteractionType'];
        if (fullInteractionType != null && fullInteractionType is List) {
          for (var interaction in fullInteractionType) {
            interactions.add(FullInteractionType.fromJson(interaction));
          }
        }
      }
    }

    return MultiDrugInteractionResult(interactions: interactions);
  }

  factory MultiDrugInteractionResult.empty() {
    return MultiDrugInteractionResult(interactions: []);
  }
}

class FullInteractionType {
  final String comment;
  final List<MinConcept> drugs;

  FullInteractionType({required this.comment, required this.drugs});

  factory FullInteractionType.fromJson(Map<String, dynamic> json) {
    final List<MinConcept> drugs = [];
    final minConcept = json['minConcept'];

    if (minConcept != null && minConcept is List) {
      for (var drug in minConcept) {
        drugs.add(MinConcept.fromJson(drug));
      }
    }

    return FullInteractionType(
      comment: json['comment'] ?? 'No comment available',
      drugs: drugs,
    );
  }
}

class MinConcept {
  final String name;
  final String rxcui;

  MinConcept({required this.name, required this.rxcui});

  factory MinConcept.fromJson(Map<String, dynamic> json) {
    return MinConcept(
      name: json['name'] ?? 'Unknown',
      rxcui: json['rxcui'] ?? '',
    );
  }
}