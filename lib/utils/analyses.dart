import 'package:flutter/material.dart';

class Analysis {
  final int id;
  final double ctc;
  final double potassio;
  final double result;
  String kctc;

  double? valorDigitado;
  double? resultadoPersonalizado;
  String? nomeArquivo;

  Analysis({
    required this.id,
    required this.ctc,
    required this.potassio,
    required this.result,
    required this.kctc,
    this.valorDigitado,
    this.resultadoPersonalizado,
    this.nomeArquivo,
  });

  // Construtor para criar a partir do banco
  factory Analysis.fromMap(Map<String, dynamic> map) {
    return Analysis(
      id: map['id'] as int,
      ctc: (map['ctc'] as num).toDouble(),
      potassio: (map['potassio'] as num).toDouble(),
      result: (map['resultado'] as num).toDouble(),
      kctc: map['kctc'] as String,
    );
  }

  // Para salvar no banco novamente
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ctc': ctc,
      'potassio': potassio,
      'resultado': result,
      'kctc': kctc,
    };
  }
}

class AnaliseTable extends StatefulWidget {
  final List<Analysis> analyses;
  const AnaliseTable({super.key, required this.analyses});

  @override
  State<AnaliseTable> createState() => _AnaliseTableState();
}

class _AnaliseTableState extends State<AnaliseTable> {
  bool editMode = false;
  final Map<int, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.analyses.length; i++) {
      controllers[i] = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(covariant AnaliseTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (int i = 0; i < widget.analyses.length; i++) {
      controllers[i] ??= TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _salvarValores() {
    setState(() {
      for (int i = 0; i < widget.analyses.length; i++) {
        final text = controllers[i]!.text;
        if (text.isNotEmpty) {
          final valorDigitado = double.tryParse(text.replaceAll(',', '.')) ?? 0;

          if (valorDigitado > 0) {
            // Converte t/ha para g/ha e divide pelo valor digitado
            widget.analyses[i].resultadoPersonalizado =
                (widget.analyses[i].result * 1000000) / valorDigitado;
          } else {
            widget.analyses[i].resultadoPersonalizado = 0;
          }
        }
      }
      editMode = false;
    });
  }

  Color _resultColor(double value) {
    // if (value < 0) return Colors.red;
    // if (value < 20) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    return Column(
      children: [
        // Botão Editar/Salvar
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff8f5c30), Color(0xffdba85e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (editMode) {
                  _salvarValores();
                } else {
                  setState(() => editMode = true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                editMode ? "Salvar" : "Editar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith(
                  (_) => Colors.grey.shade200,
                ),
                dividerThickness: 0.5,
                columns: const [
                  DataColumn(label: Text('Análise')),
                  DataColumn(label: Text('CTC (T)')),
                  DataColumn(label: Text('V %')),
                  DataColumn(label: Text('Resultado (t/ha)')),
                  DataColumn(label: Text('K/CTC')),
                  DataColumn(label: Text('Manual')), // coluna editável
                  DataColumn(
                    label: Text('Dose por Planta (g/ha)'),
                  ), // resultado calculado
                ],
                rows: List<DataRow>.generate(widget.analyses.length, (index) {
                  final a = widget.analyses[index];
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
                      // DataCell(Text(a.kctc)),
                      DataCell(
                        editMode
                            ? SizedBox(
                                width: 100, // largura fixa pra ficar bonitinho
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: a.kctc, // valor atual selecionado
                                  items:
                                      [
                                            '1.00.1',
                                            '1.5.0',
                                            '2.00.1',
                                            '3.00.1',
                                          ] // coloque os valores que quiser
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        a.kctc =
                                            val; // atualiza o valor da análise
                                      });
                                    }
                                  },
                                ),
                              )
                            : Text(a.kctc), // modo normal
                      ),
                      DataCell(
                        editMode
                            ? SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: controllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Digite...",
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      a.valorDigitado = double.tryParse(
                                        val.replaceAll(',', '.'),
                                      );
                                    }); // atualiza o estado
                                  },
                                ),
                              )
                            : Text(
                                controllers[index]?.text.isEmpty ?? true
                                    ? "-"
                                    : controllers[index]!.text,
                              ),
                      ),
                      DataCell(
                        Text(
                          a.resultadoPersonalizado != null
                              ? "${a.resultadoPersonalizado!.toStringAsFixed(2)} g/ha"
                              : '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: a.resultadoPersonalizado != null
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class AnalysisTable extends StatelessWidget {
//   final List<Analysis> analyses;
//   const AnalysisTable({Key? key, required this.analyses}) : super(key: key);

//   Color _resultColor(double value) {
//     // Ajuste essa lógica conforme significado do seu "resultado".
//     // if (value.abs() < 0.0001) return Colors.black87;
//     // if (value > 0) return Colors.red.shade700; // exemplo: destaque em vermelho
//     return Colors.green.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white, // "folha"
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
//         ],
//       ),
//       child: SingleChildScrollView(
//         scrollDirection:
//             Axis.horizontal, // permite rolagem horizontal se necessário
//         child: DataTable(
//           headingRowColor: MaterialStateProperty.resolveWith(
//             (_) => Colors.grey.shade200,
//           ),
//           dividerThickness: 0.5,
//           columns: const [
//             DataColumn(label: Text('Análise')),
//             DataColumn(label: Text('CTC (T)')),
//             DataColumn(label: Text('V %')),
//             DataColumn(label: Text('Resultado (t/ha)')),
//             DataColumn(label: Text('K/CTC')),
//           ],
//           rows: List<DataRow>.generate(analyses.length, (index) {
//             final a = analyses[index];
//             return DataRow(
//               cells: [
//                 DataCell(Text('#${index + 1}')),
//                 DataCell(Text(a.ctc.toStringAsFixed(2))),
//                 DataCell(Text(a.potassio.toStringAsFixed(2))),
//                 DataCell(
//                   Text(
//                     a.result.toStringAsFixed(3),
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: _resultColor(a.result),
//                     ),
//                   ),
//                 ),
//                 DataCell(Text(a.kctc)),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
