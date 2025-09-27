import 'package:cloud_firestore/cloud_firestore.dart';
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
        .where((s) => s.enName.isNotEmpty || s.arName.isNotEmpty)
        .toList();
    items.sort(
      (a, b) => a.enName.toLowerCase().compareTo(b.enName.toLowerCase()),
    );
    return items;
  }
}
