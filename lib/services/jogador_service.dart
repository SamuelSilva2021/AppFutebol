import 'dart:convert';
import 'package:futebol_wallace/models/jogador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class JogadorService {
  static final DatabaseService _db = DatabaseService();
  
  static Future<List<Jogador>> getJogadores() async {
    return await _db.getJogadores();
  }
  
  static Future<void> saveJogadores(List<Jogador> jogadores) async {
    // Não é necessário implementar, pois cada operação é feita individualmente
  }
  
  static Future<void> addJogador(Jogador jogador) async {
    await _db.addJogador(jogador);
  }
  
  static Future<void> updateJogador(Jogador jogadorAtualizado) async {
    await _db.updateJogador(jogadorAtualizado);
  }
  
  static Future<void> deleteJogador(String id) async {
    await _db.deleteJogador(id);
  }
  
  static Future<bool> existeJogadorComNome(String nome, {String? excludeId}) async {
    return await _db.existeJogadorComNome(nome, excludeId: excludeId);
  }
}