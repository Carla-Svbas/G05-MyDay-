import 'package:flutter_test/flutter_test.dart';

import 'package:my_day/controllers/controladores.dart';
import 'package:my_day/main.dart';
import 'package:my_day/models/registo.dart';

void main() {
  test('login certo entra e login errado mostra erro', () {
    final app = criarControladores();
    expect(app.sessao.entrar('rodrigo@escola.pt', 'errada'), false);
    expect(app.sessao.erro, 'Email ou palavra-passe incorretos.');
    expect(app.sessao.entrar('rodrigo@escola.pt', '123456'), true);
    expect(app.sessao.utilizador!.nome, 'Rodrigo Rodrigues');
  });

  test('o administrador é reconhecido', () {
    final app = criarControladores();
    app.sessao.entrar('admin@escola.pt', 'admin123');
    expect(app.sessao.admin, true);
  });

  test('o Rodrigo tem 12 dias seguidos e 13 registos', () {
    final app = criarControladores();
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final rodrigo = app.sessao.utilizador;
    expect(app.registos.diasSeguidos(rodrigo), 12);
    expect(app.registos.total(rodrigo), 13);
  });

  test('um convidado só vê registos públicos', () {
    final app = criarControladores();
    for (final r in app.registos.registosDe(null)) {
      expect(r.visibilidade, Visibilidade.publico);
    }
  });

  test('criar registo valida o título e depois aparece na lista', () {
    final app = criarControladores();
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final rodrigo = app.sessao.utilizador!;

    final erro = app.registos.criarRegisto(
      autor: rodrigo,
      titulo: ' ',
      texto: '',
      disciplina: 'Redes',
      projeto: null,
      tags: [],
      visibilidade: Visibilidade.privado,
      comLocal: false,
      fotos: 0,
      comAudio: false,
      comVideo: false,
    );
    expect(erro, 'Escreve um título para o registo.');

    app.registos.criarRegisto(
      autor: rodrigo,
      titulo: 'Teste',
      texto: 'Olá',
      disciplina: 'Redes',
      projeto: 'Redes',
      tags: app.registos.lerTags('#a b, #a'),
      visibilidade: Visibilidade.publico,
      comLocal: true,
      fotos: 2,
      comAudio: false,
      comVideo: true,
    );
    final novo = app.registos.registosDe(rodrigo).first;
    expect(novo.titulo, 'Teste');
    expect(novo.tags, ['a', 'b']);
    expect(novo.local, 'Biblioteca IADE');
    expect(app.registos.total(rodrigo), 14);
  });

  test('comentar usa copyWith e convidados não podem comentar', () {
    final app = criarControladores();
    expect(
        app.registos.comentar(1, null, 'Olá'), 'Os convidados não podem comentar. Cria uma conta.');
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final antes = app.registos.procurar(1)!.comentarios.length;
    expect(app.registos.comentar(1, app.sessao.utilizador, 'Boa!'), null);
    expect(app.registos.procurar(1)!.comentarios.length, antes + 1);
  });

  test('mapa e calendário contam registos por local e por disciplina', () {
    final app = criarControladores();
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final rodrigo = app.sessao.utilizador;
    final biblioteca = app.registos.locais.first;
    expect(app.registos.registosNoLocal(rodrigo, biblioteca, true).length, 3);
    expect(app.registos.registosNoDia(rodrigo, DateTime.now()).length, 2);
    expect(app.registos.porDisciplina(rodrigo).values.first, 4);
  });

  test('projetos: filtro, criar e mudar de nome', () {
    final app = criarControladores();
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final rodrigo = app.sessao.utilizador!;
    expect(app.projetos.projetosDe(rodrigo).length, 4);
    expect(app.projetos.projetosDe(rodrigo, filtro: Visibilidade.amigos).length, 2);
    expect(app.projetos.criar(rodrigo, 'App MyDay'), 'Já tens um projeto com esse nome.');

    final appMyDay = app.projetos.projetosDe(rodrigo).firstWhere((p) => p.nome == 'App MyDay');
    expect(app.projetos.registosDoProjeto(appMyDay, rodrigo).length, 5);
    app.projetos.editar(appMyDay.id, 'MyDay', '');
    final renomeado = app.projetos.procurar(appMyDay.id)!;
    expect(app.projetos.registosDoProjeto(renomeado, rodrigo).length, 5);
  });

  test('comunidade: a seguir, descobrir e pesquisa', () {
    final app = criarControladores();
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final rodrigo = app.sessao.utilizador!;
    final aSeguir = app.comunidade.feed(rodrigo, true, '');
    expect(aSeguir.map((r) => r.titulo).toList(), ['Titulação Ácido-Base', 'Listas Ligadas']);
    expect(app.comunidade.feed(rodrigo, true, 'tiago').length, 1);
    app.comunidade.alternarSeguir(rodrigo, 'cecilia@escola.pt');
    expect(app.comunidade.feed(rodrigo, true, '').length, 1);
  });

  test('perfil: conquistas e lembretes', () {
    final app = criarControladores();
    app.sessao.entrar('rodrigo@escola.pt', '123456');
    final rodrigo = app.sessao.utilizador!;
    final desbloqueadas = app.perfil.conquistas(rodrigo).map((c) => c.desbloqueada).toList();
    expect(desbloqueadas, [true, true, false]);
    app.perfil.mudarHora(rodrigo, 8, 5);
    expect(app.perfil.textoLembrete(rodrigo), 'Todos os dias às 08:05');
  });

  test('administração: ocultar, denunciar e registo de ações', () {
    final app = criarControladores();
    app.sessao.entrar('admin@escola.pt', 'admin123');
    final lurdes = app.sessao.utilizador!;
    expect(app.admin.denuncias.length, 2);

    final copiado = app.admin.denuncias.first;
    app.admin.ocultar(copiado, lurdes);
    expect(app.comunidade.feed(null, false, '').any((r) => r.id == copiado.registoId), false);
    expect(app.admin.acoes.first.descricao, 'ocultou «Resumo de Física – exame»');

    app.registos.denunciar(15, 'Spam');
    app.registos.denunciar(15, 'Spam');
    expect(app.admin.denuncias.last.pessoas, 2);
  });

  testWidgets('o ecrã de Entrar mostra os elementos principais', (tester) async {
    await tester.pumpWidget(MyDayApp(app: criarControladores()));
    expect(find.text('MyDay'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Continuar como convidado'), findsOneWidget);
  });
}
