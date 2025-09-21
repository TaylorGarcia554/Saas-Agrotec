import 'package:flutter/material.dart';

class AnaliseCard extends StatelessWidget {
  final int id;
  final String nome;
  final double ctc;
  final double v;
  final double resultado;
  final String kctc;
  final DateTime createdAt;

  final VoidCallback onEditar;
  final VoidCallback onBaixar;
  final VoidCallback onVisualizar;

  const AnaliseCard({
    super.key,
    required this.id,
    required this.nome,
    required this.ctc,
    required this.v,
    required this.resultado,
    required this.kctc,
    required this.createdAt,
    required this.onEditar,
    required this.onBaixar,
    required this.onVisualizar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Criado em: ${createdAt.toLocal()}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: "Baixar",
              onPressed: onBaixar,
            ),
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: "Visualizar",
              onPressed: onVisualizar,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Editar",
              onPressed: onEditar,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CTC: $ctc"),
                Text("V: $v"),
                Text("Resultado: $resultado"),
                Text("KCTC: $kctc"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
