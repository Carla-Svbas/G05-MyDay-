import '../models/comment.dart';
import '../models/entry.dart';
import '../models/map_place.dart';
import '../models/project.dart';
import '../models/report.dart';
import '../models/user.dart';

/// Dados de exemplo, iguais aos que aparecem no Figma.
/// Substituem uma base de dados enquanto a app é um protótipo.
List<User> sampleUsers = [
  User(
    name: 'Rodrigo Rodrigues',
    email: 'rodrigo@escola.pt',
    password: '123456',
    course: 'Eng. Informática · IADE',
  ),
  User(
    name: 'Lurdes',
    email: 'admin@escola.pt',
    password: 'admin123',
    course: 'Administração',
    isAdmin: true,
  ),
  // Colegas que aparecem na Comunidade (ecrã 09).
  User(
    name: 'Cecília Francisco',
    email: 'cecilia@escola.pt',
    password: '123456',
    course: 'Química · IADE',
  ),
  User(
    name: 'Tiago Reis',
    email: 'tiago@escola.pt',
    password: '123456',
    course: 'Eng. Informática · IADE',
  ),
  User(
    name: 'estudante_10',
    email: 'estudante10@escola.pt',
    password: '123456',
    course: 'Eng. Informática · IADE',
  ),
  User(
    name: 'estudante_45',
    email: 'estudante45@escola.pt',
    password: '123456',
    course: 'Física · IADE',
  ),
  User(
    name: 'Inês Martins',
    email: 'ines@escola.pt',
    password: '123456',
    course: 'Eng. Informática · IADE',
  ),
];

/// Quem cada utilizador segue (email → emails). Ser "amigo" = seguir.
Map<String, Set<String>> sampleFollowing = {
  'rodrigo@escola.pt': {'cecilia@escola.pt', 'tiago@escola.pt'},
  'cecilia@escola.pt': {'rodrigo@escola.pt'},
  'tiago@escola.pt': {'rodrigo@escola.pt', 'ines@escola.pt'},
};

/// Desafio da semana (ecrã 09).
String sampleChallenge = 'Explica um conceito em 60 segundos de vídeo';

/// Disciplinas que se podem escolher num registo.
const List<String> sampleSubjects = [
  'Matemática Discreta',
  'Bases de Dados',
  'Prog. Móvel',
  'Redes',
];


/// Locais do mapa (ecrã 07), nas posições dos marcadores do Figma.
const List<MapPlace> samplePlaces = [
  MapPlace(name: 'Biblioteca IADE', address: 'Av. Dom Carlos I, Lisboa', x: 150, y: 230),
  MapPlace(name: 'Jardim da Estrela', address: 'Praça da Estrela, Lisboa', x: 320, y: 170),
  MapPlace(name: 'Café do campus', address: 'Av. Dom Carlos I, Lisboa', x: 280, y: 300),
  MapPlace(name: 'Casa', address: 'Rua de São Bento, Lisboa', x: 90, y: 380),
  MapPlace(name: 'Laboratório de Química', address: 'Campus IADE, Lisboa', x: 230, y: 450),
];

/// Data de há [days] dias, à hora indicada.
/// Assim os exemplos aparecem sempre como "Hoje" e "Ontem", como no Figma.
DateTime _daysAgo(int days, int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - days, hour, minute);
}

const String _rodrigo = 'rodrigo@escola.pt';

/// Projetos do Rodrigo (ecrã 05). É uma lista que pode crescer ("+ Novo").
List<Project> sampleProjects = [
  Project(
    ownerEmail: _rodrigo,
    name: 'Matemática Discreta',
    description: 'Exercícios e resumos de Matemática Discreta.',
    createdAt: _daysAgo(40, 9, 0),
    colorIndex: 0,
  ),
  Project(
    ownerEmail: _rodrigo,
    name: 'App MyDay',
    description: 'Registo do desenvolvimento da aplicação para '
        'Programação Móvel e Bases de Dados.',
    createdAt: _daysAgo(23, 9, 0),
    visibility: EntryVisibility.public,
    colorIndex: 1,
  ),
  Project(
    ownerEmail: _rodrigo,
    name: 'Redes',
    description: 'Apontamentos e laboratórios de Redes.',
    createdAt: _daysAgo(30, 9, 0),
    visibility: EntryVisibility.friends,
    colorIndex: 2,
  ),
  Project(
    ownerEmail: _rodrigo,
    name: 'Bases de Dados',
    description: 'Modelação e SQL.',
    createdAt: _daysAgo(35, 9, 0),
    visibility: EntryVisibility.friends,
    colorIndex: 3,
  ),
];

