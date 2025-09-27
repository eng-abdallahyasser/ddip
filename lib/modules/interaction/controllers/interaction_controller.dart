import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/drugs_repository.dart';

class InteractionController extends GetxController {
  final allDrugNames = <String>[].obs;
  final suggestions = <String>[].obs;
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
      final names = await repository.fetchAllDrugNames();
      allDrugNames.assignAll(names);
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
    final matches = allDrugNames
        .where((n) => n.toLowerCase().contains(q))
        .take(10)
        .toList();
    suggestions.assignAll(matches);
  }

  void addSelected(String name) {
    if (!selected.contains(name)) selected.add(name);
    searchController.clear();
    focusNode.requestFocus();
    suggestions.clear();
  }

  void removeSelectedAt(int index) => selected.removeAt(index);
}
