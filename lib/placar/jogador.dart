import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Jogador {
  int id;
  String nome;
  bool ativoTorneio;

//  Jogador(this.id, this.nome, this.ok);
  Jogador({this.id, this.nome, this.ativoTorneio});
  Jogador.novo(this.id, this.nome, this.ativoTorneio);

//  Map<String, dynamic> toMap() {
//    return {
//      'id': id,
//      'nome': nome,
//      'ok': ok,
//    };
//  }

//  factory Jogador.fromJson(Map<String, dynamic> json) => _$JogadorFromJson(json);
//  Map<String, dynamic> toMap() => _$JogadorToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ativo_torneio': ativoTorneioDb,
    };
  }


  @override
  String toString() {
    return '{id: $id, nome: $nome}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Jogador && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  int get ativoTorneioDb => ativoTorneio ? 1 : 0;
}
