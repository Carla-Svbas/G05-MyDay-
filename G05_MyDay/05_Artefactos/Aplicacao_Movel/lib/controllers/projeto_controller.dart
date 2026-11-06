import 'package:flutter/foundation.dart';

import '../data/projetos_demo.dart';
import '../models/grupo_estudo.dart';
import '../models/projeto.dart';
import '../models/registo.dart';
import '../models/utilizador.dart';
import 'registo_controller.dart';

class ProjetoController extends ChangeNotifier {
  final RegistoController registos;
  final List<Projeto> _projetos = List.of(projetosDemo);
  int _proximoId = 100;

  ProjetoController({required this.registos});

  List<GrupoEstudo> get grupos => gruposDemo;

  Future<void> carregarDaApi(String euEmail) async {
    final lista = await registos.api!.meusProjetos();
    _projetos.removeWhere((p) => p.donoEmail == euEmail);
    for (var i = 0; i < lista.length; i++) {
      final dados = lista[i];
      _projetos.add(Projeto(
        id: dados['id'],
        donoEmail: euEmail,
        nome: dados['titulo'],
        descricao: dados['descricao'] ?? '',
        visibilidade: Visibilidade.values.byName(dados['visibilidade']),
        criadoEm: registos.lerData(dados['criadoEm']),
        cor: i % 4,
      ));
    }
    notifyListeners();
  }

  int? idDoProjeto(String? nome) {
    for (final p in _projetos) {
      if (p.nome == nome) {
        return p.id;
      }
    }
    return null;
  }

  List<Projeto> projetosDe(Utilizador? utilizador, {Visibilidade? filtro}) {
    final lista = <Projeto>[];
    for (final p in _projetos) {
      final meu = utilizador != null && p.donoEmail == utilizador.email;
      final publico = p.visibilidade == Visibilidade.publico;
      final passaFiltro = filtro == null || p.visibilidade == filtro;
      if ((meu || (utilizador == null && publico)) && passaFiltro) {
        lista.add(p);
      }
    }
    return lista;
  }

  Projeto? procurar(int id) {
    for (final p in _projetos) {
      if (p.id == id) {
        return p;
      }
    }
    return null;
  }

  List<String> nomesProjetos(Utilizador? utilizador) {
    return projetosDe(utilizador).map((p) => p.nome).toList();
  }

  List<Registo> registosDoProjeto(Projeto projeto, Utilizador? utilizador) {
    return registos.registosDe(utilizador).where((r) => r.projeto == projeto.nome).toList();
  }

  int numeroDisciplinas(Projeto projeto, Utilizador? utilizador) {
    final disciplinas = <String>{};
    for (final r in registosDoProjeto(projeto, utilizador)) {
      disciplinas.add(r.disciplina);
    }
    return disciplinas.length;
  }

  bool temProjetoPublico(Utilizador utilizador) {
    return projetosDe(utilizador).any((p) => p.visibilidade == Visibilidade.publico);
  }

  String? criar(Utilizador utilizador, String nome) {
    nome = nome.trim();
    if (nome.isEmpty) {
      return 'Escreve o nome do projeto.';
    }
    for (final p in projetosDe(utilizador)) {
      if (p.nome.toLowerCase() == nome.toLowerCase()) {
        return 'Já tens um projeto com esse nome.';
      }
    }
    _projetos.add(Projeto(
      id: _proximoId++,
      donoEmail: utilizador.email,
      nome: nome,
      descricao: '',
      criadoEm: DateTime.now(),
      cor: _projetos.length,
    ));
    notifyListeners();
    return null;
  }

  String? editar(int id, String nome, String descricao) {
    nome = nome.trim();
    if (nome.isEmpty) {
      return 'O nome não pode ficar vazio.';
    }
    final i = _projetos.indexWhere((p) => p.id == id);
    if (i < 0) {
      return 'Este projeto já não existe.';
    }
    registos.mudarNomeProjeto(_projetos[i].nome, nome);
    _projetos[i] = _projetos[i].copyWith(nome: nome, descricao: descricao.trim());
    notifyListeners();
    return null;
  }

  void mudarVisibilidade(int id, Visibilidade visibilidade) {
    final i = _projetos.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _projetos[i] = _projetos[i].copyWith(visibilidade: visibilidade);
      notifyListeners();
    }
  }
}
