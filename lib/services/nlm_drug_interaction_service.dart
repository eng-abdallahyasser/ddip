import 'dart:convert';
import 'dart:developer';
import 'package:ddip/models/drug_interaction_result.dart';
import 'package:ddip/models/multi_drug_interaction_result.dart';
import 'package:http/http.dart' as http;

class NLMDrugInteractionService {
  static const String baseUrl = 'https://rxnav.nlm.nih.gov/REST';

  // Search for drug by name and get RxCUI
  Future<String?> getRxCuiByName(String drugName) async {
    try {
      final url = Uri.parse('$baseUrl/rxcui.json?name=$drugName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rxcuiList = data['idGroup']?['rxnormId'];

        if (rxcuiList != null && rxcuiList.isNotEmpty) {
          return rxcuiList[0];
        }
      }
    } catch (e) {
      log('Error getting RxCUI: $e');
    }
    return null;
  }

  // Get interactions for a single drug
  Future<DrugInteractionResult> getInteractionsForDrug(String rxcui) async {
    try {
      final url = Uri.parse(
        '$baseUrl/interaction/interaction.json?rxcui=$rxcui',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DrugInteractionResult.fromJson(data);
      }
    } catch (e) {
      log('Error getting interactions: $e');
    }
    return DrugInteractionResult.empty();
  }

  // Get interactions between multiple drugs
  Future<MultiDrugInteractionResult> getInteractionsBetweenDrugs(
    List<String> rxcuis,
  ) async {
    try {
      final rxcuisParam = rxcuis.join('+');
      final url = Uri.parse(
        '$baseUrl/interaction/list.json?rxcuis=$rxcuisParam',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MultiDrugInteractionResult.fromJson(data);
      }
    } catch (e) {
      log('Error getting multi-drug interactions: $e');
    }
    return MultiDrugInteractionResult.empty();
  }

  // Search for drug names with spelling suggestions
  Future<List<String>> searchDrugNames(String query) async {
    try {
      final url = Uri.parse('$baseUrl/spellingsuggestions.json?name=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions =
            data['suggestionGroup']?['suggestionList']?['suggestion'];

        if (suggestions != null) {
          return List<String>.from(suggestions);
        }
      }
    } catch (e) {
      log('Error searching drug names: $e');
    }
    return [];
  }
}
