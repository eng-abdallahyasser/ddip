import 'dart:developer';
import 'package:ddip/models/drug.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/drugs_repository.dart';
import '../../../data/repositories/interactions_repository.dart';
import '../../../models/drug_interaction.dart';

class InteractionController extends GetxController {
  final allDrugs = <dynamic>[].obs; // holds SearchDrug objects
  // suggestions holds SearchDrug-like objects matching current search
  final allInteractions = <dynamic>[].obs;

  final suggestions = <dynamic>[].obs;
  // selected holds full Drug maps (as returned by fetchDrugById)
  final selectedDrugs = <Drug>[].obs;

  // found interactions between selected drugs
  final interactionsFounded = <DrugInteraction>[].obs;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final DrugsRepository drugsRepository;
  final InteractionsRepository interactionsRepository;

  InteractionController({
    required this.drugsRepository,
    required this.interactionsRepository,
  });

  @override
  void onInit() {
    super.onInit();
    _fetchAllDrugNames();
    searchController.addListener(_onTextChanged);
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
      final interactions = await interactionsRepository.fetchAllInteractions();
      allInteractions.assignAll(interactions);
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
          final ar = (d.arName ?? '').toString().toLowerCase();
          return en.contains(q) || ar.contains(q);
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

    // fetch full drug properties
    final full = await drugsRepository.fetchDrugById(id);
    if (full == null) return;

    log("fetchDrug ${full.toString()}");

    selectedDrugs.add(full);

    checkInteractions();

    searchController.clear();
    focusNode.requestFocus();
    suggestions.clear();
  }

  /// Recompute interactions for all currently selected drugs.
  Future<void> checkInteractions() async {
    interactionsFounded.clear();

    if (selectedDrugs.length < 2) return;

    // iterate over unique pairs (i < j)
    for (var i = 0; i < selectedDrugs.length; i++) {
      final drugA = selectedDrugs[i];
      for (var j = i + 1; j < selectedDrugs.length; j++) {
        final drugB = selectedDrugs[j];

        final existing = <DrugInteraction>[];

        for (final activeIngredientA in drugA.activeIngredients) {
          for (final activeIngredientB in drugB.activeIngredients) {
            log(
              'checking interactions for $activeIngredientA and $activeIngredientB',
            );

            SearckInteractionDrug? A = allInteractions.firstWhereOrNull(
              (d) =>
                  (d.activeIngredientA == activeIngredientA ||
                  d.activeIngredientB == activeIngredientA),
            );
            SearckInteractionDrug? B = allInteractions.firstWhereOrNull(
              (d) =>
                  (d.activeIngredientA == activeIngredientB ||
                  d.activeIngredientB == activeIngredientB),
            );

            if (A != null) {
              final ia = await interactionsRepository.getInteractionById(A.id);
              existing.add(ia);
            }
            if (B != null) {
              final ib = await interactionsRepository.getInteractionById(B.id);
              existing.add(ib);
            }
          }
        }

        if (existing.isNotEmpty) {
          log(
            'Found existing interactions for ${drugA.id} and ${drugB.id}: ${existing.length}',
          );
          for (final ex in existing) {
            if (!interactionsFounded.any(
              (it) =>
                  it.activeIngredientA == ex.activeIngredientA &&
                  it.activeIngredientB == ex.activeIngredientB,
            )) {
              interactionsFounded.add(ex);
            }
          }
        } else {
          // No stored interaction found between these two drugs. You may add
          // heuristic detection here if desired (shared actives, etc.).
        }
      }
    }
  }

  void removeSelectedAt(int index) {
    selectedDrugs.removeAt(index);
    // Recompute interactions after a removal
    checkInteractions();
  }
}
