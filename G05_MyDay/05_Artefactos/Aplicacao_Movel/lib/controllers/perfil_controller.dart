import 'package:flutter/foundation.dart';

import '../models/conquista.dart';
import '../models/definicoes.dart';
import '../models/utilizador.dart';
import 'projeto_controller.dart';
import 'registo_controller.dart';
import 'sessao_controller.dart';

class PerfilController extends ChangeNotifier {
  final SessaoController sessao;
  final RegistoController registos;
  final ProjetoController projetos;
  final Map<String, Definicoes> _definicoes = {};

  PerfilController({
    required this.sessao,
    required this.registos,
    required this.projetos,
  });

  Definicoes definicoesDe(Utilizador utilizador) {
    return _definicoes[utilizador.email] ?? const Definicoes();
  }

  void mudarLocalizacao(Utilizador utilizador, bool valor) {
    _definicoes[utilizador.email] = definicoesDe(utilizador).copyWith(localizacao: valor);
    notifyListeners();
  }

  void mudarMicrofone(Utilizador utilizador, bool valor) {
    _definicoes[utilizador.email] = definicoesDe(utilizador).copyWith(microfone: valor);
    notifyListeners();
  }

  void mudarLembretes(Utilizador utilizador, bool valor) {
    _definicoes[utilizador.email] = definicoesDe(utilizador).copyWith(lembretes: valor);
    notifyListeners();
  }

  void mudarHora(Utilizador utilizador, int hora, int minuto) {
    _definicoes[utilizador.email] = definicoesDe(utilizador).copyWith(hora: hora, minuto: minuto);
    notifyListeners();
  }

  String textoLembrete(Utilizador utilizador) {
    final d = definicoesDe(utilizador);
    if (!d.lembretes) {
      return 'Desligados';
    }
    final hora = d.hora.toString().padLeft(2, '0');
    final minuto = d.minuto.toString().padLeft(2, '0');
    return 'Todos os dias às $hora:$minuto';
  }

  List<Conquista> conquistas(Utilizador utilizador) {
    final dias = registos.diasSeguidos(utilizador);
    return [
      Conquista(titulo: '7 dias seguidos', tipo: 'dias', desbloqueada: dias >= 7),
      Conquista(
        titulo: '1.º projeto público',
        tipo: 'projeto',
        desbloqueada: projetos.temProjetoPublico(utilizador),
      ),
      Conquista(titulo: '30 dias seguidos', tipo: 'dias', desbloqueada: dias >= 30),
    ];
  }

  void apagarConta(Utilizador utilizador) {
    registos.apagarRegistosDe(utilizador.email);
    sessao.apagarConta(utilizador);
    _definicoes.remove(utilizador.email);
    notifyListeners();
  }
}
