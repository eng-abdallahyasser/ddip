import 'package:ddip/models/drug.dart';
import 'package:flutter/material.dart';

class DrugCardWidget extends StatelessWidget {
  final Drug drug;
  final Function() onDeleted;

  const DrugCardWidget({super.key, required this.drug, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(drug.enName),
        subtitle: Text(drug.activeIngredients.join(", ") ,style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.close_rounded, size: 24),
        onTap: onDeleted,
      ),
    );
  }
}