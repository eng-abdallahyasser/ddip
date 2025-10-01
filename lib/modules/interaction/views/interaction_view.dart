import 'package:ddip/modules/interaction/views/drug_card_widget.dart';
import 'package:ddip/modules/interaction/views/gemini_feedback_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/interaction_controller.dart';

class InteractionView extends StatelessWidget {
  const InteractionView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InteractionController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Interaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: c.searchController,
              focusNode: c.focusNode,
              decoration: const InputDecoration(
                labelText: 'Search drugs by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // Selected drugs and suggestions
            Expanded(
              child: Obx(() {
                if (c.allDrugs.isEmpty) {
                  return Text('Loading...');
                }

                if (c.suggestions.isEmpty && c.selectedDrugs.isEmpty) {
                  return Text(
                    'No suggestions found, ${c.allDrugs.length} drugs available.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    // Selected drugs section
                    if (c.selectedDrugs.isNotEmpty && c.suggestions.isEmpty)
                      ...c.selectedDrugs.map(
                        (drug) => DrugCardWidget(
                          drug: drug,
                          onDeleted: () => c.removeSelectedAt(c.selectedDrugs.indexOf(drug)),
                        ),
                      ),
                    // Interactions section
                    if (c.interactionsFounded.isNotEmpty &&
                        c.suggestions.isEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Interactions found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...c.interactionsFounded.map(
                        (it) => Card(
                          child: ListTile(
                            title: Text(
                              '${it.activeIngredientA} ↔ ${it.activeIngredientB}',
                            ),
                            subtitle: Text(it.description),
                            trailing: Text(
                              it.severity.toString().split('.').last,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (c.geminiFeedback.value.isNotEmpty &&
                        c.suggestions.isEmpty)
                      GeminiFeedbackWidget(text: c.geminiFeedback.value),

                    // Suggestions list
                    if (c.suggestions.isNotEmpty)
                      ...c.suggestions.map((drug) {
                        final title = (drug.enName?.isNotEmpty ?? false)
                            ? drug.enName
                            : drug.arName;
                        final subtitle = (drug.arName?.isNotEmpty ?? false)
                            ? drug.arName
                            : null;
                        return Card(
                          key: ValueKey('suggestion_${drug.id ?? drug.enName}'),
                          child: ListTile(
                            title: Text(title ?? 'No name'),
                            subtitle: subtitle != null ? Text(subtitle) : null,
                            onTap: () => c.addSelected(drug),
                          ),
                        );
                      }),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
