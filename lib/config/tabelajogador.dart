import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutterapp/placar/jogador.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart' show join;

import 'bancodados.dart';

//Utilizada para testes
void main() async {
  var databaseHelper = TabelaJogador();

  List<Jogador> lista = await databaseHelper.jogadores();
  // apaga todos
  if (lista.isNotEmpty) {
    for (Jogador db in lista) {
      await databaseHelper.deleteJogador(db.id);
    }
  }

  Jogador jogador = Jogador.novo(null, "Ednilson", true);

  await databaseHelper.insertJogador(jogador);
  print(await databaseHelper.jogadores());

// Update Fido's age and save it to the database.
  Jogador j = await databaseHelper.consultarJogador(1);
  j.nome = 'ITAMAR';
  await databaseHelper.updateJogador(j);

  print(await databaseHelper.jogadores());

  await databaseHelper.deleteJogador(1);

  print("finalizado");
  print(await databaseHelper.jogadores());
}

class TabelaJogador extends DatabaseHelper {
  TabelaJogador() : super.privateConstructor();

  Future<List<Jogador>> jogadores() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The jogadores.
    final List<Map<String, dynamic>> maps = await db.query('tb_jogador');

    // Convert the List<Map<String, dynamic> into a List<Jogador>.
    return List.generate(maps.length, (i) {
      return Jogador(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        ativoTorneio: maps[i]['ativo_torneio'] == 1 ? true : false,
      );
    });
  }

  Future<List<Jogador>> jogadoresTorneio() async {
    final Database db = await database;

    String whereString = 'ativo_torneio = ?';

    List<dynamic> whereArguments = [1];

    List<Map<String, dynamic>> maps = await db.query('tb_jogador',
        where: whereString, whereArgs: whereArguments);

    return List.generate(maps.length, (i) {
      return Jogador(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        ativoTorneio: maps[i]['ativo_torneio'] == 1 ? true : false,
      );
    });
  }

  Future<void> insertJogador(Jogador jogador) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Jogador into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same Jogador is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'tb_jogador',
      jogador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateJogador(Jogador jogador) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Jogador.
    await db.update(
      'tb_jogador',
      jogador.toMap(),
      where: "id = ?",
      // Pass the Jogador's id as a whereArg to prevent SQL injection.
      whereArgs: [jogador.id],
    );
  }

  Future<Jogador> consultarJogador(int id) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The jogadores.
//    final List<Map<String, dynamic>> maps = await db.query('tb_jogador');

    String whereString = 'id = ?';
    List<dynamic> whereArguments = [id];
    List<Map<String, dynamic>> maps = await db.query('tb_jogador',
        where: whereString, whereArgs: whereArguments);

    // Convert the List<Map<String, dynamic> into a List<Jogador>.
    var list = List.generate(maps.length, (i) {
      return Jogador(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        ativoTorneio: maps[i]['ativo_torneio'] == 1 ? true : false,
      );
    });
    return list[0];
  }

  Future<void> deleteJogador(int id) async {
    try {
      // Get a reference to the database.
      final db = await database;

      // Remove the Jogador from the database.
      var i = await db.delete(
        'tb_jogador',
        // Use a `where` clause to delete a specific jogador.
        where: "id = ?",
        // Pass the Jogador id as a whereArg to prevent SQL injection.
        whereArgs: [id],
      );
    } on Exception catch (exception) {
      print(exception);
      rethrow;
    } catch (error) {
      print(error);
    }
  }
}
