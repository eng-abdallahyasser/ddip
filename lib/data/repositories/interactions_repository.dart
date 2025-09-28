
import 'package:ddip/models/drug_interaction.dart';

class SearckInteractionDrug {
  final String id;
  final String activeIngredientA;
  final String activeIngredientB;

  SearckInteractionDrug({
    required this.id,
    required this.activeIngredientA,
    required this.activeIngredientB,
  });
}

abstract class InteractionsRepository {
  /// Save an interaction record to the interactions collection.
  /// Returns the saved document id or null on failure.
  Future<String?> saveInteraction(Map<String, dynamic> interaction);

  /// Return list of all searchable drugs for interactions.
  Future<List<SearckInteractionDrug>> fetchAllInteractions();

  Future<DrugInteraction> getInteractionById(String id);

  /// Query interactions between two drug ids (order-independent). Returns list
  /// of interaction documents as maps.
  Future<List<Map<String, dynamic>>> findInteractionsBetween(
    String idA,
    String idB,
  );
}