/// Grupos de estudo (ecrã 05).
const List<StudyGroup> sampleGroups = [
  StudyGroup(
    name: 'Grupo BD 2026',
    memberNames: ['Tiago Reis', 'Inês Martins', 'Rodrigo Rodrigues', 'Cecília Francisco', 'Ana Lopes'],
    sharedEntries: 12,
  ),
];

/// Registos do Rodrigo: um por dia nos últimos 12 dias (os "12 dias seguidos").
List<Entry> sampleEntries = [
  Entry(
    authorEmail: _rodrigo,
    subject: 'Matemática Discreta',
    title: 'Gauss Seidel: iterações',
    text: 'Finalmente percebi como aplicar o método para resolver sistemas de '
        'equações lineares . O exercício 4 da ficha ajudou muito.',
    date: _daysAgo(0, 10, 42),
    project: 'Matemática Discreta',
    tags: ['iterações', 'cálculo'],
    locationName: 'Biblioteca IADE',
    locationAddress: 'Av. Dom Carlos I, Lisboa',
    photoCount: 1,
    comments: [
      Comment(
        authorName: 'Cristiano Zanzala',
        text: 'O exercício 4 também me salvou. Tens a ficha?',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Bases de Dados',
    title: 'Diagrama ER',
    project: 'Bases de Dados',
    text: 'Hoje aprendi a desenhar a planta de uma BD.',
    date: _daysAgo(0, 9, 15),
    visibility: EntryVisibility.friends,
    audioDuration: '1:24',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Prog. Móvel',
    title: 'Primeiro ecrã em Flutter',
    project: 'App MyDay',
    text: 'Montei o ecrã de entrada da app com widgets do Flutter.',
    date: _daysAgo(1, 18, 30),
    locationName: 'Casa',
    locationAddress: 'Rua de São Bento, Lisboa',
    visibility: EntryVisibility.public,
    videoDuration: '0:42',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Redes',
    title: 'Camadas do modelo OSI',
    project: 'Redes',
    text: 'Fiz um resumo das sete camadas com exemplos de protocolos.',
    date: _daysAgo(2, 16, 5),
    locationName: 'Casa',
    locationAddress: 'Rua de São Bento, Lisboa',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Bases de Dados',
    title: 'Contrato da API definido',
    photoCount: 2,
    project: 'App MyDay',
    text: 'Definimos em grupo os pedidos e respostas entre a app e o servidor.',
    date: _daysAgo(3, 14, 20),
    locationName: 'Café do campus',
    locationAddress: 'Av. Dom Carlos I, Lisboa',
    visibility: EntryVisibility.public,
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Matemática Discreta',
    title: 'Método de Jacobi',
    project: 'Matemática Discreta',
    text: 'Comparei o método de Jacobi com o de Gauss Seidel.',
    date: _daysAgo(4, 11, 0),
    locationName: 'Biblioteca IADE',
    locationAddress: 'Av. Dom Carlos I, Lisboa',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Redes',
    title: 'Endereçamento IP',
    project: 'Redes',
    text: 'Treinei subredes e máscaras com os exercícios da aula.',
    date: _daysAgo(5, 17, 45),
    locationName: 'Casa',
    locationAddress: 'Rua de São Bento, Lisboa',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Prog. Móvel',
    title: 'Navegação entre ecrãs',
    project: 'App MyDay',
    text: 'Aprendi a usar o Navigator para mudar de ecrã.',
    date: _daysAgo(6, 15, 10),
    locationName: 'Casa',
    locationAddress: 'Rua de São Bento, Lisboa',
    visibility: EntryVisibility.friends,
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Bases de Dados',
    title: 'Modelo de dados – versão 1',
    project: 'App MyDay',
    text: 'Primeira versão das tabelas do projeto MyDay.',
    date: _daysAgo(7, 10, 30),
    locationName: 'Laboratório de Química',
    locationAddress: 'Campus IADE, Lisboa',
    visibility: EntryVisibility.public,
    photoCount: 1,
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Matemática Discreta',
    title: 'Relações de equivalência',
    project: 'Matemática Discreta',
    text: 'Percebi as propriedades reflexiva, simétrica e transitiva.',
    date: _daysAgo(8, 9, 50),
    locationName: 'Biblioteca IADE',
    locationAddress: 'Av. Dom Carlos I, Lisboa',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Redes',
    title: 'Wireshark',
    project: 'Redes',
    text: 'Capturei pacotes e identifiquei um pedido HTTP.',
    date: _daysAgo(9, 18, 15),
    locationName: 'Casa',
    locationAddress: 'Rua de São Bento, Lisboa',
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Prog. Móvel',
    title: 'Wireframes no Figma',
    photoCount: 4,
    project: 'App MyDay',
    text: 'Desenhámos os primeiros ecrãs da aplicação.',
    date: _daysAgo(10, 14, 0),
    locationName: 'Jardim da Estrela',
    locationAddress: 'Praça da Estrela, Lisboa',
    visibility: EntryVisibility.public,
  ),
  Entry(
    authorEmail: _rodrigo,
    subject: 'Bases de Dados',
    title: 'Chaves primárias e estrangeiras',
    project: 'Bases de Dados',
    text: 'Revi como as tabelas se ligam entre si.',
    date: _daysAgo(11, 16, 40),
    locationName: 'Laboratório de Química',
    locationAddress: 'Campus IADE, Lisboa',
  ),

  // ---------- Registos de colegas (aparecem na Comunidade) ----------
  Entry(
    authorEmail: 'cecilia@escola.pt',
    subject: 'Química – laboratório',
    title: 'Titulação Ácido-Base',
    text: 'Registei a mudança de cor no ponto de equivalência.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    visibility: EntryVisibility.friends,
    photoCount: 1,
    comments: _sampleComments(4),
  ),
  Entry(
    authorEmail: 'tiago@escola.pt',
    subject: 'Algoritmos',
    title: 'Listas Ligadas',
    text: 'Fiz o exemplo das aulas passo a passo no caderno.',
    date: DateTime.now().subtract(const Duration(hours: 5)),
    visibility: EntryVisibility.public,
    photoCount: 1,
    comments: [..._sampleComments(6), _offensiveComment],
  ),
  Entry(
    authorEmail: 'ines@escola.pt',
    subject: 'Prog. Móvel',
    title: 'Estado com setState',
    text: 'Percebi finalmente quando o Flutter redesenha um widget.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    visibility: EntryVisibility.public,
    comments: _sampleComments(2),
  ),
  _copiedEntry,
];

/// Comentário denunciado (ecrã 11).
final Comment _offensiveComment = Comment(
  authorName: 'estudante_10',
  text: 'Que trabalho tão mau, mais valia desistires.',
  date: DateTime.now().subtract(const Duration(hours: 3)),
);

/// Registo denunciado (ecrã 11).
final Entry _copiedEntry = Entry(
  authorEmail: 'estudante45@escola.pt',
  subject: 'Física',
  title: 'Resumo de Física – exame',
  text: 'Resumo completo para o exame de Física.',
  date: DateTime.now().subtract(const Duration(hours: 6)),
  visibility: EntryVisibility.public,
  photoCount: 1,
);

/// Denúncias por tratar (ecrã 11 · Administração).
List<Report> sampleReports = [
  Report(entry: _copiedEntry, reason: 'Conteúdo copiado', count: 2),
  Report(
    entry: sampleEntries.firstWhere((entry) => entry.title == 'Listas Ligadas'),
    comment: _offensiveComment,
    reason: 'Linguagem ofensiva',
  ),
];

/// Registo de ações dos administradores (ecrã 11).
List<AdminAction> sampleAdminActions = [
  AdminAction(adminName: 'lurdes.admin', description: 'publicou um desafio', date: _daysAgo(0, 11, 20)),
  AdminAction(
      adminName: 'lurdes.admin', description: 'aprovou a tag #listasligadas', date: _daysAgo(0, 10, 2)),
];

/// Cria [count] comentários de exemplo (só para os contadores da Comunidade).
List<Comment> _sampleComments(int count) {
  const authors = ['Ana Lopes', 'Inês Martins', 'Tiago Reis', 'Rodrigo Rodrigues'];
  return [
    for (int i = 0; i < count; i++)
      Comment(
        authorName: authors[i % authors.length],
        text: 'Muito útil, obrigado por partilhares!',
        date: DateTime.now().subtract(Duration(minutes: 30 + i * 10)),
      ),
  ];
}
