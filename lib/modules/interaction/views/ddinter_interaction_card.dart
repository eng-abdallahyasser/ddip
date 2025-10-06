

import 'package:ddip/models/drug_interaction.dart';
import 'package:flutter/material.dart';

class DDInterInteractionCard extends StatelessWidget {
  final DrugInteraction interaction;
  final VoidCallback? onTap;
  final bool isExpanded;

  const DDInterInteractionCard({
    super.key,
    required this.interaction,
    this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(
              color: interaction.severity.color,
              width: 6,
            )),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isExpanded 
                ? _buildExpandedView()
                : _buildCompactView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with drugs and severity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: interaction.severity.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: interaction.severity.color),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    interaction.severity.icon,
                    size: 16,
                    color: interaction.severity.textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    interaction.severity.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: interaction.severity.textColor,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Evidence level
            if (interaction.evidenceLevel.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  interaction.evidenceLevel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Drug names
        Text(
          '${interaction.activeIngredientA} + ${interaction.activeIngredientB}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Risk level and tap hint
        Text(
          interaction.severity.riskDescription,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),
        
        const SizedBox(height: 16),
        
        // Description
        _buildSection('Interaction Description', interaction.description),
        
        const SizedBox(height: 12),
        
        // Mechanism
        if (interaction.mechanism.isNotEmpty)
          Column(
            children: [
              _buildSection('Mechanism', interaction.mechanism),
              const SizedBox(height: 12),
            ],
          ),
        
        // Management
        if (interaction.management.isNotEmpty)
          Column(
            children: [
              _buildSection('Management', interaction.management),
              const SizedBox(height: 12),
            ],
          ),
        
        // Footer with IDs and evidence
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severity badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: interaction.severity.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: interaction.severity.color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                interaction.severity.icon,
                size: 20,
                color: interaction.severity.textColor,
              ),
              const SizedBox(width: 8),
              Text(
                interaction.severity.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: interaction.severity.textColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Evidence level
        if (interaction.evidenceLevel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Evidence: ${interaction.evidenceLevel}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DDInter IDs:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${interaction.ddInterIdA} • ${interaction.ddInterIdB}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            interaction.severity.riskDescription,
            style: TextStyle(
              fontSize: 12,
              color: interaction.severity.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}