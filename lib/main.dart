import 'package:flutter/material.dart';
import 'package:flutterapp/jogadores.dart';
import 'package:flutterapp/partidas.dart';
import 'package:flutterapp/ranking.dart';

import 'abapontos.dart';

void main() {
  runApp(TabBarDemo());
}

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Text("Jogador")),
                Tab(icon: Text("Partidas")),
                Tab(icon: Text("Pontos")),
                Tab(icon: Text("Ranking")),
              ],
            ),
            title: Text('Placar'),
          ),
          body: TabBarView(
            children: [
              HomeJogadores(),
              HomePartidas(),
              HomePontos(),
              HomeRanking(),
            ],
          ),
        ),
      ),
    );
  }
}