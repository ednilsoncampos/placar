import 'dart:async';

import 'package:flutterapp/config/bancodados.dart';
import 'package:flutterapp/config/tabelajogador.dart';
import 'package:flutterapp/placar/jogador.dart';
import 'package:flutterapp/placar/partida.dart';
import 'package:flutterapp/placar/resultado.dart';
import 'package:flutterapp/placar/torneio.dart';
import 'package:sqflite/sqflite.dart';

//Utilizada para testes
void main() async {
  var dbPartidas = TabelaPartidas();
  var dbJogador = TabelaJogador();

  Jogador jogador = Jogador.novo(null, "Ednilson", true);

  Jogador jogador2 = Jogador.novo(null, "Edinho", true);

  await dbJogador.insertJogador(jogador);
  await dbJogador.insertJogador(jogador2);

  List jogdores = await dbJogador.jogadores();

  Torneio novoTorneio = Torneio.novo(new DateTime.now(), " Itamar ");

  await dbPartidas
      .insertTorneio(novoTorneio)
      .then((id) => {inserirPart(id, jogdores, novoTorneio, dbPartidas)});

  await dbPartidas.partidas().then((p) => {print(p)});

  await dbPartidas
      .consultarPartida(1)
      .then((p) => {print("-> " + p.toString())});
}

void inserirPart(
    int id, List jogdores, Torneio novoTorneio, TabelaPartidas dbTabelas) {
  novoTorneio.id = id;
  Partida partida =
      Partida.nova(new DateTime.now(), jogdores[0], jogdores[0], novoTorneio);
  dbTabelas
      .insertPartida(partida)
      .then((value) => dbTabelas.partidas().then((p) => {print(p)}));
}

class TabelaPartidas extends DatabaseHelper {
  var tabelaPartidas = 'tb_partidas';
  var tabelaTorneio = 'tb_torneio';

  var dbJogadores = TabelaJogador();

  TabelaPartidas() : super.privateConstructor();

