import 'package:flutter/foundation.dart';

import '../data/comunidade_demo.dart';
import '../data/projetos_demo.dart';
import '../models/grupo_estudo.dart';
import '../models/registo.dart';
import '../models/utilizador.dart';
import 'registo_controller.dart';
import 'sessao_controller.dart';

class ComunidadeController extends ChangeNotifier {
  final SessaoController sessao;
  final RegistoController registos;
  final Map<String, List<String>> _seguir = {};
  String _desafio = desafioDemo;

  ComunidadeController({required this.sessao, required this.registos}) {
    seguirDemo.forEach((email, lista) {
      _seguir[email] = List.of(lista);
    });
  }

  String get desafio => _desafio;
  List<GrupoEstudo> get grupos => gruposDemo;
  int get numeroUtilizadores => sessao.utilizadores.length;

  void mudarDesafio(String texto) {
    _desafio = texto;
    notifyListeners();
  }

  String nomeAutor(String email) => sessao.nomeDe(email);

  bool segue(Utilizador? utilizador, String email) {
    if (utilizador == null || _seguir[utilizador.email] == null) {
      return false;
    }
    return _seguir[utilizador.email]!.contains(email);
  }

  void definirSeguimentos(String euEmail, List<String> aSeguir, List<String> seguidores) {
    _seguir[euEmail] = List.of(aSeguir);
    for (final chave in seguidores) {
      _seguir[chave] ??= [];
      if (!_seguir[chave]!.contains(euEmail)) {
        _seguir[chave]!.add(euEmail);
      }
    }
    notifyListeners();
  }

  void alternarSeguir(Utilizador utilizador, String email) {
    _seguir[utilizador.email] ??= [];
    final lista = _seguir[utilizador.email]!;
    if (lista.contains(email)) {
      lista.remove(email);
    } else {
      lista.add(email);
    }
    notifyListeners();
  }

  List<Utilizador> aSeguir(Utilizador utilizador) {
    return sessao.utilizadores
        .where((u) => u.email != utilizador.email && segue(utilizador, u.email))
        .toList();
  }

  List<Utilizador> seguidores(Utilizador utilizador) {
    return sessao.utilizadores
        .where((u) => u.email != utilizador.email && segue(u, utilizador.email))
        .toList();
  }

  bool podeVer(Registo registo, Utilizador? utilizador) {
    if (utilizador != null && registo.autorEmail == utilizador.email) {
      return true;
    }
    if (registo.visibilidade == Visibilidade.publico) {
      return true;
    }
    if (registo.visibilidade == Visibilidade.amigos) {
      return segue(utilizador, registo.autorEmail);
    }
    return false;
  }

  List<Registo> feed(Utilizador? utilizador, bool soQuemSigo, String pesquisa) {
    final texto = pesquisa.trim().toLowerCase();
    final lista = <Registo>[];
    for (final r in registos.todos) {
      final meu = utilizador != null && r.autorEmail == utilizador.email;
      if (meu || r.oculto || !podeVer(r, utilizador)) {
        continue;
      }
      if (segue(utilizador, r.autorEmail) != soQuemSigo) {
        continue;
      }
      final tudo =
          '${r.titulo} ${r.texto} ${r.disciplina} ${nomeAutor(r.autorEmail)} ${r.tags.join(' ')}';
      if (texto.isNotEmpty && !tudo.toLowerCase().contains(texto)) {
        continue;
      }
      lista.add(r);
    }
    lista.sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }
}
