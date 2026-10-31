import 'package:flutter/foundation.dart';

import '../data/utilizadores_demo.dart';
import '../models/utilizador.dart';

class SessaoController extends ChangeNotifier {
  final List<Utilizador> _utilizadores = List.of(utilizadoresDemo);
  Utilizador? utilizador;
  bool convidado = false;
  String? erro;

  List<Utilizador> get utilizadores => List.unmodifiable(_utilizadores);

  bool get admin => utilizador != null && utilizador!.admin;

  bool entrar(String email, String palavraPasse) {
    email = email.trim().toLowerCase();
    if (!_dadosValidos(email, palavraPasse)) {
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
    erro = 'Email ou palavra-passe incorretos.';
    return false;
  }

  bool criarConta(String email, String palavraPasse) {
    email = email.trim().toLowerCase();
    if (!_dadosValidos(email, palavraPasse)) {
      return false;
    }
    if (palavraPasse.length < 6) {
      erro = 'A palavra-passe precisa de pelo menos 6 caracteres.';
      return false;
    }
    for (final u in _utilizadores) {
      if (u.email == email) {
        erro = 'Já existe uma conta com este email.';
        return false;
      }
    }
    final novo = Utilizador(
      nome: email.split('@').first,
      email: email,
      palavraPasse: palavraPasse,
      curso: '',
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
