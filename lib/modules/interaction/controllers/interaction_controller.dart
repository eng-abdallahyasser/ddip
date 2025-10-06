import 'dart:developer';
import 'package:ddip/data/services/gemini_service.dart';
import 'package:ddip/models/drug.dart';
import 'package:ddip/models/drug_interaction.dart';
import 'package:ddip/services/open_fda_service.dart';
import 'package:ddip/utils/interaction_import.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/drugs_repository.dart';
import '../../../data/repositories/interactions_repository.dart';

class InteractionController extends GetxController {
  // final NLMDrugInteractionService _nlmInteractionService =
  //     NLMDrugInteractionService();
  final OpenFDADrugService _openFDADrugService = OpenFDADrugService();
  final allDrugs = <dynamic>[].obs; // holds SearchDrug objects
  // suggestions holds SearchDrug-like objects matching current search
  final dDInterInteractionsFounded = <DrugInteraction>[].obs;

  final List<DrugInteraction> allDDInterInteractions = <DrugInteraction>[];

  final suggestions = <dynamic>[].obs;
  // selected holds full Drug maps (as returned by fetchDrugById)
  final selectedDrugs = <Drug>[].obs;
  final setOfActiveIngredients = <String>{};
  final setOfActiveIngredientsRxcui = <String>{};
  final setOfActivesOpenFDAInfo = <DrugOpenFDAInfo>{};

  final geminiService = GeminiService();
  final geminiFeedback = "".obs; // store feedback text

  // found interactions between selected drugs
  final openFDAInteractionsFounded = <OpenFDAInteractionResult>[].obs;
  final loading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final DrugsRepository drugsRepository;
  final InteractionsRepository interactionsRepository;

  InteractionController({
    required this.drugsRepository,
    required this.interactionsRepository,
  });

  @override
  void onInit() async {
    super.onInit();
    _fetchAllDrugNames();
    await _loadAllDDInterInteractions();

    searchController.addListener(_onTextChanged);
  }

