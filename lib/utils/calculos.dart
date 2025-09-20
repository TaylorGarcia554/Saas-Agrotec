import 'package:agrotec/utils/analyses.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class Calculos {
  // Processa o texto para extrair apenas CTC, V% e K
  List<Analysis> processTextLines(List<TextLine> lines) {
    List<Analysis> resultList = [];

    List<double> ctcValues = [];
    List<double> vValues = [];
    List<double> kctcValues = [];

    for (var line in lines) {
      final text = line.text.trim();

      // ---- CTC ----
      if ((text.contains('CTC (T)') ||
              text.contains('C.T.C.') ||
              text.contains('(C.T.C)')) &&
          // Bloqueia linhas que contenham "% ... C.T.C."
          !RegExp(r'%.*C\.?T\.?C').hasMatch(text)) {
        final nums = extractNumbers(text);
        if (nums.isNotEmpty) {
          ctcValues.addAll(nums);
          print("CTC encontrado: $nums | Linha: $text");
        }
      }

      // ---- V% ----
      if (text.contains('V%') ||
          text.contains('V %') ||
          text.contains('Saturação de base')) {
        final nums = extractNumbers(text);
        if (nums.isNotEmpty) {
          vValues.addAll(nums);
          print("V% encontrado: $nums | Linha: $text");
        }
      }

      // ---- K/CTC ----
      if (text.contains('% K C.T.C.') || text.contains('K mg/dm³')) {
        final nums = extractNumbers(text);
        if (nums.isNotEmpty) {
          kctcValues.addAll(nums);
          print("K encontrado: $nums | Linha: $text");
        }
      }
    }

    // Se não encontrou nada, tenta processar como tabela
    // if (ctcValues.length < 1 || vValues.length < 1) {
    //   print("Poucos dados, tentando processar como tabela em colunas...");
    //   resultList = processarTabelaColunas(lines);
    //   print(resultList);
    //   return resultList;
    if (ctcValues.isEmpty || vValues.isEmpty) {
      print("Poucos dados, tentando processar como tabela em colunas...");
      resultList = processarTabelaPDF(lines);
      print(resultList);
      return resultList;
    }

    // tamanho mínimo comum
    int size = [
      ctcValues.length,
      vValues.length,
    ].reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < size; i++) {
      double ctc = ctcValues[i];
      double v = vValues[i];
      double? k = (i < kctcValues.length) ? kctcValues[i] : null;
      int j = i + 1;

      double result = (v < 60) ? (60 - v) * ctc / 100 : (v - 60) * ctc / 100;

      String kctcStr = classifyKCTC(k);

      resultList.add(
        Analysis(id: j, ctc: ctc, potassio: v, result: result, kctc: kctcStr),
        // AnalysisCard(id: j, t: ctc, v: v, resultado: result, kct: kctcStr),
      );
    }

    return resultList;
  }

  List<Analysis> processarTabelaPDF(List<TextLine> lines) {
    List<Analysis> resultList = [];
    bool startValues = false;
    List<double> currentSample = [];

    for (var line in lines) {
      final text = line.text.trim();

      if (text.isEmpty) continue;

      // Detecta início dos valores
      if (text.contains('Zn Zinco')) {
        startValues = true;
        continue;
      }

      if (!startValues) continue; // ignora tudo antes de Zn

      // Se for um número inteiro => índice de amostra
      if (int.tryParse(text) != null) {
        // Processa a amostra anterior se existir
        if (currentSample.isNotEmpty) {
          // Pegando T, V, K
          double t = currentSample[11]; // posição 12
          double v = currentSample[12]; // posição 13
          double k = currentSample[13]; // posição 14

          double result = (v < 60) ? (60 - v) * t / 100 : (v - 60) * t / 100;

          resultList.add(
            Analysis(
              id: resultList.length + 1,
              ctc: t,
              potassio: v,
              result: result,
              kctc: classifyKCTC(k),
            ),
          );

          currentSample.clear();
        }
      } else {
        // É um número decimal (valor da amostra)
        final numVal = double.tryParse(text.replaceAll(',', '.'));
        if (numVal != null) {
          currentSample.add(numVal);
        }
      }
    }

    // Processa a última amostra
    if (currentSample.isNotEmpty) {
      double t = currentSample[11];
      double v = currentSample[12];
      double k = currentSample[13];

      double result = (v < 60) ? (60 - v) * t / 100 : (v - 60) * t / 100;

      resultList.add(
        Analysis(
          id: resultList.length + 1,
          ctc: t,
          potassio: v,
          result: result,
          kctc: classifyKCTC(k),
        ),
      );
    }

    return resultList;
  }

  // Extrai um ou mais números de uma linha
  List<double> extractNumbers(String line) {
    final regex = RegExp(r'[-+]?[0-9]*[.,]?[0-9]+');
    return regex
        .allMatches(line)
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
  }

  // Classificação do K/CTC
  String classifyKCTC(double? k) {
    if (k == null) return 'Unknown';
    if (k < 3) return '1.00.1';
    if (k >= 3 && k < 4) return '1.5.0';
    if (k >= 4 && k < 6) return '2.00.1';
    return '3.00.1';
  }
}
