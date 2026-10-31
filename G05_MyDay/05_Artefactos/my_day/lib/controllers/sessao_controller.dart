import 'package:flutter/foundation.dart';

import '../data/utilizadores_demo.dart';
import '../models/utilizador.dart';

class SessaoController extends ChangeNotifier {
  final List<Utilizador> _utilizadores = List.of(utilizadoresDemo);
  Utilizador? utilizador;
  bool convidado = false;
  String? erro;
  bool semConta = false;

  List<Utilizador> get utilizadores => List.unmodifiable(_utilizadores);

  bool get admin => utilizador != null && utilizador!.admin;

  bool entrar(String email, String palavraPasse) {
    email = email.trim().toLowerCase();
    semConta = false;
    if (!_dadosValidos(email, palavraPasse)) {
      return false;
    }
    semConta = !existeConta(email);
    if (semConta) {
      erro = 'Não existe nenhuma conta com este email. Cria uma conta.';
      return false;
    }
    for (final u in _utilizadores) {
      if (u.email == email && u.palavraPasse == palavraPasse) {
        utilizador = u;
        convidado = false;
        erro = null;
        notifyListeners();
        return true;
      }
    }
    erro = 'Palavra-passe incorreta.';
    return false;
  }

  bool existeConta(String email) {
    email = email.trim().toLowerCase();
    for (final u in _utilizadores) {
      if (u.email == email) {
        return true;
      }
    }
    return false;
  }

  bool criarConta({
    required String nome,
    required String email,
    required String palavraPasse,
    required String confirmarPalavraPasse,
    required String curso,
  }) {
    email = email.trim().toLowerCase();
    if (nome.trim().isEmpty) {
      erro = 'Escreve o teu nome.';
      return false;
    }
    if (!_dadosValidos(email, palavraPasse)) {
      return false;
    }
    if (palavraPasse.length < 6) {
      erro = 'A palavra-passe precisa de pelo menos 6 caracteres.';
      return false;
    }
    if (palavraPasse != confirmarPalavraPasse) {
      erro = 'As palavras-passe não são iguais.';
      return false;
    }
    if (existeConta(email)) {
      erro = 'Já existe uma conta com este email.';
      return false;
    }
    final novo = Utilizador(
      nome: nome.trim(),
      email: email,
      palavraPasse: palavraPasse,
      curso: curso.trim(),
    );
    _utilizadores.add(novo);
    utilizador = novo;
    convidado = false;
    erro = null;
    notifyListeners();
    return true;
  }

  void entrarComoConvidado() {
    utilizador = null;
    convidado = true;
    erro = null;
    notifyListeners();
  }

  void sair() {
    utilizador = null;
    convidado = false;
    notifyListeners();
  }

  void apagarConta(Utilizador u) {
    _utilizadores.removeWhere((x) => x.email == u.email);
    sair();
  }

  String nomeDe(String email) {
    for (final u in _utilizadores) {
      if (u.email == email) {
        return u.nome;
      }
    }
    return email;
  }

  bool _dadosValidos(String email, String palavraPasse) {
    if (email.isEmpty || palavraPasse.isEmpty) {
      erro = 'Preenche o email e a palavra-passe.';
      return false;
    }
    if (!email.contains('@') || !email.contains('.')) {
      erro = 'Escreve um email válido.';
      return false;
    }
    return true;
  }
}
