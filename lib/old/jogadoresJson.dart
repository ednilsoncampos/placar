import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterapp/placar/jogador.dart';
import 'package:path_provider/path_provider.dart';

class HomeJogadores extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeJogadores> {
  final _toDoController = TextEditingController();

  List<Jogador> _jogadores = new List();

  Jogador _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        if ("[]" != data) {
          _jogadores = json.decode(data);
          ;
        }
      });
    });
  }

  void _addToDo() {
    setState(() {
      Jogador jogador;
      if (_jogadores.isEmpty) {
        jogador = Jogador.novo(1, _toDoController.text, false);
      } else {
        int _id;
        if (_jogadores.length == 1) {
          _id = 2;
        } else {
          _jogadores.sort((a, b) => a.id.compareTo(b.id));
          _id = _jogadores.last.id + 1;
        }

        jogador = Jogador.novo(_id, _toDoController.text, false);
      }

      _jogadores.add(jogador);
      _toDoController.text = "";
      _readData().then((data) {
        print(data);
      });
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _jogadores.sort((a, b) {
        if (a.ativoTorneio && !b.ativoTorneio)
          return 1;
        else if (!a.ativoTorneio && b.ativoTorneio)
          return -1;
        else
          return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Cadastrados"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
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
        secondary: CircleAvatar(
          child:
              Icon(_jogadores[index].ativoTorneio ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _jogadores[index].ativoTorneio = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = _jogadores[index];
          _lastRemovedPos = index;
          _jogadores.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Jogador \"${_lastRemoved.nome}\" removido!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _jogadores.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
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

  /*
  Future<File> _getFile() async {
    /*
        String directory = await rootBundle.loadString('assets/jogadores.json');
    return File(directory);
     */
    final directory = await getApplicationDocumentsDirectory();
    var path = "${directory.path}/data.json";
    var file = File(path);

    return file;
  }*/

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _getFile2() async {
    final path = await _localPath;
    var file = File('$path/data.json');
    var readAsString = await file.readAsString();
    print(readAsString);
    return file;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _saveData() async {
    String dataJson;
    try {
      final _data = List<dynamic>.from(
        _jogadores.map<dynamic>(
          (dynamic item) => item,
        ),
      );
      dataJson = json.encode(_data);
    } on Exception catch (exception) {
      print(exception);
      rethrow;
    } catch (error) {
      print(error);
    }
    final file = await _getFile();
    return file.writeAsString(dataJson);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
