import 'jogador.dart';

class Time {
  final String nome;
  final List<Jogador> jogadores;
  final String cor;
  
  Time({
    required this.nome,
    required this.jogadores,
    required this.cor,
  });

  double get overallMedio {
    if (jogadores.isEmpty) return 0.0;
    return jogadores.map((j) => j.overall).reduce((a, b) => a + b) / jogadores.length;
  }

  int get totalOverall => jogadores.map((j) => j.overall).fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'jogadores': jogadores.map((j) => j.toJson()).toList(),
      'cor': cor,
    };
  }

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      nome: json['nome'] as String,
      jogadores: (json['jogadores'] as List)
          .map((j) => Jogador.fromJson(j as Map<String, dynamic>))
          .toList(),
      cor: json['cor'] as String,
    );
  }

  @override
  String toString() => 'Time(nome: $nome, jogadores: ${jogadores.length}, overall: ${overallMedio.toStringAsFixed(1)})';
}