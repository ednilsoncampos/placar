import 'package:flutterapp/placar/resultado.dart';
import 'package:flutterapp/placar/torneio.dart';

import 'jogador.dart';

class Partida {
  int id;
  DateTime dataPartida;

  Torneio torneio;

  //Jogador 1
  Jogador jogador1;
  int pontosJogador1 = 0;
  Resultado resultadoJogador1 = Resultado.aguardando;

  //Jogador 2
  Jogador jogador2;
  int pontosJogador2 = 0;
  Resultado resultadoJogador2 = Resultado.aguardando;

  Partida({
      this.id,
      this.dataPartida,
      this.torneio,
      this.jogador1,
      this.pontosJogador1,
      this.resultadoJogador1,
      this.jogador2,
      this.pontosJogador2,
      this.resultadoJogador2});

  Partida.nova(this.dataPartida, this.jogador1, this.jogador2, this.torneio);

  zerar() {
    pontosJogador1 = 0;
    pontosJogador2 = 0;
    resultadoJogador1 = Resultado.aguardando;
    resultadoJogador2 = Resultado.aguardando;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_partida': dataPartida.millisecondsSinceEpoch,
      'fk_torneio': torneio.id,
      'fk_jogador1': jogador1.id,
      'pontos_jogador1': pontosJogador1,
      'resultado_jogador1': resultadoJogador1.index,
      'fk_jogador2': jogador2.id,
      'pontos_jogador2': pontosJogador2,
      'resultado_jogador2': resultadoJogador2.index,
    };
  }

  @override
  String toString() {
    return 'Partida{id: $id, torneio: $torneio, jogador1: $jogador1, jogador2: $jogador2}';
  }
}
