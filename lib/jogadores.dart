import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterapp/placar/jogador.dart';

import 'config/tabelajogador.dart';


class HomeJogadores extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeJogadores> {
  var databaseHelper = TabelaJogador();

  final _toDoController = TextEditingController();

  List<Jogador> _jogadores = new List();

  Jogador _lastRemoved;

  @override
  void initState() {
    super.initState();

    atualizarLista();
  }

  void atualizarLista() {
    _readData().then((data) {
      setState(() {
        _jogadores = data;
      });
    });
  }

  void _addToDo() {
    setState(() {
      Jogador jogador = Jogador.novo(null, _toDoController.text, true);
      _saveData(jogador);
      _toDoController.text = "";
      atualizarLista();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      atualizarLista();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Novo Jogador",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                )),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _jogadores.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(
            _jogadores[index].id.toString() + " - " + _jogadores[index].nome),
        value: _jogadores[index].ativoTorneio,
        onChanged: (c) {
          setState(() {
            _jogadores[index].ativoTorneio = c;
            _saveData(_jogadores[index]);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = _jogadores[index];
          _remover(_lastRemoved.id);

          atualizarLista();

          final snack = SnackBar(
            content: Text("Jogador \"${_lastRemoved.nome}\" removido!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    atualizarLista();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  void _saveData(Jogador jogador) async {
    if(jogador.id == null) {
      await databaseHelper.insertJogador(jogador);
    } else {
      await databaseHelper.updateJogador(jogador);
    }
  }

  void _remover(int id) async {
      await databaseHelper.deleteJogador(id);
  }

  Future<List<Jogador>> _readData() async {
    try {
      List<Jogador> lista = await databaseHelper.jogadores();
      return lista;
    } catch (e) {
      return null;
    }
  }
}
