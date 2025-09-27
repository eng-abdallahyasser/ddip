import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/drugs_repository.dart';

class InteractionController extends GetxController {
  final allDrugs = <dynamic>[].obs; // holds SearchDrug objects
  final suggestions = <dynamic>[].obs;
  final selected = <String>[].obs;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final DrugsRepository repository;

  InteractionController({required this.repository});

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
      final drugs = await repository.fetchAllDrugs();
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

  void addSelected(dynamic drug) {
    final display = (drug.enName?.toString().isNotEmpty ?? false)
        ? drug.enName
        : drug.arName;
    if (!selected.contains(display)) selected.add(display);
    searchController.clear();
    focusNode.requestFocus();
    suggestions.clear();
  }

  void removeSelectedAt(int index) => selected.removeAt(index);
}
