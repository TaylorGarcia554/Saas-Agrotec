import 'package:agrotec/menuhome.dart';
import 'package:agrotec/models/db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart' as window_size;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    // Inicializa sqflite_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Define o tamanho mínimo da janela
    window_size.setWindowMinSize(const Size(800, 600));
    // (opcional) define tamanho inicial
    window_size.setWindowFrame(const Rect.fromLTWH(100, 100, 1024, 768));
  }
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
