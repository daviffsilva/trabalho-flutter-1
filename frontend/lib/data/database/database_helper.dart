import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:entrega_app/data/models/entrega.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'entregas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entregas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clienteId INTEGER NOT NULL,
        motoristaId INTEGER NOT NULL,
        endereco TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        status TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        dataEntrega TEXT,
        fotoEntrega TEXT,
        fotoAssinatura TEXT
      )
    ''');

    await db.insert('entregas', {
      'clienteId': 1,
      'motoristaId': 1,
      'endereco': 'Rua das Flores, 123 - São Paulo',
      'status': 'ENTREGUE',
      'dataCriacao': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'dataEntrega': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'fotoEntrega': null,
      'fotoAssinatura': null,
      'latitude': -23.550520,
      'longitude': -46.633308,
    });
    await db.insert('entregas', {
      'clienteId': 2,
      'motoristaId': 1,
      'endereco': 'Av. Paulista, 1000 - São Paulo',
      'status': 'ENTREGUE',
      'dataCriacao': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'dataEntrega': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'fotoEntrega': null,
      'fotoAssinatura': null,
      'latitude': -23.563210,
      'longitude': -46.654190,
    });
  }

  Future<int> insertEntrega(Entrega entrega) async {
    final db = await database;
    return await db.insert('entregas', entrega.toJson());
  }

  Future<List<Entrega>> getEntregasByCliente(int clienteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entregas',
      where: 'clienteId = ?',
      whereArgs: [clienteId],
    );
    return maps.map((map) => Entrega.fromJson(map)).toList();
  }

  Future<List<Entrega>> getEntregasByMotorista(int motoristaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entregas',
      where: 'motoristaId = ?',
      whereArgs: [motoristaId],
    );
    return maps.map((map) => Entrega.fromJson(map)).toList();
  }

  Future<void> updateEntregaStatus(int id, String fotoEntrega, String fotoAssinatura) async {
    final db = await database;
    await db.update(
      'entregas',
      {
        'status': StatusEntrega.entregue.toString().split('.').last,
        'dataEntrega': DateTime.now().toIso8601String(),
        'fotoEntrega': fotoEntrega,
        'fotoAssinatura': fotoAssinatura,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 