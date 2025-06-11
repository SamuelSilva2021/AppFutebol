import 'dart:convert';
import 'package:futebol_wallace/models/jogador.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JogadorService {
  static const String _key = 'jogadores';
  
  static Future<List<Jogador>> getJogadores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null || jsonString.isEmpty) {
      // Retorna jogadores de exemplo na primeira execução
      return _getJogadoresExemplo();
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Jogador.fromJson(json)).toList();
    } catch (e) {
      // Se houver erro na deserialização, retorna jogadores de exemplo
      return _getJogadoresExemplo();
    }
  }
  
  static Future<void> saveJogadores(List<Jogador> jogadores) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(jogadores.map((j) => j.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
  
  static Future<void> addJogador(Jogador jogador) async {
    final jogadores = await getJogadores();
    jogadores.add(jogador);
    await saveJogadores(jogadores);
  }
  
  static Future<void> updateJogador(Jogador jogadorAtualizado) async {
    final jogadores = await getJogadores();
    final index = jogadores.indexWhere((j) => j.id == jogadorAtualizado.id);
    if (index != -1) {
      jogadores[index] = jogadorAtualizado;
      await saveJogadores(jogadores);
    }
  }
  
  static Future<void> deleteJogador(String id) async {
    final jogadores = await getJogadores();
    jogadores.removeWhere((j) => j.id == id);
    await saveJogadores(jogadores);
  }
  
  static Future<bool> existeJogadorComNome(String nome, {String? excludeId}) async {
    final jogadores = await getJogadores();
    return jogadores.any((j) => 
        j.nome.toLowerCase() == nome.toLowerCase() && 
        (excludeId == null || j.id != excludeId)
    );
  }
  
  static List<Jogador> _getJogadoresExemplo() {
    return [
      Jogador(nome: 'Carlos Silva', overall: 85),
      Jogador(nome: 'João Santos', overall: 78),
      Jogador(nome: 'Pedro Oliveira', overall: 82),
      Jogador(nome: 'Lucas Costa', overall: 75),
      Jogador(nome: 'Bruno Lima', overall: 88),
      Jogador(nome: 'Rafael Souza', overall: 80),
      Jogador(nome: 'Diego Ferreira', overall: 76),
      Jogador(nome: 'Marcelo Alves', overall: 84),
      Jogador(nome: 'Gustavo Pereira', overall: 79),
      Jogador(nome: 'Thiago Rodrigues', overall: 81),
      Jogador(nome: 'Felipe Martins', overall: 77),
      Jogador(nome: 'Anderson Barbosa', overall: 83),
      Jogador(nome: 'Vinicius Gomes', overall: 74),
      Jogador(nome: 'Rodrigo Ribeiro', overall: 86),
      Jogador(nome: 'Gabriel Nascimento', overall: 79),
    ];
  }
}