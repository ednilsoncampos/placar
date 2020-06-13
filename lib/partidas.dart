import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterapp/config/tabelapartidas.dart';
import 'package:flutterapp/placar/jogador.dart';
import 'package:flutterapp/placar/partida.dart';
import 'package:flutterapp/placar/resultado.dart';
import 'package:flutterapp/placar/torneio.dart';
import 'package:trotter/trotter.dart';

import 'config/tabelajogador.dart';

class HomePartidas extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePartidas> {
  var dbJogadores = TabelaJogador();
  var dbPartidas = TabelaPartidas();

  List<Partida> _partidas = new List();
  int qtdePorRodada = 1;

  String torneio = "Torneio:";
  Torneio ultimoTorneio;

  List<bool> isSelected;

  @override
  void initState() {
    isSelected = [true, false, false];
    super.initState();

    if (_partidas.isEmpty) atualizarLista();

    buscarUltimoTorneio();
  }

  void buscarUltimoTorneio() async {
    ultimoTorneio = await dbPartidas.consultarUltimoTorneio();
    if (ultimoTorneio != null) {
      torneio = "Torneio: " +
          ultimoTorneio.id.toString() +
          " - " +
          ultimoTorneio.descricao +
          ultimoTorneio.dataAberturaFormatada();
    }
  }

  void encerrarPartidas() async {
    if (ultimoTorneio.dataEncerramento != null) {
      setState(() {
        _partidas = List();
      });
      return;
    }
    await atualizarResultados(_partidas);
    ultimoTorneio.dataEncerramento = DateTime.now();
    await dbPartidas.updateTorneio(ultimoTorneio);
    atualizarLista();
  }

  Future atualizarResultados(List<Partida> partidas) async {
    for (Partida p in partidas) {
      if ((p.pontosJogador1 > 0 || p.pontosJogador2 > 0) ==
          (p.pontosJogador1 == p.pontosJogador2)) {
        p.resultadoJogador1 = Resultado.empate;
        p.resultadoJogador2 = Resultado.empate;
      } else if (p.pontosJogador1 > p.pontosJogador2) {
        p.resultadoJogador1 = Resultado.vitoria;
        p.resultadoJogador2 = Resultado.derrota;
      } else if (p.pontosJogador1 < p.pontosJogador2) {
        p.resultadoJogador1 = Resultado.derrota;
        p.resultadoJogador2 = Resultado.vitoria;
      }
      //TODO Criar método para atualizar lista
      await dbPartidas.updatePartida(p);
    }
  }

  void apagarPartidas() async {
    var partidas = await dbPartidas.partidas();
    for (Partida p in partidas) {
      await dbPartidas.deletePartida(p.id);
    }
    setState(() {
      _partidas = new List();
    });
  }

