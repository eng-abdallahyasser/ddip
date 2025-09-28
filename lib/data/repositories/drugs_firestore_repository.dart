import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddip/models/drug.dart';
import 'drugs_repository.dart';

class DrugsFirestoreRepository implements DrugsRepository {
  final FirebaseFirestore firestore;

  DrugsFirestoreRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<SearchDrug>> fetchAllDrugs() async {
    final snapshot = await firestore.collection('drugs').get();
    final items = snapshot.docs
        .map((d) {
          final data = d.data();
          final id = d.id;
          final en = (data['enName'] ?? data['name'] ?? '').toString();
          final ar = (data['arName'] ?? data['arabic'] ?? '').toString();
          
          return SearchDrug(id: id, enName: en, arName: ar);
        })
        .where((s) => s.enName.isNotEmpty)
        .toList();
    items.sort(
      (a, b) => a.enName.toLowerCase().compareTo(b.enName.toLowerCase()),
    );
    return items;
  }

  @override
  Future<List<String>> fetchAllActiveIngredients() async {
    final List<String> uniqueActiveIngredients = [];
    final snapshot = await firestore.collection('drugs').get();

    // Process all documents to collect active ingredients
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final rawIngredients = data['activeIngredients'];

      // Handle different possible formats of activeIngredients
      List<String> ingredients = [];
      if (rawIngredients is List) {
        ingredients = rawIngredients.map((item) => item.toString().trim()).where((s) => s.isNotEmpty).toList();
      } else if (rawIngredients is String && rawIngredients.isNotEmpty) {
        ingredients = [rawIngredients.trim()];
      }
      uniqueActiveIngredients.addAll(ingredients);
    }

    final result = uniqueActiveIngredients.toSet().toList();
    return result;
  }

  @override
  Future<Map<String, dynamic>?> fetchMapDrugById(String id) async {
    final doc = await firestore.collection('drugs').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data);
    map['id'] = doc.id;
    return map;
  }

  @override
  Future<Drug?> fetchDrugById(String id) {
    return fetchMapDrugById(id).then((map) {
      if (map == null) return null;
      return Drug.fromJson(map);
    });
  }
}
