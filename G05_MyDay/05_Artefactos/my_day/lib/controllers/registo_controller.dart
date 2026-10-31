import 'package:flutter/foundation.dart';

import '../data/comunidade_demo.dart';
import '../data/locais_demo.dart';
import '../data/registos_demo.dart';
import '../models/comentario.dart';
import '../models/denuncia.dart';
import '../models/local.dart';
import '../models/registo.dart';
import '../models/utilizador.dart';

class RegistoController extends ChangeNotifier {
  final List<Registo> _registos = List.of(registosDemo);
  final List<Denuncia> _denuncias = List.of(denunciasDemo);
  final List<int> _favoritos = [];
  int _proximoId = 100;

  List<Registo> get todos => List.unmodifiable(_registos);
  List<Denuncia> get denuncias => List.unmodifiable(_denuncias);
  List<String> get disciplinas => disciplinasDemo;
  List<Local> get locais => locaisDemo;
  Local get localAtual => locaisDemo.first;

  Registo? procurar(int id) {
    for (final r in _registos) {
      if (r.id == id) {
        return r;
      }
    }
    return null;
  }

  List<Registo> registosDe(Utilizador? utilizador) {
    final lista = <Registo>[];
    for (final r in _registos) {
      final meu = utilizador != null && r.autorEmail == utilizador.email;
      final publico = r.visibilidade == Visibilidade.publico && !r.oculto;
      if (meu || (utilizador == null && publico)) {
        lista.add(r);
      }
    }
    lista.sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }

  int total(Utilizador? utilizador) => registosDe(utilizador).length;

  int diasSeguidos(Utilizador? utilizador) {
    final lista = registosDe(utilizador);
    var dias = 0;
    var dia = _soDia(DateTime.now());
    while (_temRegistoNoDia(lista, dia)) {
      dias++;
      dia = _somarDias(dia, -1);
    }
    return dias;
  }

  List<bool> semana(Utilizador? utilizador) {
    final lista = registosDe(utilizador);
    final segunda = _segundaFeira();
    final dias = <bool>[];
    for (var i = 0; i < 7; i++) {
      dias.add(_temRegistoNoDia(lista, _somarDias(segunda, i)));
    }
    return dias;
  }

  int registosDaSemana(Utilizador? utilizador) {
    final segunda = _segundaFeira();
    return registosDe(utilizador).where((r) => !r.data.isBefore(segunda)).length;
  }

  List<Registo> registosNoDia(Utilizador? utilizador, DateTime dia) {
    return registosDe(utilizador).where((r) => _soDia(r.data) == _soDia(dia)).toList();
  }

  int registosHoje() {
    return _registos.where((r) => _soDia(r.data) == _soDia(DateTime.now())).length;
  }

  List<Registo> registosNoLocal(Utilizador? utilizador, Local local, bool ultimos30Dias) {
    final inicio = _somarDias(_soDia(DateTime.now()), -29);
    final lista = <Registo>[];
    for (final r in registosDe(utilizador)) {
      final recente = !ultimos30Dias || !r.data.isBefore(inicio);
      if (r.local == local.nome && recente) {
        lista.add(r);
      }
    }
    return lista;
  }

  Local? localDe(Registo registo) {
    for (final l in locaisDemo) {
      if (l.nome == registo.local) {
        return l;
      }
    }
    return null;
  }

  Map<String, int> porDisciplina(Utilizador? utilizador) {
    final contagem = <String, int>{};
    for (final r in registosDe(utilizador)) {
      contagem[r.disciplina] = (contagem[r.disciplina] ?? 0) + 1;
    }
    final nomes = contagem.keys.toList();
    nomes.sort((a, b) => contagem[b]!.compareTo(contagem[a]!));
    final ordenado = <String, int>{};
    for (final nome in nomes) {
      ordenado[nome] = contagem[nome]!;
    }
    return ordenado;
  }

