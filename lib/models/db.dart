import 'package:agrotec/utils/analyses.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnalisesDB {
  static final AnalisesDB _instance = AnalisesDB._internal();
  factory AnalisesDB() => _instance;
  AnalisesDB._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await databaseFactory
        .getDatabasesPath(); // <- usa a factory atual
    return await databaseFactory.openDatabase(
      // <- usa a factory atual
      join(dbPath, 'analises.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE analises(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            ctc REAL, 
            v REAL, 
            resultado REAL, 
            kctc TEXT,
            nome TEXT,
            create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        },
      ),
    );
  }

  // Salvar análise
  Future<void> salvarAnalise({
    required double ctc,
    required double v,
    required double resultado,
    required String kctc,
    required String nome,
  }) async {
    final db = await database;
    await db.insert('analises', {
      'ctc': ctc,
      'v': v,
      'resultado': resultado,
      'kctc': kctc,
      'nome': nome,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Buscar análises ordenadas
  Future<List<Map<String, dynamic>>> buscarAnalisesOrdenadas() async {
    final db = await database;
    return await db.query('analises', orderBy: 'id DESC');
  }

  // Buscar e converter para List<Analysis>
  Future<List<Analysis>> buscarAnalisesComoObjetos() async {
    final resultados = await buscarAnalisesOrdenadas();
    return resultados.map((map) {
      return Analysis(
        id: map['id'] as int,
        ctc: (map['ctc'] as num).toDouble(),
        potassio: (map['v'] as num).toDouble(),
        result: (map['resultado'] as num).toDouble(),
        kctc: map['kctc'] as String,
      );
    }).toList();
  }
}
