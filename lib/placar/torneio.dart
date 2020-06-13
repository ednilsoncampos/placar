import 'package:intl/intl.dart';

class Torneio {
  int id;
  DateTime dataAbertura;
  DateTime dataEncerramento;
  String descricao;

  Torneio({this.id, this.dataAbertura, this.dataEncerramento, this.descricao});
  Torneio.novo(this.dataAbertura, this.descricao);

  String dataAberturaFormatada() {
    String formattedDate = DateFormat('dd/MM/yyyy HH:MM').format(
        dataAbertura);
    return formattedDate;
  }

  String dataAberturaFormatadaDb() {
    String formattedDate = DateFormat('YYYY-MM-DD HH:MM:SS.SSS').format(
        dataAbertura);
    return formattedDate;
  }

  String dataEncerramentoFormatada() {
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(
        dataEncerramento);
    return formattedDate;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data_abertura': dataAbertura.millisecondsSinceEpoch,
      'data_encerramento': dataEncerramento != null ? dataEncerramento.millisecondsSinceEpoch : null,
      'descricao': descricao,
    };
  }

  @override
  String toString() {
    return 'Torneio{id: $id, dataAbertura: $dataAbertura, descricao: $descricao}';
  }
}
