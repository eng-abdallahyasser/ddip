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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    if (c.selectedDrugs.isEmpty || c.suggestions.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: List.generate(
                        c.selectedDrugs.length,
                        (i) => Chip(
                          label: Text(
                            c.selectedDrugs[i].enName 
                          ),
                          onDeleted: () => c.removeSelectedAt(i),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Interactions list
                  Obx(() {
                    if (c.interactionsFounded.isEmpty || c.suggestions.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interactions found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: c.interactionsFounded.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final it = c.interactionsFounded[idx];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  '${it.activeIngredientA} ↔ ${it.activeIngredientB}',
                                ),
                                subtitle: Text(it.description),
                                trailing: Text(
                                  it.severity.toString().split('.').last,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Obx(() {
                      if (c.allDrugs.isEmpty) {
                        return const Center(child: Text('Loading...'));
                      }
                      if (c.suggestions.isEmpty && c.selectedDrugs.isEmpty) {
                        return Center(child: Text('No suggestions found, ${c.allDrugs.length} drugs available.'));
                      }
                      return ListView.builder(
                        itemCount: c.suggestions.length,
                        itemBuilder: (context, i) {
                          final drug = c.suggestions[i];
                          final title =
                              (drug.enName?.toString().isNotEmpty ?? false)
                              ? drug.enName
                              : drug.arName;
                          final subtitle =
                              (drug.arName?.toString().isNotEmpty ?? false)
                              ? drug.arName
                              : null;
                          return Card(
                            child: ListTile(
                              title: Text(title ?? ''),
                              subtitle: subtitle != null
                                  ? Text(subtitle)
                                  : null,
                              onTap: () => c.addSelected(drug),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