  Future<List<Partida>> partidas() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tabelaPartidas);

    var partidas = List.generate(maps.length, (i) {
      return partidaLazy(maps[i]);
    });

    for (Partida p in partidas) {
      p.torneio = await consultarTorneio(p.torneio.id);
      p.jogador1 = await dbJogadores.consultarJogador(p.jogador1.id);
      p.jogador2 = await dbJogadores.consultarJogador(p.jogador2.id);
    }

    return partidas;
  }

  Future<List<Partida>> partidasUltimoTorneio() async {
    final Database db = await database;

    var maxId = await db.rawQuery(
        "SELECT MAX(id) AS max_id FROM " + tabelaTorneio, null);

    if (maxId[0]['max_id'] == null) {
      return List<Partida>();
    }

    List<dynamic> whereArguments = [maxId[0]['max_id']];

    var sql =
        "SELECT p.* FROM tb_partidas p INNER JOIN tb_torneio t ON t.id = p.fk_torneio "
        "WHERE t.id = ? AND t.data_encerramento is null ";
//        "AND (p.pontos_jogador1 > 0 || p.pontos_jogador2 > 0)";

    List<Map<String, dynamic>> maps = await db.rawQuery(sql, whereArguments);

    if (maps.isEmpty) return List<Partida>();

    var partidas = List.generate(maps.length, (i) {
      return partidaLazy(maps[i]);
    });

    for (Partida p in partidas) {
      p.torneio = await consultarTorneio(p.torneio.id);
      p.jogador1 = await dbJogadores.consultarJogador(p.jogador1.id);
      p.jogador2 = await dbJogadores.consultarJogador(p.jogador2.id);
    }

    return partidas;
  }

  Future<Partida> consultarPartida(int id) async {
    final Database db = await database;

    String whereString = 'id = ?';

    List<dynamic> whereArguments = [id];

    List<Map<String, dynamic>> maps = await db.query(tabelaPartidas,
        where: whereString, whereArgs: whereArguments);

    var partida = partidaLazy(maps[0]);

    partida.torneio = await consultarTorneio(maps[0]['fk_torneio']);
    partida.jogador1 =
        await dbJogadores.consultarJogador(maps[0]['fk_jogador1']);
    partida.jogador2 =
        await dbJogadores.consultarJogador(maps[0]['fk_jogador2']);

    return partida;
  }

  Partida partidaLazy(Map<String, dynamic> map) {
    var partida = Partida(
      id: map['id'],
      dataPartida: DateTime.fromMillisecondsSinceEpoch(map['data_partida']),
      torneio: Torneio(id: map['fk_torneio']),
      jogador1: Jogador(id: map['fk_jogador1']),
      pontosJogador1: map['pontos_jogador1'],
      resultadoJogador1: Resultado.values[map['resultado_jogador1']],
      jogador2: Jogador(id: map['fk_jogador2']),
      pontosJogador2: map['pontos_jogador2'],
      resultadoJogador2: Resultado.values[map['resultado_jogador2']],
    );
    return partida;
  }

  Future<void> insertPartida(Partida partida) async {
    final Database db = await database;
    await db.insert(
      tabelaPartidas,
      partida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPartidas(List<Partida> partidas) async {
    for (Partida partida in partidas) {
      await insertPartida(partida);
    }
  }

  Future<void> updatePartida(Partida partida) async {
    final db = await database;
    await db.update(
      tabelaPartidas,
      partida.toMap(),
      where: "id = ?",
      whereArgs: [partida.id],
    );
  }

  Future<void> deletePartida(int id) async {
    final db = await database;
    await db.delete(
      tabelaPartidas,
      where: "id = ?",
      whereArgs: [id],
    );
  }

//*********  TORNEIO ***********
  Future<int> insertTorneio(Torneio torneio) async {
    final Database db = await database;

    int id = await db.insert(
      tabelaTorneio,
      torneio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateTorneio(Torneio torneio) async {
    final db = await database;
    await db.update(
      tabelaTorneio,
      torneio.toMap(),
      where: "id = ?",
      whereArgs: [torneio.id],
    );
  }

  Future<Torneio> consultarTorneio(int id) async {
    final Database db = await database;

    String whereString = 'id = ?';
    List<dynamic> whereArguments = [id];
    List<Map<String, dynamic>> maps = await db.query(tabelaTorneio,
        where: whereString, whereArgs: whereArguments);

    var torneio = Torneio(
      id: maps[0]['id'],
      dataAbertura:
          DateTime.fromMillisecondsSinceEpoch(maps[0]['data_abertura']),
      dataEncerramento: maps[0]['data_encerramento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(maps[0]['data_encerramento'])
          : null,
      descricao: maps[0]['descricao'],
    );
    return torneio;
  }

  Future<Torneio> consultarUltimoTorneio() async {
    final Database db = await database;

    var maxId = await db.rawQuery(
        "SELECT MAX(id) AS max_id FROM " + tabelaTorneio, null);

    if (maxId[0]['max_id'] == null) {
      return null;
    }

    String whereString = 'id = ?';

    List<dynamic> whereArguments = [maxId[0]['max_id']];

    List<Map<String, dynamic>> maps = await db.query(tabelaTorneio,
        where: whereString, whereArgs: whereArguments);

    return Torneio(
      id: maps[0]['id'],
      dataAbertura:
          DateTime.fromMillisecondsSinceEpoch(maps[0]['data_abertura']),
      dataEncerramento: maps[0]['data_encerramento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(maps[0]['data_encerramento'])
          : null,
      descricao: maps[0]['descricao'],
    );
  }

  Future<int> consultarQtdeTorneios() async {
    final Database db = await database;

    var maxId = await db.rawQuery(
        "SELECT count(id) AS qtde FROM " + tabelaTorneio, null);

    if (maxId[0]['qtde'] == null) {
      return 0;
    }
    return maxId[0]['qtde'];
  }

  Future<int> consultarQtdePartidas() async {
    final Database db = await database;

    List<dynamic> whereArguments = [0];

    //TODO Em vez de usar a quantidade de pontos, alterar lógica que atribui pontos para definir resultado
    var sql = "SELECT count(id) AS qtde FROM tb_partidas "
        "WHERE (resultado_jogador1 != :resultado) or (pontos_jogador1 > 0 or pontos_jogador2 > 0)";
    var maxId = await db.rawQuery(sql, whereArguments);

    if (maxId[0]['qtde'] == null) {
      return 0;
    }
    return maxId[0]['qtde'];
  }
}
