import 'package:agrotec/utils/analyses.dart';
import 'package:flutter/material.dart';

class DetalhesCard extends StatelessWidget {
  final int index;
  final Analysis analysis;
  const DetalhesCard({super.key, required this.index, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Análise ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('T: ${analysis.ctc}  V: ${analysis.potassio}'),
            Text(
              'Resultado: ${analysis.result.toStringAsFixed(2)} t/ha  KCTC: ${analysis.kctc}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
