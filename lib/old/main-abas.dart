import 'package:flutter/material.dart';
import 'package:flutterapp/partidas.dart';

import '../jogadores.dart';

void main() {
  runApp(TabBarDemo());
}

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Text("Jogadores")),
                Tab(icon: Text("Partidas")),
                Tab(icon: Text("Classificação")),
              ],
            ),
            title: Text('Placar'),
          ),
          body: TabBarView(
            children: [
              new HomeJogadores(),
              new HomePartidas(),
              Text("Classificação"),
            ],
          ),
        ),
      ),
    );
  }
}