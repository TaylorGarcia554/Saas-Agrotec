import 'dart:io';
import 'package:agrotec/components/showMessager.dart';
import 'package:agrotec/utils/analyses.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BaixarPDF {
  // Função para gerar PDF
  Future<void> gerarPDF(
    List<Analysis> analyses,
    String namePDF,
    BuildContext context,
  ) async {
    // Cria um documento PDF
    final pdf = pw.Document();

    // Adiciona uma página
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Formato A4 padrão
        margin: const pw.EdgeInsets.all(
          24,
        ), // Margem de 24 pts em todos os lados
        build: (context) {
          return pw.Stack(
            children: [
              // Fundo da página
              pw.Container(
                width: double.infinity,
                height: double.infinity,
                // cor de fundo da "folha"
              ),

              // Conteúdo principal
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  pw.Text(
                    'Relatório de Análises',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  pw.SizedBox(height: 24),
                  pw.Text(
                    namePDF, // variável com o nome do PDF
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),

                  // Tabela
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white, // "folha" da tabela
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                      // boxShadow: [
                      //   pw.BoxShadow(
                      //     color: PdfColors.black,
                      //     blurRadius: 4,
                      //     offset: const PdfPoint(0, 2),
                      //   ),
                      // ],
                    ),
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Table(
                      border: pw.TableBorder(
                        horizontalInside: pw.BorderSide(
                          color: PdfColors.grey400,
                          width: 0.5,
                        ),
                        bottom: pw.BorderSide(color: PdfColors.grey400),
                      ),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(1), // Análise
                        1: pw.FlexColumnWidth(1), // CTC
                        2: pw.FlexColumnWidth(1), // V%
                        3: pw.FlexColumnWidth(1), // Resultado
                        4: pw.FlexColumnWidth(1), // K/CTC
                        5: pw.FlexColumnWidth(1), // Personalizado
                        6: pw.FlexColumnWidth(1), // Valor Digitado
                      },
                      children: [
                        // Cabeçalho da tabela
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(
                                'Análise',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(
                                'CTC (T)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(
                                'V %',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(
                                'Resultado (t/ha)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(
                                'K/CTC',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(
                                'Plantas',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text(
                                'Dose por Planta (g/ha)',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Linhas da tabela
                        ...List<pw.TableRow>.generate(analyses.length, (index) {
                          final a = analyses[index];

                          // Função para cor do resultado (igual Flutter)
                          PdfColor resultColor(double value) {
                            // if (value < 0) return PdfColors.red;
                            // if (value < 10) return PdfColors.orange;
                            return PdfColors.green;
                          }

                          return pw.TableRow(
                            decoration:
                                const pw.BoxDecoration(), // pode alternar cores aqui se quiser
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text('#${index + 1}'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(a.ctc.toStringAsFixed(2)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(a.potassio.toStringAsFixed(2)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  a.result.toStringAsFixed(3),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: resultColor(a.result),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(a.kctc),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  a.valorDigitado != null
                                      ? a.valorDigitado!.toStringAsFixed(2)
                                      : '-',
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  a.resultadoPersonalizado != null
                                      ? '${a.resultadoPersonalizado!.toStringAsFixed(2)} g/ha'
                                      : '-',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await _savePdf(pdf, namePDF);
    showCustomMessage(
      context,
      "PDF salvo com sucesso!",
      type: MessageType.success,
    );
    print('PDF gerado com sucesso!');
  }

  // Função interna para salvar o PDF em pasta escolhida
  Future<void> _savePdf(pw.Document pdf, String namePDF) async {
    // Converte para bytes
    final pdfBytes = await pdf.save();

    // Escolher pasta no desktop
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final fullPath = '$selectedDirectory/$namePDF - analise.pdf';
      final file = File(fullPath);
      await file.writeAsBytes(pdfBytes);
      print('PDF salvo em: $fullPath');
      // TODO: fazer um provider para poder mostrar mensagem esta baixando, ja baixou e tauz..
    } else {
      print('Usuário cancelou a escolha da pasta.');
    }
  }
}
