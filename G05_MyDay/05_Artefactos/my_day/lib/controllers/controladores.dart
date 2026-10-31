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

Controladores criarControladores() {
  final sessao = SessaoController();
  final registos = RegistoController();
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
