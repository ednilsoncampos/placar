import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterapp/config/tabelapartidas.dart';
import 'package:flutterapp/placar/classificacao.dart';
import 'package:flutterapp/placar/jogador.dart';
import 'package:flutterapp/placar/partida.dart';
import 'package:flutterapp/placar/resultado.dart';
import 'package:flutterapp/placar/torneio.dart';
import "package:collection/collection.dart";

import 'config/tabelajogador.dart';

class HomeRanking extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeRanking> {
  var dbJogadores = TabelaJogador();
  var dbPartidas = TabelaPartidas();

  List<Classificacao> listaClassificacao = List();

  String torneio = "";

  @override
  void initState() {
    super.initState();

    montarClassificacao();
    buscarTotaisTorneio();
  }

  void buscarTotaisTorneio() async {
    var qtde = await dbPartidas.consultarQtdeTorneios();
    var qtdePartidas = await dbPartidas.consultarQtdePartidas();

    setState(() {
      torneio = "Total de " +
          qtdePartidas.toString() +
          " partidas em " +
          qtde.toString() +
          " torneios.";
    });
  }

  void montarClassificacao() async {
    List<Classificacao> classificacao = List();
    List<Partida> partidas = await dbPartidas.partidas();

    await atualizarResultados(partidas);

    var jogadores1 = groupBy(partidas, (obj) => obj.jogador1);

    jogadores1.forEach((k, v) {
      var c = Classificacao(
        jogador: k,
        pontos: v.fold(0, (prev, e) => prev + e.pontosJogador1),
        vitorias: v.fold(
            0,
            (prev, e) =>
                (Resultado.vitoria == e.resultadoJogador1) ? (prev + 1) : prev),
        derrotas: v.fold(
            0,
            (prev, e) =>
                (Resultado.derrota == e.resultadoJogador1) ? (prev + 1) : prev),
        empates: v.fold(
            0,
            (prev, e) =>
                (Resultado.empate == e.resultadoJogador1) ? (prev + 1) : prev),
        jogos: v.fold(
            0,
            (prev, e) => (Resultado.aguardando != e.resultadoJogador1)
                ? (prev + 1)
                : prev),
      );
      classificacao.add(c);
    });

    var jogadores2 = groupBy(partidas, (obj) => obj.jogador2);

    jogadores2.forEach((k, v) {
      var c = Classificacao(
        jogador: k,
        pontos: v.fold(0, (prev, e) => prev + e.pontosJogador2),
        vitorias: v.fold(
            0,
            (prev, e) =>
                (Resultado.vitoria == e.resultadoJogador2) ? (prev + 1) : prev),
        derrotas: v.fold(
            0,
            (prev, e) =>
                (Resultado.derrota == e.resultadoJogador2) ? (prev + 1) : prev),
        empates: v.fold(
            0,
            (prev, e) =>
                (Resultado.empate == e.resultadoJogador2) ? (prev + 1) : prev),
        jogos: v.fold(
            0,
            (prev, e) => (Resultado.aguardando != e.resultadoJogador2)
                ? (prev + 1)
                : prev),
      );
      if (classificacao.contains(c)) {
        Classificacao ce = classificacao.firstWhere((e) => e == c);
        ce.pontos += c.pontos;
        ce.vitorias += c.vitorias;
        ce.derrotas += c.derrotas;
        ce.empates += c.empates;
        ce.jogos += c.jogos;
        classificacao.remove(c);
        classificacao.add(ce);
      } else {
        classificacao.add(c);
      }
    });
    classificacao.sort((a, b) => b.pontos.compareTo(a.pontos));
    setState(() {
      listaClassificacao = classificacao;
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    var celNome = TableCell(
      child: Container(
        color: Colors.black12,
        child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    var celPontos = TableCell(
      child: Container(
        color: Colors.black12,
        child: Text('Pt.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    var celJogos = TableCell(
      child: Container(
        color: Colors.black12,
        child: Text('Jg.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    var celVitoria = TableCell(
      child: Container(
        color: Colors.black12,
        child: Text('Vt.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    var celEmp = TableCell(
      child: Container(
        color: Colors.black12,
        child: Text('Emp.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    var celDerrotas = TableCell(
      child: Container(
        color: Colors.black12,
        child: Text('Dt.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );

    List<TableRow> rows = <TableRow>[
      new TableRow(
        children: <Widget>[
          celNome,
          celPontos,
          celJogos,
          celVitoria,
          celEmp,
          celDerrotas,
        ],
      ),
    ];

    for (Classificacao ranking in listaClassificacao) {
      rows.add(
        new TableRow(
          children: [
            Text(ranking.jogador.nome),
            Text(ranking.pontos.toString(), textAlign: TextAlign.center),
            Text(ranking.jogos.toString(), textAlign: TextAlign.center),
            Text(ranking.vitorias.toString(), textAlign: TextAlign.center),
            Text(ranking.empates.toString(), textAlign: TextAlign.center),
            Text(ranking.derrotas.toString(), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    var table = Container(
        margin: EdgeInsets.all(7),
        child: new Table(border: TableBorder.all(width: 1.0), children: rows));

    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(torneio,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.indigo)),
          table
        ],
      ),
    );
  }
}
