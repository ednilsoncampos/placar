import 'package:flutterapp/placar/jogador.dart';

class Classificacao {
  Jogador jogador;
  int idTorneio;
  int pontos;
  int jogos;
  int vitorias;
  int empates;
  int derrotas;

  Classificacao.nova(this.jogador, this.pontos, this.jogos, this.vitorias,
      this.empates, this.derrotas, this.idTorneio);

  Classificacao(
      {this.jogador,
      this.pontos,
      this.jogos,
      this.vitorias,
      this.empates,
      this.derrotas,
      this.idTorneio});

  Map<String, dynamic> toMap() {
    return {
      'jogador': jogador,
      'pontos': pontos,
      'jogos': jogos,
      'vitorias': vitorias,
      'empates': empates,
      'derrotas': derrotas,
      'idTorneio': idTorneio,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Classificacao &&
          runtimeType == other.runtimeType &&
          jogador == other.jogador;

  @override
  int get hashCode => jogador.hashCode;
}
