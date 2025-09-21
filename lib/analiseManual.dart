import 'package:agrotec/utils/analyses.dart';
import 'package:agrotec/utils/cor.dart';
import 'package:flutter/material.dart';

class ManualAnalysisScreen extends StatefulWidget {
  const ManualAnalysisScreen({super.key});

  @override
  State<ManualAnalysisScreen> createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen> {
  final TextEditingController _nomeArquivoController = TextEditingController();
  final TextEditingController _ctcController = TextEditingController();
  final TextEditingController _vPercentController = TextEditingController();
  final TextEditingController _kctcController = TextEditingController();

  List<Analysis> _analyses = [];
  String? _fileName;

  double resultado = 0.0;

  void _adicionarAnalise() {
    if (_fileName == null || _fileName!.isEmpty) {
      final nomeArquivo = _nomeArquivoController.text.trim();
      if (nomeArquivo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informe o nome do arquivo")),
        );
        return;
      }
      setState(() {
        _fileName = nomeArquivo;
      });
    }

    final ctc = double.tryParse(_ctcController.text.replaceAll(',', '.')) ?? 0;
    final vPercent =
        double.tryParse(_vPercentController.text.replaceAll(',', '.')) ?? 0;
    final kctc = _kctcController.text.trim();

    double result = (vPercent < 60)
        ? (60 - vPercent) * ctc / 100
        : (vPercent - 60) * ctc / 100;

    resultado = double.parse(result.toStringAsFixed(2));

    setState(() {
      _analyses.add(
        Analysis(
          nomeArquivo: _fileName!,
          id: _analyses.length + 1,
          ctc: ctc,
          potassio: vPercent,
          result: resultado,
          kctc: classifyKCTC(double.tryParse(kctc.replaceAll(',', '.'))),
        ),
      );

      // limpa os campos de input, menos o nome do arquivo
      _ctcController.clear();
      _vPercentController.clear();
      _kctcController.clear();
    });
  }

  void _resetarTudo() {
    setState(() {
      _fileName = null;
      _analyses.clear();
      _nomeArquivoController.clear();
      _ctcController.clear();
      _vPercentController.clear();
      _kctcController.clear();
    });
  }

  String classifyKCTC(double? k) {
    if (k == null) return 'Unknown';
    if (k < 3) return '1.00.1';
    if (k >= 3 && k < 4) return '1.5.0';
    if (k >= 4 && k < 6) return '2.00.1';
    return '3.00.1';
  }

  @override
  void dispose() {
    _nomeArquivoController.dispose();
    _ctcController.dispose();
    _vPercentController.dispose();
    _kctcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modo Manual - Análises")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INPUTS SUPERIORES ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeArquivoController,
                    enabled: _fileName == null, // só pode editar uma vez
                    decoration: InputDecoration(
                      labelText: "Nome do arquivo",
                      labelStyle: TextStyle(
                        color: Cor.verdeForte,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Cor.verdeForte,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Cor.verdeForte,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ctcController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "CTC (T)",
                      labelStyle:  TextStyle(
                        color: Cor.verdeForte,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Cor.verdeForte,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          // color: Color(0xff8f5c30),
                          color: Cor.verdeForte,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _vPercentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "V %",
                      labelStyle: TextStyle(
                        color: Cor.verdeForte,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:  BorderSide(
                          color: Cor.verdeForte,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:  BorderSide(
                          color: Cor.verdeForte,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _kctcController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "K CTC",
                      labelStyle: TextStyle(
                        color: Cor.verdeForte,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:  BorderSide(
                          color: Cor.verdeForte,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Cor.verdeForte,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // colors: [Color(0xff8f5c30), Color(0xffdba85e)],
                      colors: [Cor.verdeForte, Cor.verdeCinza],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _adicionarAnalise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Calcular",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 245, 60, 57),
                        Color(0xffb71c1c),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _resetarTudo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Resetar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- NOME DO ARQUIVO ACIMA DA TABELA ---
            if (_fileName != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _fileName!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          // Aqui você pode chamar a função de gerar PDF
                          // BaixarPDF().gerarPDF(_analyses, _fileName!);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.download,
                                size: 16,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Baixar PDF",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            // --- TABELA DE ANALISES ---
            Expanded(child: AnaliseTable(analyses: _analyses)),
          ],
        ),
      ),
    );
  }
}
