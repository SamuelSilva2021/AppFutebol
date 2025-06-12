import 'dart:math';
import 'package:futebol_wallace/models/jogador.dart';
import '../../models/time.dart';

class SorteioService {
  static const List<String> _coresTime = [
    '#FF5722', // Vermelho
    '#2196F3', // Azul
    '#4CAF50', // Verde
    '#FF9800', // Laranja
    '#9C27B0', // Roxo
    '#795548', // Marrom
    '#607D8B', // Azul Acinzentado
    '#E91E63', // Rosa
  ];
  
  static List<Time> sortearTimes(List<Jogador> jogadores, {required int jogadoresPorTime}) {
    if (jogadores.length < jogadoresPorTime) {
      throw Exception('É necessário pelo menos $jogadoresPorTime jogadores para formar um time');
    }
    
    final int numeroTimes = jogadores.length ~/ jogadoresPorTime;
    final List<Time> times = [];
    
    // Ordenar jogadores por overall (maior para menor)
    final jogadoresOrdenados = List<Jogador>.from(jogadores)
      ..sort((a, b) => b.overall.compareTo(a.overall));
    
    // Criar times vazios
    for (int i = 0; i < numeroTimes; i++) {
      times.add(Time(
        nome: 'Time ${String.fromCharCode(65 + i)}', // A, B, C, etc.
        jogadores: [],
        cor: _coresTime[i % _coresTime.length],
      ));
    }
    
    // Distribuir jogadores de forma balanceada
    for (int i = 0; i < jogadoresOrdenados.length; i++) {
      final timeIndex = i % numeroTimes;
      if (times[timeIndex].jogadores.length < jogadoresPorTime) {
        times[timeIndex].jogadores.add(jogadoresOrdenados[i]);
      }
    }
    
    // Embaralhar a ordem dos jogadores dentro de cada time
    final random = Random();
    for (final time in times) {
      time.jogadores.shuffle(random);
    }
    
    return times;
  }
  
  static List<Jogador> getJogadoresSobra(List<Jogador> todosJogadores, List<Time> times) {
    final jogadoresNosTime = <String>{};
    for (final time in times) {
      for (final jogador in time.jogadores) {
        jogadoresNosTime.add(jogador.id);
      }
    }
    
    return todosJogadores.where((j) => !jogadoresNosTime.contains(j.id)).toList();
  }
  
  static String getEstatisticasSorteio(List<Time> times) {
    if (times.isEmpty) return 'Nenhum time formado';
    
    final overallMedio = times.map((t) => t.overallMedio).reduce((a, b) => a + b) / times.length;
    final maiorOverall = times.map((t) => t.overallMedio).reduce((a, b) => a > b ? a : b);
    final menorOverall = times.map((t) => t.overallMedio).reduce((a, b) => a < b ? a : b);
    final diferenca = maiorOverall - menorOverall;
    
    return '''Times formados: ${times.length}
Overall médio geral: ${overallMedio.toStringAsFixed(1)}
Diferença entre times: ${diferenca.toStringAsFixed(1)}
Balanceamento: ${diferenca <= 5 ? 'Excelente' : diferenca <= 10 ? 'Bom' : 'Regular'}''';
  }
}