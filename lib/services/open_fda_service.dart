import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

/// Service for interacting with the FDA OpenFDA API
class OpenFDADrugService {
  static const String baseUrl = 'https://api.fda.gov/drug';

  /// Search for drug information by name (brand or generic)
  Future<List<DrugOpenFDAInfo>> searchDrug(String drugName) async {
    try {
      final query = Uri.encodeComponent(drugName.toLowerCase());

      // Search both brand and generic names
      final searchQuery ='openfda.generic_name:"$query"';
      final url = Uri.parse('$baseUrl/label.json?search=$searchQuery');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        log('Found ${results.length} results from openFDA for "$drugName"');
        return results
            .map((result) => DrugOpenFDAInfo.fromJson(result))
            .toList();
      } else if (response.statusCode == 404) {
        // No results found
        return [];
      }
    } catch (e) {
      log('Error searching drug: $e');
      rethrow;
    }
    return [];
  }

  /// Get detailed drug information including interactions
  Future<DrugOpenFDAInfo?> getDrugDetails(String drugName) async {
    final results = await searchDrug(drugName);
    return results.isNotEmpty ? results.first : null;
  }

  /// Search for interactions between two drugs
  Future<OpenFDAInteractionResult> checkInteractionsBetweenDrugs(
    String drug1Name,
    String drug2Name,
  ) async {
    try {
      // Get information for both drugs
      final drug1Info = await getDrugDetails(drug1Name);
      final drug2Info = await getDrugDetails(drug2Name);

      if (drug1Info == null || drug2Info == null) {
        return OpenFDAInteractionResult(
          drug1Name: drug1Name,
          drug2Name: drug2Name,
          found: false,
          message: drug1Info == null
              ? 'Could not find information for $drug1Name'
              : 'Could not find information for $drug2Name',
        );
      }

      // Check if drug2 is mentioned in drug1's interactions
      final drug2GenericName = drug2Info.genericName?.toLowerCase() ?? '';
      final drug2BrandName = drug2Info.brandName?.toLowerCase() ?? '';

      List<String> foundInteractions = [];

      for (var interaction in drug1Info.drugInteractions) {
        final interactionLower = interaction.toLowerCase();
        if (interactionLower.contains(drug2GenericName) ||
            interactionLower.contains(drug2BrandName) ||
            interactionLower.contains(drug2Name.toLowerCase())) {
          foundInteractions.add(interaction);
        }
      }

      // Also check drug2's interactions mentioning drug1
      final drug1GenericName = drug1Info.genericName?.toLowerCase() ?? '';
      final drug1BrandName = drug1Info.brandName?.toLowerCase() ?? '';

      for (var interaction in drug2Info.drugInteractions) {
        final interactionLower = interaction.toLowerCase();
        if (interactionLower.contains(drug1GenericName) ||
            interactionLower.contains(drug1BrandName) ||
            interactionLower.contains(drug1Name.toLowerCase())) {
          if (!foundInteractions.contains(interaction)) {
            foundInteractions.add(interaction);
          }
        }
      }

      return OpenFDAInteractionResult(
        drug1Name: drug1Info.brandName ?? drug1Info.genericName ?? drug1Name,
        drug2Name: drug2Info.brandName ?? drug2Info.genericName ?? drug2Name,
        found: foundInteractions.isNotEmpty,
        interactions: foundInteractions,
        message: foundInteractions.isEmpty
            ? 'No specific interactions found between these drugs in FDA labels'
            : null,
        drug1Info: drug1Info,
        drug2Info: drug2Info,
      );
    } catch (e) {
      log('Error checking interactions: $e');
      return OpenFDAInteractionResult(
        drug1Name: drug1Name,
        drug2Name: drug2Name,
        found: false,
        message: 'Error checking interactions: $e',
      );
    }
  }

  OpenFDAInteractionResult checkInteractionsBetweenDrugsInfo(
    DrugOpenFDAInfo drug1Info,
    DrugOpenFDAInfo drug2Info,
  ) {
    try {
      // Check if drug2 is mentioned in drug1's interactions
      final drug2GenericName = drug2Info.genericName?.toLowerCase() ?? '';
      final drug2BrandName = drug2Info.brandName?.toLowerCase() ?? '';

      List<String> foundInteractions = [];

      for (var interaction in drug1Info.drugInteractions) {
        final interactionLower = interaction.toLowerCase();
        if (interactionLower.contains(drug2GenericName) ||
            interactionLower.contains(drug2BrandName)) {
          foundInteractions.add(interaction);
        }
      }

      // Also check drug2's interactions mentioning drug1
      final drug1GenericName = drug1Info.genericName?.toLowerCase() ?? '';
      final drug1BrandName = drug1Info.brandName?.toLowerCase() ?? '';

      for (var interaction in drug2Info.drugInteractions) {
        final interactionLower = interaction.toLowerCase();
        if (interactionLower.contains(drug1GenericName) ||
            interactionLower.contains(drug1BrandName)) {
          if (!foundInteractions.contains(interaction)) {
            foundInteractions.add(interaction);
          }
        }
      }

      return OpenFDAInteractionResult(
        drug1Name: drug1Info.brandName ?? drug1Info.genericName ?? "drug1Name",
        drug2Name: drug2Info.brandName ?? drug2Info.genericName ?? "drug2Name",
        found: foundInteractions.isNotEmpty,
        interactions: foundInteractions,
        message: foundInteractions.isEmpty
            ? 'No specific interactions found between these drugs in FDA labels'
            : null,
        drug1Info: drug1Info,
        drug2Info: drug2Info,
      );
    } catch (e) {
      log('Error checking interactions: $e');
      return OpenFDAInteractionResult(
        drug1Name: drug1Info.brandName ?? drug1Info.genericName ?? "drug1Name",
        drug2Name: drug2Info.brandName ?? drug2Info.genericName ?? "drug2Name",
        found: false,
        message: 'Error checking interactions: $e',
      );
    }
  }

  /// Search for adverse events involving a drug
  Future<List<AdverseEvent>> getAdverseEvents(String drugName) async {
    try {
      final query = Uri.encodeComponent(drugName.toLowerCase());
      final url = Uri.parse(
        '$baseUrl/event.json?search=patient.drug.medicinalproduct:"$query"&limit=10',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((result) => AdverseEvent.fromJson(result)).toList();
      }
    } catch (e) {
      log('Error getting adverse events: $e');
    }
    return [];
  }
}

