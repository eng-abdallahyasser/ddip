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
              ),
            ),
            const SizedBox(height: 8),

            // Selected drugs
            Obx(
              () => c.selected.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: c.selected.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => Chip(
                          label: Text(c.selected[i]),
                          onDeleted: () => c.removeSelectedAt(i),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 8),

            // Suggestions
            Expanded(
              child: Obx(() {
                if (c.allDrugNames.isEmpty)
                  return const Center(child: Text('Loading...'));
                if (c.suggestions.isEmpty)
                  return const Center(child: Text('No suggestions'));
                return ListView.builder(
                  itemCount: c.suggestions.length,
                  itemBuilder: (context, i) {
                    final name = c.suggestions[i];
                    return Card(
                      child: ListTile(
                        title: Text(name),
                        onTap: () => c.addSelected(name),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
