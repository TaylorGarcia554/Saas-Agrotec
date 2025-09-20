import 'package:flutter/material.dart';

class Analysis {
  final int id;
  final double ctc;
  final double potassio;
  final double result;
  final String kctc;

  Analysis({
    required this.id,
    required this.ctc,
    required this.potassio,
    required this.result,
    required this.kctc,
  });
}

class AnalysisTable extends StatelessWidget {
  final List<Analysis> analyses;
  const AnalysisTable({Key? key, required this.analyses}) : super(key: key);

  Color _resultColor(double value) {
    // Ajuste essa lógica conforme significado do seu "resultado".
    // if (value.abs() < 0.0001) return Colors.black87;
    // if (value > 0) return Colors.red.shade700; // exemplo: destaque em vermelho
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // "folha"
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal, // permite rolagem horizontal se necessário
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith(
            (_) => Colors.grey.shade200,
          ),
          dividerThickness: 0.5,
          columns: const [
            DataColumn(label: Text('Análise')),
            DataColumn(label: Text('CTC (T)')),
            DataColumn(label: Text('V %')),
            DataColumn(label: Text('Resultado (t/ha)')),
            DataColumn(label: Text('K/CTC')),
          ],
          rows: List<DataRow>.generate(analyses.length, (index) {
            final a = analyses[index];
            return DataRow(
              cells: [
                DataCell(Text('#${index + 1}')),
                DataCell(Text(a.ctc.toStringAsFixed(2))),
                DataCell(Text(a.potassio.toStringAsFixed(2))),
                DataCell(
                  Text(
                    a.result.toStringAsFixed(3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _resultColor(a.result),
                    ),
                  ),
                ),
                DataCell(Text(a.kctc)),
              ],
            );
          }),
        ),
      ),
    );
  }
}