/// Model for drug information
class DrugOpenFDAInfo {
  final String? brandName;
  final String? genericName;
  final String? manufacturer;
  final List<String> drugInteractions;
  final List<String> warnings;
  final List<String> precautions;
  final List<String> adverseReactions;
  final String? dosageAndAdministration;
  final String? description;
  final List<String> activeIngredients;

  DrugOpenFDAInfo({
    this.brandName,
    this.genericName,
    this.manufacturer,
    this.drugInteractions = const [],
    this.warnings = const [],
    this.precautions = const [],
    this.adverseReactions = const [],
    this.dosageAndAdministration,
    this.description,
    this.activeIngredients = const [],
  });

  factory DrugOpenFDAInfo.fromJson(Map<String, dynamic> json) {
    final openfda = json['openfda'] as Map<String, dynamic>?;

    return DrugOpenFDAInfo(
      brandName: openfda?['brand_name']?[0],
      genericName: openfda?['generic_name']?[0],
      manufacturer: openfda?['manufacturer_name']?[0],
      drugInteractions: _extractList(json['drug_interactions']),
      warnings: _extractList(json['warnings']),
      precautions: _extractList(json['precautions']),
      adverseReactions: _extractList(json['adverse_reactions']),
      dosageAndAdministration: json['dosage_and_administration']?[0],
      description: json['description']?[0],
      activeIngredients: openfda?['substance_name'] != null
          ? List<String>.from(openfda!['substance_name'])
          : [],
    );
  }

  static List<String> _extractList(dynamic field) {
    if (field == null) return [];
    if (field is List) {
      return field.map((e) => e.toString()).toList();
    }
    return [field.toString()];
  }

  String get displayName => brandName ?? genericName ?? 'Unknown Drug';
}

/// Model for interaction check results
class OpenFDAInteractionResult {
  final String drug1Name;
  final String drug2Name;
  final bool found;
  final List<String> interactions;
  final String? message;
  final DrugOpenFDAInfo? drug1Info;
  final DrugOpenFDAInfo? drug2Info;

  OpenFDAInteractionResult({
    required this.drug1Name,
    required this.drug2Name,
    required this.found,
    this.interactions = const [],
    this.message,
    this.drug1Info,
    this.drug2Info,
  });
}

/// Model for adverse events
class AdverseEvent {
  final String? seriousness;
  final List<String> reactions;
  final String? patientAge;
  final String? patientSex;
  final String? reportDate;

  AdverseEvent({
    this.seriousness,
    this.reactions = const [],
    this.patientAge,
    this.patientSex,
    this.reportDate,
  });

  factory AdverseEvent.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] as Map<String, dynamic>?;
    final reactions = patient?['reaction'] as List?;

    List<String> reactionTerms = [];
    if (reactions != null) {
      for (var reaction in reactions) {
        if (reaction['reactionmeddrapt'] != null) {
          reactionTerms.add(reaction['reactionmeddrapt']);
        }
      }
    }

    return AdverseEvent(
      seriousness: json['serious']?.toString(),
      reactions: reactionTerms,
      patientAge: patient?['patientonsetage']?.toString(),
      patientSex: patient?['patientsex']?.toString(),
      reportDate: json['receiptdate'],
    );
  }
}
