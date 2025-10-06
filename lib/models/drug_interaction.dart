import 'package:flutter/material.dart';

enum InteractionSeverity { major, moderate, minor, unknown }

class DrugInteraction {
  final String ddInterIdA;
  final String ddInterIdB;
  final String activeIngredientA;
  final String activeIngredientB;
  final InteractionSeverity severity;
  final String description;
  final String mechanism;
  final String management;
  final String evidenceLevel;

  DrugInteraction({
    required this.ddInterIdA,
    required this.ddInterIdB,
    required this.activeIngredientA,
    required this.activeIngredientB,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.management,
    required this.evidenceLevel,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    InteractionSeverity parseSeverity(String? s) {
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

    return DrugInteraction(
      ddInterIdA: json['drugAId']?.toString() ?? '',
      ddInterIdB: json['drugBId']?.toString() ?? '',
      activeIngredientA: json['activeIngredientA']?.toString() ?? '',
      activeIngredientB: json['activeIngredientB']?.toString() ?? '',
      severity: parseSeverity(json['severity']?.toString()),
      description: json['description']?.toString() ?? '',
      mechanism: json['mechanism']?.toString() ?? '',
      management: json['management']?.toString() ?? '',
      evidenceLevel: json['evidenceLevel']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    String severityToString(InteractionSeverity s) {
      switch (s) {
        case InteractionSeverity.major:
          return 'major';
        case InteractionSeverity.moderate:
          return 'moderate';
        case InteractionSeverity.minor:
          return 'minor';
        case InteractionSeverity.unknown:
          return 'unknown';
      }
    }

    return {
      'ddInterIdA': ddInterIdA,
      'ddInterIdB': ddInterIdB,
      'drugA': activeIngredientA,
      'drugB': activeIngredientB,
      'severity': severityToString(severity),
      'description': description,
      'mechanism': mechanism,
      'management': management,
      'evidenceLevel': evidenceLevel,
    };
  }
}

extension InteractionSeverityExtension on InteractionSeverity {
  String get displayName {
    switch (this) {
      case InteractionSeverity.major:
        return 'Major';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.minor:
        return 'Minor';
      case InteractionSeverity.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case InteractionSeverity.major:
        return Colors.red;
      case InteractionSeverity.moderate:
        return Colors.orange;
      case InteractionSeverity.minor:
        return Colors.blue;
      case InteractionSeverity.unknown:
        return Colors.grey;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case InteractionSeverity.major:
        return Colors.red.shade50;
      case InteractionSeverity.moderate:
        return Colors.orange.shade50;
      case InteractionSeverity.minor:
        return Colors.blue.shade50;
      case InteractionSeverity.unknown:
        return Colors.grey.shade50;
    }
  }

  Color get textColor {
    switch (this) {
      case InteractionSeverity.major:
        return Colors.red.shade900;
      case InteractionSeverity.moderate:
        return Colors.orange.shade900;
      case InteractionSeverity.minor:
        return Colors.blue.shade900;
      case InteractionSeverity.unknown:
        return Colors.grey.shade900;
    }
  }

  IconData get icon {
    switch (this) {
      case InteractionSeverity.major:
        return Icons.warning_amber_rounded;
      case InteractionSeverity.moderate:
        return Icons.warning_amber_outlined;
      case InteractionSeverity.minor:
        return Icons.info_outlined;
      case InteractionSeverity.unknown:
        return Icons.help_outline;
    }
  }

  String get riskDescription {
    switch (this) {
      case InteractionSeverity.major:
        return 'High risk - Avoid combination';
      case InteractionSeverity.moderate:
        return 'Moderate risk - Use with caution';
      case InteractionSeverity.minor:
        return 'Low risk - Monitor therapy';
      case InteractionSeverity.unknown:
        return 'Risk level not specified';
    }
  }
}
