import 'package:cloud_firestore/cloud_firestore.dart';
import 'drugs_repository.dart';

class DrugsFirestoreRepository implements DrugsRepository {
  final FirebaseFirestore firestore;

  DrugsFirestoreRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<String>> fetchAllDrugNames() async {
    final snapshot = await firestore.collection('drugs').get();
    final names = snapshot.docs
        .map((d) {
          final data = d.data();
          return (data['enName'] ?? data['name'] ?? '').toString();
        })
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }
}
