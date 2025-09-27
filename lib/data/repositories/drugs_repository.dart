abstract class DrugsRepository {
  /// Return list of drug display names (enName or name).
  Future<List<String>> fetchAllDrugNames();
}
