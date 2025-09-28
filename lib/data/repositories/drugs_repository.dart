import 'package:ddip/models/drug.dart';

class SearchDrug {
  final String id;
  final String enName;
  final String arName;

  SearchDrug({required this.id, required this.enName, required this.arName});
}

abstract class DrugsRepository {
  /// Return list of searchable drug records.
  Future<List<SearchDrug>> fetchAllDrugs();

  /// Fetch a full Drug record by id. Implementations should return a map
  // ignore: unintended_html_in_doc_comment
  /// or a domain model; here we return Map<String, dynamic> to avoid
  /// importing the domain model package in repository interfaces.
  Future<Map<String, dynamic>?> fetchMapDrugById(String id);
  Future<Drug?> fetchDrugById(String id);

  Future<List<String>> fetchAllActiveIngredients();
}
