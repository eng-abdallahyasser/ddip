import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddip/models/drug_interaction.dart';
import 'interactions_repository.dart';

class InteractionsFirestoreRepository implements InteractionsRepository {
  final FirebaseFirestore firestore;

  InteractionsFirestoreRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String?> saveInteraction(Map<String, dynamic> interaction) async {
    try {
      final doc = await firestore.collection('interactions').add(interaction);
      return doc.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> findInteractionsBetween(
    String idA,
    String idB,
  ) async {
    // Since relationships are bidirectional, look for entries where
    // (drugAId == idA and drugBId == idB) OR (drugAId == idB and drugBId == idA)
    final q1 = firestore
        .collection('interactions')
        .where('drugAId', isEqualTo: idA)
        .where('drugBId', isEqualTo: idB)
        .get();
    final q2 = firestore
        .collection('interactions')
        .where('drugAId', isEqualTo: idB)
        .where('drugBId', isEqualTo: idA)
        .get();

    final results = await Future.wait([q1, q2]);
    final docs = <Map<String, dynamic>>[];
    for (final snap in results) {
      for (final d in snap.docs) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        docs.add(m);
      }
    }
    return docs;
  }
  
  @override
  Future<List<SearckInteractionDrug>> fetchAllInteractions() async{
    final snapshot = await firestore.collection('interactions').get();
    final items = snapshot.docs
        .map((d) {
          final data = d.data();
          final id = d.id;
          final drugAId = (data['drugAId'] ?? '').toString();
          final drugBId = (data['drugBId'] ?? '').toString();
          return SearckInteractionDrug(id: id, activeIngredientA: drugAId, activeIngredientB: drugBId);
        })
        .where((s) => s.activeIngredientA.isNotEmpty || s.activeIngredientB.isNotEmpty)
        .toList();
    items.sort(
      (a, b) => a.activeIngredientA.toLowerCase().compareTo(b.activeIngredientA.toLowerCase()),
    );
    return items;
    
  }

  @override
  Future<DrugInteraction> getInteractionById(String id) {
    return firestore.collection('interactions').doc(id).get().then((doc) {
      if (!doc.exists) {
        throw Exception('Interaction with id $id not found');
      }
      final data = doc.data();
      if (data == null) {
        throw Exception('Interaction with id $id has no data');
      }
      final map = Map<String, dynamic>.from(data);
      map['id'] = doc.id;
      return DrugInteraction.fromJson(map);
    });
  }
}
