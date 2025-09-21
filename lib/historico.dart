import 'package:agrotec/models/db.dart';
import 'package:agrotec/utils/analyses.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Historico extends StatefulWidget {
  const Historico({Key? key}) : super(key: key);

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  List<Analysis> analyses = [];
  bool editMode = false;
  List<TextEditingController?> controllers = [];

  @override
  void initState() {
    // TODO: implement initState
    _carregarAnalises();
    super.initState();
  }

  Future<void> _carregarAnalises() async {
    // final data = await AnalisesDB().buscarAnalisesComoObjetos();
    final data = [
      Analysis(id: 1, ctc: 10.0, potassio: 5.0, result: 2.5, kctc: "50%"),
      Analysis(id: 2, ctc: 15.0, potassio: 7.5, result: 3.75, kctc: "50%"),
    ]; // Simulação de dados

    setState(() {
      analyses = data;
      controllers = List.generate(
        data.length,
        (_) => TextEditingController(text: ""),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: analyses.isEmpty
          ? const Center(child: Text("Nenhuma análise encontrada"))
          : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: analyses.length,
            itemBuilder: (context, index) {
              final analysis = analyses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
                  title: Text(
                    "Análise #${analysis.id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    AnaliseTable(analyses: [analysis]),
                  ],
                ),
              );
            },
          ),
    );
  }
}
