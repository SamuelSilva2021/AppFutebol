import 'package:uuid/uuid.dart';

class Jogador {
  final String id;
  final String nome;
  final int overall;
  
  Jogador({
    String? id,
    required this.nome,
    required this.overall,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'overall': overall,
    };
  }

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      id: json['id'] as String,
      nome: json['nome'] as String,
      overall: json['overall'] as int,
    );
  }

  Jogador copyWith({
    String? nome,
    int? overall,
  }) {
    return Jogador(
      id: id,
      nome: nome ?? this.nome,
      overall: overall ?? this.overall,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Jogador && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Jogador(id: $id, nome: $nome, overall: $overall)';
}