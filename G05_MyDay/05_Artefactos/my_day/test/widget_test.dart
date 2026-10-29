import 'package:flutter_test/flutter_test.dart';

import 'package:my_day/controllers/admin_controller.dart';
import 'package:my_day/controllers/auth_controller.dart';
import 'package:my_day/controllers/community_controller.dart';
import 'package:my_day/controllers/entry_controller.dart';
import 'package:my_day/controllers/profile_controller.dart';
import 'package:my_day/controllers/project_controller.dart';
import 'package:my_day/models/entry.dart';
import 'package:my_day/main.dart';

void main() {
  // Testes ao Controller: não precisam de ecrã.
  test('login certo entra, login errado mostra erro', () {
    final auth = AuthController();

    expect(auth.login('rodrigo@escola.pt', 'errada'), false);
    expect(auth.errorMessage, 'Email ou palavra-passe incorretos.');

    expect(auth.login('rodrigo@escola.pt', '123456'), true);
    expect(auth.currentUser!.name, 'Rodrigo Rodrigues');
  });

  test('o Rodrigo tem 12 dias seguidos e só vê os seus registos', () {
    final auth = AuthController();
    final entries = EntryController();
    auth.login('rodrigo@escola.pt', '123456');

    expect(entries.streakDays(auth.currentUser), 12);
    expect(entries.entriesFor(auth.currentUser).length, 13);
  });

  test('mapa e calendário: contagens por local, dia e disciplina', () {
    final auth = AuthController();
    final entries = EntryController();
    auth.login('rodrigo@escola.pt', '123456');
    final user = auth.currentUser;

    // Como no Figma: Biblioteca IADE 3, Casa 5, Laboratório 2, Café 1, Jardim 1.
    final counts = {
      for (final place in entries.places)
        place.name: entries.entriesAtPlace(place, user, lastDays: 30).length,
    };
    expect(counts['Biblioteca IADE'], 3);
    expect(counts['Casa'], 5);
    expect(counts['Laboratório de Química'], 2);

    expect(entries.entriesOnDay(user, DateTime.now()).length, 2);
    expect(entries.totalEntries(user), 13);
    expect(entries.entriesPerSubject(user).first.value, 4);
  });

  test('projetos: filtro, registos do projeto, criar e mudar de nome', () {
    final auth = AuthController();
    final entries = EntryController();
    final projects = ProjectController(entryController: entries);
    auth.login('rodrigo@escola.pt', '123456');
    final user = auth.currentUser;

    expect(projects.projectsFor(user).length, 4);
    expect(projects.projectsFor(user, filter: EntryVisibility.friends).length, 2);
    expect(projects.projectsFor(null).length, 1); // convidado: só "App MyDay"

    final app = projects.projectsFor(user).firstWhere((p) => p.name == 'App MyDay');
    expect(projects.entriesOf(app, user).length, 5);

    expect(projects.createProject(user!, 'App MyDay'), 'Já tens um projeto com esse nome.');
    expect(projects.createProject(user, 'Química'), null);

    projects.editProject(app, 'MyDay', app.description);
    expect(projects.entriesOf(app, user).length, 5); // os registos seguem o nome novo
    projects.editProject(app, 'App MyDay', app.description);
  });

  test('comunidade: a seguir, descobrir, pesquisa e regra "só amigos"', () {
    final auth = AuthController();
    final entries = EntryController();
    final community = CommunityController(entryController: entries);
    auth.login('rodrigo@escola.pt', '123456');
    final user = auth.currentUser;

    // A seguir: Cecília (só amigos) e Tiago (público), do mais recente para o mais antigo.
    final following = community.feed(user, followingOnly: true);
    expect(following.map((e) => e.title).toList(), ['Titulação Ácido-Base', 'Listas Ligadas']);

    // Descobrir: só públicos de quem não sigo.
    expect(community.feed(user, followingOnly: false).map((e) => e.title),
        ['Resumo de Física – exame', 'Estado com setState']);

    // Pesquisa pelo nome do autor.
    expect(community.feed(user, followingOnly: true, query: 'tiago').length, 1);

    // Um convidado não vê o registo "só amigos" da Cecília.
    expect(community.feed(null, followingOnly: false).any((e) => e.title == 'Titulação Ácido-Base'), false);

    // Deixar de seguir a Cecília esconde o registo dela.
    community.toggleFollow(user!, 'cecilia@escola.pt');
    expect(community.feed(user, followingOnly: true).length, 1);
    community.toggleFollow(user, 'cecilia@escola.pt');
  });

  test('administração: ocultar, ignorar, denunciar e registo de ações', () {
    final auth = AuthController();
    final entries = EntryController();
    final community = CommunityController(entryController: entries);
    final admin = AdminController(entryController: entries, communityController: community);
    auth.login('admin@escola.pt', 'admin123');
    final lurdes = auth.currentUser!;
    expect(admin.adminHandle(lurdes), 'lurdes.admin');

    // As duas denúncias do Figma.
    expect(admin.openReports.length, 2);
    final copied = admin.openReports.firstWhere((r) => r.reason == 'Conteúdo copiado');
    final offensive = admin.openReports.firstWhere((r) => r.comment != null);
    expect(admin.authorOf(offensive), 'estudante_10');
    expect(offensive.title, 'Comentário em «Listas Ligadas»');

    // Ocultar o registo copiado: desaparece da Comunidade.
    final actionsBefore = admin.actions.length;
    admin.hide(copied, lurdes);
    expect(community.feed(null, followingOnly: false).any((e) => e.title == copied.entry.title), false);

    // Ocultar o comentário ofensivo: é apagado do registo.
    final commentsBefore = offensive.entry.comments.length;
    admin.hide(offensive, lurdes);
    expect(offensive.entry.comments.length, commentsBefore - 1);
    expect(admin.openReports, isEmpty);
    expect(admin.actions.length, actionsBefore + 2);
    expect(admin.actions.first.description, 'ocultou «Comentário em «Listas Ligadas»»');

    // Duas denúncias iguais contam como uma, com 2 pessoas.
    final entry = entries.allEntries.firstWhere((e) => e.title == 'Listas Ligadas');
    entries.reportEntry(entry, 'Spam');
    entries.reportEntry(entry, 'Spam');
    expect(admin.openReports.single.count, 2);
    admin.ignore(admin.openReports.single, lurdes);

    expect(admin.publishChallenge(lurdes, '  '), 'Escreve o desafio.');
    expect(admin.publishChallenge(lurdes, 'Faz um mapa mental'), null);
    expect(community.challenge, 'Faz um mapa mental');
  });

  test('perfil: conquistas, configurações e apagar conta', () {
    final auth = AuthController();
    final entries = EntryController();
    final projects = ProjectController(entryController: entries);
    final community = CommunityController(entryController: entries);
    final profile = ProfileController(
      authController: auth, entryController: entries, projectController: projects);

    auth.login('rodrigo@escola.pt', '123456');
    final user = auth.currentUser!;

    // 12 dias seguidos e um projeto público: as duas primeiras conquistas estão desbloqueadas.
    final unlocked = profile.achievementsOf(user).map((a) => a.unlocked).toList();
    expect(unlocked, [true, true, false]);

    expect(profile.reminderText(user), 'Todos os dias às 21:00');
    profile.setReminderTime(user, 8, 5);
    expect(profile.reminderText(user), 'Todos os dias às 08:05');

    expect(community.followingCount(user), 2);
    expect(community.followersCount(user), 2);

    // Apagar a conta de um colega remove-o e aos seus registos.
    auth.login('ines@escola.pt', '123456');
    final ines = auth.currentUser!;
    profile.deleteAccount(ines);
    expect(auth.currentUser, null);
    expect(auth.login('ines@escola.pt', '123456'), false);
    expect(entries.allEntries.any((e) => e.authorEmail == 'ines@escola.pt'), false);
  });

  test('criar registo: valida o título e depois aparece no Diário', () {
    final auth = AuthController();
    final entries = EntryController();
    auth.login('rodrigo@escola.pt', '123456');
    final before = entries.entriesFor(auth.currentUser).length;

    String? error = entries.createEntry(
      author: auth.currentUser!, title: '  ', text: '', subject: 'Redes',
      project: null, tags: [], visibility: EntryVisibility.private,
      withLocation: false, photoCount: 0, withAudio: false, withVideo: false,
    );
    expect(error, 'Escreve um título para o registo.');

    error = entries.createEntry(
      author: auth.currentUser!, title: 'Teste', text: 'Olá', subject: 'Redes',
      project: 'Redes', tags: entries.parseTags('#a b, #a'),
      visibility: EntryVisibility.public, withLocation: true,
      photoCount: 2, withAudio: false, withVideo: true,
    );
    expect(error, null);

    final newest = entries.entriesFor(auth.currentUser).first;
    expect(entries.entriesFor(auth.currentUser).length, before + 1);
    expect(newest.title, 'Teste');
    expect(newest.tags, ['a', 'b']);
    expect(newest.locationName, 'Biblioteca IADE');
  });

  test('registo: comentar, favoritar e só o autor pode apagar', () {
    final auth = AuthController();
    final entries = EntryController();
    final entry = entries.entriesFor(null).first; // um registo público

    expect(entries.addComment(entry, null, 'Olá'),
        'Os convidados não podem comentar. Cria uma conta.');

    auth.login('rodrigo@escola.pt', '123456');
    final before = entry.comments.length;
    expect(entries.addComment(entry, auth.currentUser, 'Boa!'), null);
    expect(entry.comments.length, before + 1);

    entries.toggleFavorite(entry);
    expect(entries.isFavorite(entry), true);

    expect(entries.isOwner(entry, auth.currentUser), true);
    expect(entries.isOwner(entry, null), false);
  });

  test('um convidado só vê registos públicos', () {
    final entries = EntryController();
    for (final entry in entries.entriesFor(null)) {
      expect(entry.visibility, EntryVisibility.public);
    }
  });

  test('o administrador é reconhecido', () {
    final auth = AuthController();
    auth.login('admin@escola.pt', 'admin123');
    expect(auth.isAdmin, true);
  });

  // Teste à View: o ecrã de Entrar mostra os textos do Figma.
  testWidgets('ecrã de Entrar mostra os elementos principais', (tester) async {
    await tester.pumpWidget(MyDayApp());

    expect(find.text('MyDay'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Continuar como convidado'), findsOneWidget);
  });
}
