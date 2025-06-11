import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import '../models/jogador.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  bool _initialized = false;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (!_initialized) {
      await _initializeDatabase();
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _initializeDatabase() async {
    try {
      // Garante que o plugin está inicializado
      await getDatabasesPath();
      _initialized = true;
    } on PlatformException catch (e) {
      print('Erro ao inicializar o banco de dados: $e');
      // Aguarda um momento e tenta novamente
      await Future.delayed(const Duration(milliseconds: 500));
      await _initializeDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'futebol.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Erro ao criar banco de dados: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jogadores(
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        overall INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Jogador>> getJogadores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jogadores');
    return List.generate(maps.length, (i) {
      return Jogador(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        overall: maps[i]['overall'],
      );
    });
  }

  Future<void> addJogador(Jogador jogador) async {
    final db = await database;
    await db.insert(
      'jogadores',
      {
        'id': jogador.id,
        'nome': jogador.nome,
        'overall': jogador.overall,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateJogador(Jogador jogador) async {
    final db = await database;
    await db.update(
      'jogadores',
      {
        'nome': jogador.nome,
        'overall': jogador.overall,
      },
      where: 'id = ?',
      whereArgs: [jogador.id],
    );
  }

  Future<void> deleteJogador(String id) async {
    final db = await database;
    await db.delete(
      'jogadores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> existeJogadorComNome(String nome, {String? excludeId}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'jogadores',
      where: 'LOWER(nome) = LOWER(?) AND id != ?',
      whereArgs: [nome, excludeId ?? ''],
    );
    return result.isNotEmpty;
  }
} 