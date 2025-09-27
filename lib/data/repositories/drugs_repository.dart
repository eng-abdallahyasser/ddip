class SearchDrug {
  final String id;
  final String enName;
  final String arName;

  SearchDrug({required this.id, required this.enName, required this.arName});
}

abstract class DrugsRepository {
  /// Return list of searchable drug records.
  Future<List<SearchDrug>> fetchAllDrugs();
}
