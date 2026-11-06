import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiErro implements Exception {
  final String mensagem;
  final int estado;
  final bool semConta;

  ApiErro(this.mensagem, this.estado, {this.semConta = false});
}

class SemLigacao implements Exception {}

String enderecoPorDefeito() {
  const definido = String.fromEnvironment('API');
  if (definido.isNotEmpty) {
    return definido;
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000/api';
  }
  return 'http://localhost:3000/api';
}

class MyDayApi {
  final String endereco;
  String? token;

  MyDayApi({String? endereco}) : endereco = endereco ?? enderecoPorDefeito();

  bool get ligado => token != null;

  Future<dynamic> pedido(String metodo, String caminho, {Map<String, dynamic>? corpo}) async {
    final cabecalhos = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$endereco$caminho');
    final http.Response resposta;
    try {
      final envio = metodo == 'GET'
          ? http.get(uri, headers: cabecalhos)
          : http.post(uri, headers: cabecalhos, body: jsonEncode(corpo ?? {}));
      resposta = await envio.timeout(const Duration(seconds: 4));
    } on TimeoutException {
      throw SemLigacao();
    } catch (_) {
      throw SemLigacao();
    }
    final dados = resposta.body.isEmpty ? null : jsonDecode(utf8.decode(resposta.bodyBytes));
    if (resposta.statusCode >= 400) {
      final erro = dados is Map ? dados : {};
      throw ApiErro(
        erro['erro'] ?? 'Erro ${resposta.statusCode}',
        resposta.statusCode,
        semConta: erro['semConta'] == true,
      );
    }
    return dados;
  }

  Future<Map<String, dynamic>> entrar(String email, String palavraPasse) async {
    final dados = await pedido('POST', '/auth/login', corpo: {'email': email, 'password': palavraPasse});
    token = dados['token'];
    return dados['utilizador'];
  }

  Future<Map<String, dynamic>> registar(String nome, String email, String palavraPasse, String curso) async {
    final dados = await pedido('POST', '/auth/registar',
        corpo: {'nome': nome, 'email': email, 'password': palavraPasse, 'curso': curso});
    token = dados['token'];
    return dados['utilizador'];
  }

  Future<List<dynamic>> meusRegistos() async => await pedido('GET', '/registos');

  Future<List<dynamic>> feed() async => await pedido('GET', '/comunidade/feed');

  Future<Map<String, dynamic>> registo(int id) async => await pedido('GET', '/registos/$id');

  Future<Map<String, dynamic>> seguimentos() async => await pedido('GET', '/comunidade/seguimentos');

  Future<List<dynamic>> meusProjetos() async => await pedido('GET', '/projetos');

  Future<List<dynamic>> disciplinas() async => await pedido('GET', '/disciplinas');

  Future<Map<String, dynamic>> criarRegisto(Map<String, dynamic> dados) async =>
      await pedido('POST', '/registos', corpo: dados);

  Future<Map<String, dynamic>> comentar(int id, String texto) async =>
      await pedido('POST', '/registos/$id/comentarios', corpo: {'texto': texto});

  void sair() {
    token = null;
  }
}
