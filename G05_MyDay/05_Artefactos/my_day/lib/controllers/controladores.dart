import '../data/myday_api.dart';
import 'admin_controller.dart';
import 'comunidade_controller.dart';
import 'perfil_controller.dart';
import 'projeto_controller.dart';
import 'registo_controller.dart';
import 'sessao_controller.dart';

class Controladores {
  final SessaoController sessao;
  final RegistoController registos;
  final ProjetoController projetos;
  final ComunidadeController comunidade;
  final PerfilController perfil;
  final AdminController admin;

  Controladores({
    required this.sessao,
    required this.registos,
    required this.projetos,
    required this.comunidade,
    required this.perfil,
    required this.admin,
  });
}

Future<void> carregarDadosDaApi(Controladores app) async {
  final eu = app.sessao.utilizador;
  if (!app.sessao.online || eu == null) {
    return;
  }
  await app.registos.carregarDaApi(
    euEmail: eu.email,
    euId: app.sessao.idNaApi!,
    lembrarAutor: app.sessao.lembrarAutor,
  );
  await app.projetos.carregarDaApi(eu.email);

  final seguimentos = await app.sessao.api.seguimentos();
  final aSeguir = <String>[];
  final seguidores = <String>[];
  for (final u in seguimentos['aSeguir']) {
    app.sessao.lembrarAutor('utilizador${u['id']}', u['nome']);
    aSeguir.add('utilizador${u['id']}');
  }
  for (final u in seguimentos['seguidores']) {
    app.sessao.lembrarAutor('utilizador${u['id']}', u['nome']);
    seguidores.add('utilizador${u['id']}');
  }
  app.comunidade.definirSeguimentos(eu.email, aSeguir, seguidores);
}

Controladores criarControladores() {
  final api = MyDayApi();
  final sessao = SessaoController(api: api);
  final registos = RegistoController(api: api);
  final projetos = ProjetoController(registos: registos);
  final comunidade = ComunidadeController(sessao: sessao, registos: registos);
  final perfil = PerfilController(sessao: sessao, registos: registos, projetos: projetos);
  final admin = AdminController(registos: registos, comunidade: comunidade);
  return Controladores(
    sessao: sessao,
    registos: registos,
    projetos: projetos,
    comunidade: comunidade,
    perfil: perfil,
    admin: admin,
  );
}