  Future<void> _loadAllDDInterInteractions() async {
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_A.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_B.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_D.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_H.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_L.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_P.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_R.csv',
      ),
    );
    allDDInterInteractions.addAll(
      await importDrugInteractionsFromCsv(
        'assets/data/ddinter_downloads_code_V.csv',
      ),
    );
    log(
      'Total imported DDInter interactions: ${allDDInterInteractions.where((e) {
        return e.severity == InteractionSeverity.unknown;
      }).length}',
    );
  }

  @override
  void onClose() {
    searchController.removeListener(_onTextChanged);
    searchController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> _fetchAllDrugNames() async {
    try {
      final drugs = await drugsRepository.fetchAllDrugs();
      allDrugs.assignAll(drugs);
    } catch (_) {
      // ignore errors for now
    }
  }

  void _onTextChanged() {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      suggestions.clear();
      return;
    }
    final matches = allDrugs
        .where((d) {
          final en = (d.enName ?? '').toString().toLowerCase();
          return en.startsWith(q);
        })
        .take(10)
        .toList();
    suggestions.assignAll(matches);
  }

  Future<void> addSelected(dynamic drug) async {
    // drug is SearchDrug-like with id
    final id = drug.id?.toString() ?? '';
    if (id.isEmpty) return;

    // avoid duplicates by id
    if (selectedDrugs.any((s) => s.id == id)) {
      searchController.clear();
      suggestions.clear();
      focusNode.requestFocus();
      return;
    }

    loading.value = true;
    geminiFeedback.value = "Gemini thinking...";
    searchController.clear();
    focusNode.requestFocus();
    suggestions.clear();

    // fetch full drug properties
    final fullDrug = await drugsRepository.fetchDrugById(id);
    if (fullDrug == null) return;
    for (final activeIngredient in fullDrug.activeIngredients) {
      setOfActiveIngredients.add(activeIngredient);
      // Here you would typically look up the RXCUI for the active ingredient.
      // final rxcui = await _nlmInteractionService.getRxCuiByName(
      //   activeIngredient.toLowerCase(),
      // );
      final openFDAInfo = await _openFDADrugService.searchDrug(
        activeIngredient,
      );
      if (openFDAInfo.isNotEmpty) {
        setOfActivesOpenFDAInfo.addAll(openFDAInfo);
        log("Added OpenFDA info for: $activeIngredient");
      }
      // if (rxcui != null) {
      //   setOfActiveIngredientsRxcui.add(rxcui);
      //   log("Added RXCUI: $rxcui");
      // } else {
      //   log(
      //     "No RXCUI found for active ingredient: ${activeIngredient.toLowerCase()}",
      //   );
      // }
    }
    setOfActiveIngredients.toSet();
    setOfActiveIngredientsRxcui.toSet();
    setOfActivesOpenFDAInfo.toSet();

    log("fetchDrug ${fullDrug.toString()}");

    selectedDrugs.add(fullDrug);

    checkInteractions();
    getGeminiFeedback();

    loading.value = false;
  }

  /// Recompute interactions for all currently selected drugs.
  Future<void> checkInteractions() async {
    if (selectedDrugs.length < 2) return;
    // Check DDInter interactions
    dDInterInteractionsFounded.clear();
    for (var i = 0; i < setOfActiveIngredients.length - 1; i++) {
      for (var j = i + 1; j < setOfActiveIngredients.length; j++) {
        final drugA = setOfActiveIngredients.elementAt(i);
        final drugB = setOfActiveIngredients.elementAt(j);
        final ddInterInteractions = allDDInterInteractions.where((interaction) {
          final matchA =
              (interaction.activeIngredientA.toLowerCase() ==
              drugA.toLowerCase());
          final matchB =
              (interaction.activeIngredientB.toLowerCase() ==
              drugB.toLowerCase());
          final reverseMatchA =
              (interaction.activeIngredientA.toLowerCase() ==
              drugB.toLowerCase());
          final reverseMatchB =
              (interaction.activeIngredientB.toLowerCase() ==
              drugA.toLowerCase());
          return (matchA && matchB) || (reverseMatchA && reverseMatchB);
        }).toList();
        if (ddInterInteractions.isNotEmpty) {
          dDInterInteractionsFounded.addAll(ddInterInteractions);
          log(
            "Found ${ddInterInteractions.length} interactions from DDInter between $drugA and $drugB.",
          );
          log("ex :${ddInterInteractions[0].toMap()}");
        }
      }
    }

    // Check OpenFDA interactions
    // iterate over unique pairs (i < j)
    openFDAInteractionsFounded.clear();

    for (var i = 0; i < setOfActivesOpenFDAInfo.length - 1; i++) {
      for (var j = i + 1; j < setOfActivesOpenFDAInfo.length; j++) {
        final drugA = setOfActivesOpenFDAInfo.elementAt(i);
        final drugB = setOfActivesOpenFDAInfo.elementAt(j);
        final interaction = _openFDADrugService
            .checkInteractionsBetweenDrugsInfo(drugA, drugB);
        if (interaction.found) {
          openFDAInteractionsFounded.add(interaction);
        }
      }
    }
    log(
      "Found ${openFDAInteractionsFounded.length} interactions from OpenFDA.",
    );
  }

  void removeSelectedAt(int index) async {
    selectedDrugs.removeAt(index);
    // Recompute interactions after a removal
    setOfActiveIngredients.clear();
    for (final drug in selectedDrugs) {
      for (final activeIngredient in drug.activeIngredients) {
        setOfActiveIngredients.add(activeIngredient);
      }
    }
    setOfActiveIngredients.toSet();
    checkInteractions();
    getGeminiFeedback();
  }

  Future<void> getGeminiFeedback() async {
    try {
      if (selectedDrugs.isEmpty) return;

      final drugNames = selectedDrugs
          .map((d) => "${d.enName} contain active ingredient ===> ${d.active}")
          .toList();

      final feedback = await geminiService.getDrugsFeedback(drugNames);

      geminiFeedback.value = feedback;
      log("Gemini Feedback: $feedback");
    } catch (e) {
      log("Gemini error: $e");
      geminiFeedback.value = "Could not fetch AI feedback.";
    }
  }
}
