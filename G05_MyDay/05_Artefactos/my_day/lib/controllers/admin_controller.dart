import 'package:flutter/foundation.dart';

import '../data/comunidade_demo.dart';
import '../models/acao_admin.dart';
import '../models/denuncia.dart';
import '../models/utilizador.dart';
import 'comunidade_controller.dart';
import 'registo_controller.dart';

class AdminController extends ChangeNotifier {
  final RegistoController registos;
  final ComunidadeController comunidade;
  final List<AcaoAdmin> _acoes = List.of(acoesDemo);

  AdminController({required this.registos, required this.comunidade});

  List<AcaoAdmin> get acoes => List.unmodifiable(_acoes);
  List<Denuncia> get denuncias => registos.denuncias;
  int get utilizadores => comunidade.numeroUtilizadores;
  int get registosHoje => registos.registosHoje();
  int get totalRegistos => registos.todos.length;
  String get desafio => comunidade.desafio;

  String nomeAdmin(Utilizador admin) => '${admin.nome.toLowerCase()}.admin';

  String tituloDenuncia(Denuncia denuncia) {
    final registo = registos.procurar(denuncia.registoId);
    if (registo == null) {
      return 'Registo apagado';
    }
    if (denuncia.comentarioId != null) {
      return 'Comentário em «${registo.titulo}»';
    }
    return registo.titulo;
  }

  String autorDenuncia(Denuncia denuncia) {
    final registo = registos.procurar(denuncia.registoId);
    if (registo == null) {
      return '';
    }
    if (denuncia.comentarioId != null) {
      for (final c in registo.comentarios) {
        if (c.id == denuncia.comentarioId) {
          return c.autor;
        }
      }
    }
    return comunidade.nomeAutor(registo.autorEmail);
  }

  void ocultar(Denuncia denuncia, Utilizador admin) {
    final titulo = tituloDenuncia(denuncia);
    if (denuncia.comentarioId != null) {
      registos.apagarComentario(denuncia.registoId, denuncia.comentarioId!);
    } else {
      registos.ocultar(denuncia.registoId);
    }
    registos.fecharDenuncia(denuncia.id);
    _registarAcao(admin, 'ocultou «$titulo»');
  }

  void avisarAutor(Denuncia denuncia, Utilizador admin) {
    final autor = autorDenuncia(denuncia);
    registos.fecharDenuncia(denuncia.id);
    _registarAcao(admin, 'avisou $autor');
  }

  void ignorar(Denuncia denuncia, Utilizador admin) {
    final titulo = tituloDenuncia(denuncia);
    registos.fecharDenuncia(denuncia.id);
    _registarAcao(admin, 'ignorou a denúncia a «$titulo»');
  }

  Map<String, int> tags() {
    final contagem = <String, int>{};
    for (final r in registos.todos) {
      for (final tag in r.tags) {
        contagem[tag] = (contagem[tag] ?? 0) + 1;
      }
    }
    return contagem;
  }

  String? publicarDesafio(Utilizador admin, String texto) {
    if (texto.trim().isEmpty) {
      return 'Escreve o desafio.';
    }
    comunidade.mudarDesafio(texto.trim());
    _registarAcao(admin, 'publicou um desafio');
    return null;
  }

  void _registarAcao(Utilizador admin, String descricao) {
    _acoes.insert(
        0, AcaoAdmin(admin: nomeAdmin(admin), descricao: descricao, data: DateTime.now()));
    notifyListeners();
  }
}
