import 'package:ddip/models/interaction_pair.dart';

class DrugInteractionResult {
  final List<InteractionPair> interactions;

  DrugInteractionResult({required this.interactions});

  factory DrugInteractionResult.fromJson(Map<String, dynamic> json) {
    final interactionTypeGroup = json['interactionTypeGroup'];
    final List<InteractionPair> interactions = [];

    if (interactionTypeGroup != null && interactionTypeGroup is List) {
      for (var group in interactionTypeGroup) {
        final interactionType = group['interactionType'];
        if (interactionType != null && interactionType is List) {
          for (var type in interactionType) {
            final interactionPair = type['interactionPair'];
            if (interactionPair != null && interactionPair is List) {
              for (var pair in interactionPair) {
                interactions.add(InteractionPair.fromJson(pair));
              }
            }
          }
        }
      }
    }

    return DrugInteractionResult(interactions: interactions);
  }

  factory DrugInteractionResult.empty() {
    return DrugInteractionResult(interactions: []);
  }
}