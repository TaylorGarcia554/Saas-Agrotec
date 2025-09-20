import 'package:agrotec/menuhome.dart';
import 'package:agrotec/models/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalisesDB().database; // Inicializa o banco de dados

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Análises PDF',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Menuhome(),
    );
  }
}
