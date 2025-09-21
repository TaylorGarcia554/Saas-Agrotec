import 'dart:io';
import 'dart:typed_data';
import 'package:agrotec/components/detalhes.dart';
import 'package:agrotec/components/showMessager.dart';
import 'package:agrotec/utils/analyses.dart';
import 'package:agrotec/utils/calculos.dart';
import 'package:agrotec/utils/cor.dart';
import 'package:agrotec/utils/salvarPDF.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // Para ler PDF
import 'package:path/path.dart' as p;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<String> selectedFileNames = [];
  List<String> selectedFilePaths = [];
  bool isAnalyzing = false;

  // Guardar resultados de todos os PDFs
  Map<String, List<Analysis>> analysesPorArquivo = {};
  List extractedText = [];

  final Calculos calculos = Calculos();

  Future<void> handleFileSelect() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true, // 👈 agora dá pra pegar vários
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        // selectedFileNames = result.files.map((f) => f.name).toList();
        selectedFileNames = result.files
            .map((f) => p.basenameWithoutExtension(f.name)) // 👈 só o nome
            .toList();
        selectedFilePaths = result.files
            .where((f) => f.path != null)
            .map((f) => f.path!)
            .toList();
      });
    } else {
      print('Nenhum arquivo selecionado');
    }
  }

  Future<void> analyzeSelectedPdfs() async {
    if (selectedFilePaths.isEmpty) return;

    setState(() => isAnalyzing = true);

    try {
      for (int i = 0; i < selectedFilePaths.length; i++) {
        final fileName = selectedFileNames[i];
        final filePath = selectedFilePaths[i];

        final pdfBytes = await File(filePath).readAsBytes();
        final pdfDoc = PdfDocument(inputBytes: pdfBytes);
        final extractor = PdfTextExtractor(pdfDoc);
        final text = extractor.extractTextLines(
          startPageIndex: 0,
          endPageIndex: pdfDoc.pages.count - 1,
        );
        pdfDoc.dispose();

        final analyses = calculos.processTextLines(text, fileName);

        setState(() {
          analysesPorArquivo[fileName] = analyses;
        });
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Análises concluídas com sucesso!')),
      // );
      showCustomMessage(
        context,
        'Análises concluídas com sucesso!',
        type: MessageType.success,
      ); // TODO: trocar depois o lugar onde você quer que apareça a mensagem ( precisa ser no MenuHome para nao bugar )
    } catch (e) {
      print("Erro ao analisar PDFs: $e");
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Erro ao analisar PDFs.')));
      showCustomMessage(
        context,
        'Erro ao analisar os PDFs.',
        type: MessageType.error,
      );
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  // Função que lê o PDF e retorna todo o texto em formato String
  String extractTextFromPdf(Uint8List pdfBytes) {
    final PdfDocument pdfDoc = PdfDocument(inputBytes: pdfBytes);
    final PdfTextExtractor extractor = PdfTextExtractor(pdfDoc);

    // Aqui estamos extraindo o texto completo do PDF (todas as páginas)
    final String text = extractor.extractText(
      startPageIndex: 0,
      endPageIndex: pdfDoc.pages.count - 1,
      layoutText: true, // preserva um pouco do layout original
    );

    pdfDoc.dispose();
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [Color(0xff8f5c30), Color(0xFFE9ECEF)],
            colors: [Cor.verdeForte, Cor.brancoVerde],
            stops: [0.001, 0.16],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xff38291a),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Analisar por PDFs",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Text(
                "Faça upload do seu arquivo PDF e obtenha análises detalhadas em segundos",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedFileNames.isEmpty) ...[
                        Row(
                          children: [
                             Icon(
                              Icons.upload_file,
                              size: 64,
                              // color: Color(0xff38291a),
                              color: Cor.verdeClaro,
                            ),
                            const SizedBox(height: 16),

                            // Se não tiver arquivo selecionado, mostra instruções
                            const Text(
                              "Selecione um arquivo PDF",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // ElevatedButton.icon(
                        //   onPressed: handleFileSelect,
                        //   icon: const Icon(Icons.file_present),
                        //   label: const Text("Escolher Arquivo"),
                        //   style: ElevatedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 24,
                        //       vertical: 14,
                        //     ),
                        //     textStyle: const TextStyle(fontSize: 16),
                        //     backgroundColor: const Color(0xff8f5c30),
                        //   ),
                        // ),
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
                          child: ElevatedButton.icon(
                            onPressed: handleFileSelect,
                            icon: const Icon(
                              Icons.file_present,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Escolher Arquivo",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // importante
                              shadowColor:
                                  Colors.transparent, // remove sombra padrão
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                      // Se já tiver arquivo, mostra info + 2 botões lado a lado
                      if (selectedFileNames.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Coluna com informações do arquivo
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Arquivo selecionado:",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                // Text(
                                //   selectedFileNames ?? "",
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                ...selectedFileNames.map(
                                  (name) => Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(), // empurra os botões pro canto direito
                            // Coluna com os botões, um embaixo do outro
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: isAnalyzing
                                      ? null
                                      : () async {
                                          setState(() {
                                            isAnalyzing = true;
                                            analysesPorArquivo = {};
                                          });
                                          await analyzeSelectedPdfs();
                                          setState(() {
                                            isAnalyzing = false;
                                          });
                                        },
                                  child: Text(
                                    isAnalyzing
                                        ? "Analisando..."
                                        : "Iniciar Análise",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: handleFileSelect,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown.shade100,
                                    foregroundColor: Colors.black87,
                                  ),
                                  child: const Text("Selecionar outro PDF"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // if (analyses.isNotEmpty) AnalysisTable(analyses: analyses),
              if (analysesPorArquivo.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: analysesPorArquivo.entries.map((entry) {
                    final fileName = entry.key;
                    final analyses = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do PDF acima da tabela
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox.shrink(),
                            InkWell(
                              onTap: () {
                                // Chame aqui a função para salvar o PDF
                                BaixarPDF().gerarPDF(
                                  analyses,
                                  fileName,
                                  context,
                                );
                                // TODO: Fazer aparecer uma notificacao de que esta baixando, baixado ou erro.
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.download,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
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

                        // Aqui entra sua tabela
                        AnaliseTable(analyses: analyses),

                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
