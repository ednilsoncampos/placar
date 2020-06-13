import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  var nomeBanco = 'db_placar.db';

  DatabaseHelper.privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper.privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    var part1 = await getDatabasesPath();
    String path = join(part1, nomeBanco);
    return await openDatabase(path, version: 1, onDowngrade: _recreateTables, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    var sqlJogador =
        "CREATE TABLE tb_jogador(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, ativo_torneio INTEGER)";

    var sqlTorneio =
        "CREATE TABLE tb_torneio(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data_abertura INTEGER, data_encerramento INTEGER, descricao TEXT)";

    var sqlPartidas = "CREATE TABLE tb_partidas "
        "(id INTEGER PRIMARY KEY AUTOINCREMENT, data_partida INTEGER, fk_torneio INTEGER, "
        "fk_jogador1 INTEGER, pontos_jogador1 INTEGER, resultado_jogador1 INTEGER, "
        "fk_jogador2 INTEGER, pontos_jogador2 INTEGER, resultado_jogador2 INTEGER, "
        "FOREIGN KEY (fk_torneio) REFERENCES tb_torneio (id), "
        "FOREIGN KEY (fk_jogador1) REFERENCES tb_jogador (id), "
        "FOREIGN KEY (fk_jogador2) REFERENCES tb_jogador (id))";

    try {
      await db.execute(sqlJogador);
      await db.execute(sqlTorneio);
      await db.execute(sqlPartidas);
    } on Exception catch (exception) {
      print(exception);
      rethrow;
    } catch (error) {
      print(error);
    }
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      // update database
//      db.execute("ALTER TABLE tabEmployee ADD COLUMN newCol TEXT;");
    }
    db.execute("DROP TABLE IF EXISTS tb_jogador;");
    db.execute("DROP TABLE IF EXISTS tb_torneio;");
    db.execute("DROP TABLE IF EXISTS tb_partidas;");

    _onCreate(db, newVersion);
  }

  void _recreateTables(Database db, int oldVersion, int newVersion) {
    db.execute("DROP TABLE IF EXISTS tb_jogador;");
    db.execute("DROP TABLE IF EXISTS tb_torneio;");
    db.execute("DROP TABLE IF EXISTS tb_partidas;");

    _onCreate(db, newVersion);
  }
}
