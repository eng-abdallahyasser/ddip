import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import '../models/drug_interaction.dart';

/// Reads a CSV file from assets/data/ and returns a list of DrugInteraction objects.
Future<List<DrugInteraction>> importDrugInteractionsFromCsv(
  String assetPath,
) async {
  final raw = await rootBundle.loadString(assetPath);
  final lines = LineSplitter.split(raw).toList();
  if (lines.isEmpty) return [];

  // Assume first line is header
  final headers = lines.first.split(',').map((h) => h.trim()).toList();
  final interactions = <DrugInteraction>[];

  for (final line in lines.skip(1)) {
    final cols = line.split(',').map((c) => c.trim()).toList();
    if (cols.length != headers.length) continue;
    final map = <String, String>{};
    for (var i = 0; i < headers.length; i++) {
      map[headers[i]] = cols[i];
    }
    interactions.add(
      DrugInteraction(
        ddInterIdA: map['DDInterID_A'] ?? '',
        ddInterIdB: map['DDInterID_B'] ?? '',
        activeIngredientA: map['Drug_A'] ?? '',
        activeIngredientB: map['Drug_B'] ?? '',
        severity: _parseSeverity(map['Level'] ?? ''),
        description: map['description'] ?? '',
        mechanism: map['mechanism'] ?? '',
        management: map['management'] ?? '',
        evidenceLevel: map['evidenceLevel'] ?? '',
      ),
    );
  }
  log('Imported ${interactions.length} interactions from $assetPath');
  log('ex :${interactions[15].toMap()}');
  return interactions;
}

InteractionSeverity _parseSeverity(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'major':
      return InteractionSeverity.major;
    case 'moderate':
      return InteractionSeverity.moderate;
    case 'minor':
      return InteractionSeverity.minor;
    default:
      return InteractionSeverity.unknown;
  }
}