  String? criarRegisto({
    required Utilizador autor,
    required String titulo,
    required String texto,
    required String? disciplina,
    required String? projeto,
    required List<String> tags,
    required Visibilidade visibilidade,
    required bool comLocal,
    required int fotos,
    required bool comAudio,
    required bool comVideo,
  }) {
    if (titulo.trim().isEmpty) {
      return 'Escreve um título para o registo.';
    }
    if (disciplina == null) {
      return 'Escolhe a disciplina.';
    }
    _registos.add(Registo(
      id: _proximoId++,
      autorEmail: autor.email,
      disciplina: disciplina,
      titulo: titulo.trim(),
      texto: texto.trim(),
      data: DateTime.now(),
      visibilidade: visibilidade,
      projeto: projeto,
      tags: tags,
      local: comLocal ? localAtual.nome : null,
      morada: comLocal ? localAtual.morada : null,
      audio: comAudio ? '0:15' : null,
      video: comVideo ? '0:30' : null,
      fotos: fotos,
    ));
    notifyListeners();
    return null;
  }

  List<String> lerTags(String texto) {
    final tags = <String>[];
    for (final palavra in texto.split(RegExp(r'[\s,]+'))) {
      final tag = palavra.replaceAll('#', '').trim();
      if (tag.isNotEmpty && !tags.contains(tag)) {
        tags.add(tag);
      }
    }
    return tags;
  }

  bool favorito(int id) => _favoritos.contains(id);

  void alternarFavorito(int id) {
    if (_favoritos.contains(id)) {
      _favoritos.remove(id);
    } else {
      _favoritos.add(id);
    }
    notifyListeners();
  }

  bool eDono(Registo registo, Utilizador? utilizador) {
    return utilizador != null && registo.autorEmail == utilizador.email;
  }

  void apagar(int id) {
    _registos.removeWhere((r) => r.id == id);
    _favoritos.remove(id);
    notifyListeners();
  }

  void apagarRegistosDe(String email) {
    _registos.removeWhere((r) => r.autorEmail == email);
    notifyListeners();
  }

  String? comentar(int id, Utilizador? utilizador, String texto) {
    if (utilizador == null) {
      return 'Os convidados não podem comentar. Cria uma conta.';
    }
    if (texto.trim().isEmpty) {
      return 'Escreve o comentário antes de enviar.';
    }
    final i = _registos.indexWhere((r) => r.id == id);
    if (i < 0) {
      return 'Este registo já não existe.';
    }
    final novo = Comentario(
      id: _proximoId++,
      autor: utilizador.nome,
      texto: texto.trim(),
      data: DateTime.now(),
    );
    _registos[i] = _registos[i].copyWith(
      comentarios: [..._registos[i].comentarios, novo],
    );
    notifyListeners();
    return null;
  }

  void mudarNomeProjeto(String antigo, String novo) {
    for (var i = 0; i < _registos.length; i++) {
      if (_registos[i].projeto == antigo) {
        _registos[i] = _registos[i].copyWith(projeto: novo);
      }
    }
    notifyListeners();
  }

  void denunciar(int registoId, String motivo) {
    final i = _denuncias.indexWhere(
        (d) => d.registoId == registoId && d.comentarioId == null && d.motivo == motivo);
    if (i >= 0) {
      _denuncias[i] = _denuncias[i].copyWith(pessoas: _denuncias[i].pessoas + 1);
    } else {
      _denuncias.add(Denuncia(id: _proximoId++, registoId: registoId, motivo: motivo));
    }
    notifyListeners();
  }

  void fecharDenuncia(int id) {
    _denuncias.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void ocultar(int registoId) {
    final i = _registos.indexWhere((r) => r.id == registoId);
    if (i >= 0) {
      _registos[i] = _registos[i].copyWith(oculto: true);
      notifyListeners();
    }
  }

  void apagarComentario(int registoId, int comentarioId) {
    final i = _registos.indexWhere((r) => r.id == registoId);
    if (i < 0) {
      return;
    }
    final comentarios = _registos[i].comentarios.where((c) => c.id != comentarioId).toList();
    _registos[i] = _registos[i].copyWith(comentarios: comentarios);
    notifyListeners();
  }

  bool _temRegistoNoDia(List<Registo> lista, DateTime dia) {
    for (final r in lista) {
      if (_soDia(r.data) == dia) {
        return true;
      }
    }
    return false;
  }

  DateTime _soDia(DateTime data) => DateTime(data.year, data.month, data.day);

  DateTime _somarDias(DateTime data, int dias) {
    return DateTime(data.year, data.month, data.day + dias);
  }

  DateTime _segundaFeira() {
    final hoje = _soDia(DateTime.now());
    return _somarDias(hoje, -(hoje.weekday - 1));
  }
}
