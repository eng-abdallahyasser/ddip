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
            // Suggestions
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Obx(
                                  () => c.selected.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          itemCount: c.selected.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) => Chip(
                            
                            label: Text(c.selected[i]),
                            onDeleted: () => c.removeSelectedAt(i),
                          ),
                        ),
                      ),
                                ),
                  ),
                  Obx(() {
                    if (c.allDrugs.isEmpty) {
                      return const Center(child: Text('Loading...'));
                    }
                    if (c.suggestions.isEmpty) {
                      return Text('No suggestions');
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
                            subtitle: subtitle != null ? Text(subtitle) : null,
                            onTap: () => c.addSelected(drug),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
