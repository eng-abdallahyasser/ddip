import 'package:ddip/services/open_fda_service.dart';
import 'package:flutter/material.dart';

class OpenFDAInteractionResultCard extends StatelessWidget {
  final OpenFDAInteractionResult interactionResult;
  final VoidCallback? onTap;
  final bool showDrugInfo;

  const OpenFDAInteractionResultCard({
    super.key,
    required this.interactionResult,
    this.onTap,
    this.showDrugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drug names and interaction count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${interactionResult.drug1Name} ↔ ${interactionResult.drug2Name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getInteractionColor(interactionResult),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      interactionResult.found
                          ? '${interactionResult.interactions.length} interactions'
                          : 'No interactions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status message or first interaction preview
              if (interactionResult.message != null)
                Text(
                  interactionResult.message!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                )
              else if (interactionResult.found &&
                  interactionResult.interactions.isNotEmpty)
                Text(
                  interactionResult.interactions.first,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              // Drug information if available and requested
              if (showDrugInfo && _hasDrugInfo(interactionResult))
                _buildDrugInfoSection(interactionResult),

              // Show more indicator if there are multiple interactions
              if (interactionResult.interactions.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${interactionResult.interactions.length - 1} more interaction${interactionResult.interactions.length > 2 ? 's' : ''}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugInfoSection(OpenFDAInteractionResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        const Text(
          'Drug Information:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (result.drug1Info != null)
          _buildDrugInfoItem(result.drug1Name, result.drug1Info!),
        if (result.drug2Info != null)
          _buildDrugInfoItem(result.drug2Name, result.drug2Info!),
      ],
    );
  }

  Widget _buildDrugInfoItem(String drugName, DrugOpenFDAInfo info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$drugName: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              _getDrugInfoSummary(info),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getDrugInfoSummary(DrugOpenFDAInfo info) {
    final List<String> details = [];
    if (info.brandName != null) details.add('Brand: ${info.brandName}');
    if (info.genericName != null) details.add('Generic: ${info.genericName}');
    return details.join(', ');
  }

  bool _hasDrugInfo(OpenFDAInteractionResult result) {
    return result.drug1Info != null || result.drug2Info != null;
  }

  Color _getInteractionColor(OpenFDAInteractionResult result) {
    if (!result.found) {
      return Colors.green;
    } else if (result.interactions.length == 1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// Usage example:
class InteractionResultsList extends StatelessWidget {
  final List<OpenFDAInteractionResult> interactions;

  const InteractionResultsList({super.key, required this.interactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: interactions.length,
      itemBuilder: (context, index) {
        final interaction = interactions[index];
        return OpenFDAInteractionResultCard(
          interactionResult: interaction,
          onTap: () {
            // Handle tap to show detailed view
            _showInteractionDetails(context, interaction);
          },
          showDrugInfo: true,
        );
      },
    );
  }

  void _showInteractionDetails(
    BuildContext context,
    OpenFDAInteractionResult interaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${interaction.drug1Name} ↔ ${interaction.drug2Name}'),
        content: interaction.found
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found ${interaction.interactions.length} interaction(s):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...interaction.interactions.map(
                    (interactionText) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• $interactionText'),
                    ),
                  ),
                ],
              )
            : Text(interaction.message ?? 'No interactions found'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