  Future<void> _showMyDialog(String data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(data),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void gerarPartidas() {
    _readData().then((jogadores) {
      if (jogadores.isNotEmpty) {
        if (jogadores.length < 2) {
          _showMyDialog('É preciso ter mais de UM jogador cadastrado.');
          return;
        }
        Torneio novoTorneio = Torneio.novo(new DateTime.now(), " Itamar ");
        _insertTorneio(novoTorneio)
            .then((id) => {inserirPartidas(id, novoTorneio, jogadores)});
      }
    });
  }

  void inserirPartidas(
      int id, Torneio novoTorneio, List<Jogador> jogadores) async {
    novoTorneio.id = id;

    final bagOfItems = jogadores, combos = Combinations(2, bagOfItems);

    var partidasSorteadas = combos().toList();

    List<Partida> partidas = new List();
    for (int i = 0; partidasSorteadas.length > i; i++) {
      Partida partida = Partida.nova(new DateTime.now(),
          partidasSorteadas[i][0], partidasSorteadas[i][1], novoTorneio);
      partidas.add(partida);
    }
    if (partidas.isNotEmpty) {
      try {
        List<Partida> todos = List();
        todos.addAll(partidas);
        if (qtdePorRodada > 1) {
          todos.addAll(partidas);
        }

        await dbPartidas.insertPartidas(todos);

        setState(() {
          var _torneio = "Torneio: " +
              novoTorneio.id.toString() +
              " - " +
              novoTorneio.descricao +
              novoTorneio.dataAberturaFormatada();
          torneio = _torneio;
        });
        atualizarLista();
      } on Exception catch (e) {
        print(e);
        _showMyDialog('Partida 1:' + e.toString());
        rethrow;
      } catch (ex) {
        print(ex);
        _showMyDialog('Partida 2:' + ex.toString());
      }
    }
  }

  void atualizarLista() {
    dbPartidas.partidasUltimoTorneio().then((data) {
      setState(() {
        _partidas = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var minusButton = new IconButton(
      icon: new Icon(Icons.remove),
      onPressed: () => setState(() => qtdePorRodada--),
    );

    var addButton = new IconButton(
        icon: new Icon(Icons.add),
        onPressed: () => setState(() => qtdePorRodada++));

    var zerar = new IconButton(
        icon: new Icon(Icons.clear),
        onPressed: () => setState(() => {apagarPartidas()}));

    /*
    var incrementDecrement = NumberInputWithIncrementDecrement(
      controller: TextEditingController(),
      min: 1,
      max: 3,
    );
    */

    var botaoGerar = RaisedButton(
      color: Colors.blueAccent,
      child: Text("Gerar partidas"),
      textColor: Colors.white,
      onPressed: gerarPartidas,
    );

    var container = Container(
      padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
      child: Row(
        children: <Widget>[
          botaoGerar,
          Expanded(
            child: Text(" " + qtdePorRodada.toString() + " por rodada",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Colors.indigo)),
          ),
          minusButton,
          addButton,
          zerar,
        ],
      ),
    );

    var tituloTorneio = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(torneio,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.teal)),
        ],
      ),
    );

    var expanded = Expanded(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
            padding: EdgeInsets.only(top: 10.0),
            itemCount: _partidas.length,
            itemBuilder: buildItem),
      ),
    );

    var containerEncerrar = Container(
      padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              color: Colors.blueAccent,
              child: Text("Encerrar partidas"),
              textColor: Colors.white,
              onPressed: encerrarPartidas,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Column(
        children: <Widget>[
          container,
          tituloTorneio,
          expanded,
          containerEncerrar
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    Partida partida = _partidas[index];
    Jogador jogador1 = partida.jogador1;
    var toggleButtons = ToggleButtons(
      children: <Widget>[
        Icon(Icons.check),
        Icon(Icons.dehaze),
        Icon(Icons.check),
      ],
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0;
              buttonIndex < isSelected.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              isSelected[buttonIndex] = !isSelected[buttonIndex];
            } else {
              isSelected[buttonIndex] = false;
            }
          }
        });
      },
      isSelected: isSelected,
    );

    var minusButton1 = new IconButton(
      icon: new Icon(Icons.remove),
      onPressed: () => setState(() => partida.pontosJogador1--),
    );

    var addButton1 = new IconButton(
        icon: new Icon(Icons.add),
        onPressed: () => {partida.pontosJogador1++, atualizarTotal(partida)});

    var addButton2 = new IconButton(
        icon: new Icon(Icons.add),
        onPressed: () => {partida.pontosJogador2++, atualizarTotal(partida)});

    var zerar = new IconButton(
        icon: new Icon(Icons.clear),
        onPressed: () =>
            setState(() => {partida.zerar(), atualizarTotal(partida)}));

    var jogador11 =
        new Text(jogador1.nome + " " + partida.pontosJogador1.toString());
    var jogador2 = new Text(
        partida.pontosJogador2.toString() + " " + partida.jogador2.nome);
    var versus = new Text(" X ");

    final linha = new Container(
      child: new Row(
        children: <Widget>[
          zerar,
          Text(partida.id.toString() + "°"),
          addButton1,
          jogador11,
          versus,
          jogador2,
          addButton2,
        ],
      ),
    );

    return ListTile(
      title: linha,
    );
  }

  /*

//  return criarTable(jogador1, partida, zerar, addButton1, addButton2);
  Container criarTable(Jogador jogador1, Partida partida, IconButton zerar, IconButton addButton1, IconButton addButton2) {
     var jogador11 = new Text(jogador1.nome);
    var jogador2 = new Text(partida.jogador2.nome);
    var versus = new Text(partida.pontosJogador1.toString() +
        " X " +
        partida.pontosJogador2.toString(), textAlign: TextAlign.center);

    final linha = new Container(
      child: new Row(
        children: <Widget>[
          zerar,
          Text(partida.id.toString() + "°"),
          addButton1,
          jogador11,
          versus,
          jogador2,
          addButton2,
        ],
      ),
    );

    List<TableRow> rows = List();

    for (Partida p in _partidas) {
      rows.add(
        new TableRow(
          children: [
            zerar,
            Text(partida.id.toString() + "°", textAlign: TextAlign.center),
            addButton1,
            jogador11,
            versus,
            jogador2,
            addButton2,
          ],
        ),
      );
    }

    var table = new Table(border: TableBorder.all(width: 1.0), children: rows);
    return Container(
      margin: EdgeInsets.all(7),
      child: table,
    );
  }
   */

  void atualizarTotal(Partida partida) async {
    await dbPartidas.updatePartida(partida);
    atualizarLista();
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    print("Salvar dados");

    return null;
  }

  Future<List<Jogador>> _readData() async {
    try {
      List<Jogador> lista = await dbJogadores.jogadoresTorneio();
      return lista;
    } catch (e) {
      return null;
    }
  }

  Future<int> _insertTorneio(Torneio torneio) async {
    try {
      int id = await dbPartidas.insertTorneio(torneio);
      return id;
    } catch (e) {
      _showMyDialog('Erro torneio:' + e.toString());
      return null;
    }
  }
}
