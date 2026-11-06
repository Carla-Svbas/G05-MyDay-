import '../models/comentario.dart';
import '../models/registo.dart';

const disciplinasDemo = [
  'Matemática Discreta',
  'Bases de Dados',
  'Prog. Móvel',
  'Redes',
];

DateTime diasAtras(int dias, int hora, int minuto) {
  final hoje = DateTime.now();
  return DateTime(hoje.year, hoje.month, hoje.day - dias, hora, minuto);
}

DateTime horasAtras(int horas) {
  return DateTime.now().subtract(Duration(hours: horas));
}

List<Comentario> comentariosDemo(int quantidade) {
  final autores = ['Ana Lopes', 'Inês Martins', 'Tiago Reis', 'Rodrigo Rodrigues'];
  final lista = <Comentario>[];
  for (var i = 0; i < quantidade; i++) {
    lista.add(Comentario(
      id: 1000 + i,
      autor: autores[i % autores.length],
      texto: 'Muito útil, obrigado por partilhares!',
      data: DateTime.now().subtract(Duration(minutes: 30 + i * 10)),
    ));
  }
  return lista;
}

final registosDemo = [
  Registo(
    id: 1,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Matemática Discreta',
    titulo: 'Gauss Seidel: iterações',
    texto: 'Finalmente percebi como aplicar o método para resolver sistemas de '
        'equações lineares . O exercício 4 da ficha ajudou muito.',
    data: diasAtras(0, 10, 42),
    projeto: 'Matemática Discreta',
    tags: ['iterações', 'cálculo'],
    local: 'Biblioteca IADE',
    morada: 'Av. Dom Carlos I, Lisboa',
    fotos: 1,
    comentarios: [
      Comentario(
        id: 1,
        autor: 'Cristiano Zanzala',
        texto: 'O exercício 4 também me salvou. Tens a ficha?',
        data: horasAtras(1),
      ),
    ],
  ),
  Registo(
    id: 2,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Bases de Dados',
    titulo: 'Diagrama ER',
    texto: 'Hoje aprendi a desenhar a planta de uma BD.',
    data: diasAtras(0, 9, 15),
    visibilidade: Visibilidade.amigos,
    projeto: 'Bases de Dados',
    audio: '1:24',
  ),
  Registo(
    id: 3,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Prog. Móvel',
    titulo: 'Primeiro ecrã em Flutter',
    texto: 'Montei o ecrã de entrada da app com widgets do Flutter.',
    data: diasAtras(1, 18, 30),
    visibilidade: Visibilidade.publico,
    projeto: 'App MyDay',
    local: 'Casa',
    morada: 'Rua de São Bento, Lisboa',
    video: '0:42',
  ),
  Registo(
    id: 4,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Redes',
    titulo: 'Camadas do modelo OSI',
    texto: 'Fiz um resumo das sete camadas com exemplos de protocolos.',
    data: diasAtras(2, 16, 5),
    projeto: 'Redes',
    local: 'Casa',
    morada: 'Rua de São Bento, Lisboa',
  ),
  Registo(
    id: 5,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Bases de Dados',
    titulo: 'Contrato da API definido',
    texto: 'Definimos em grupo os pedidos e respostas entre a app e o servidor.',
    data: diasAtras(3, 14, 20),
    visibilidade: Visibilidade.publico,
    projeto: 'App MyDay',
    local: 'Café do campus',
    morada: 'Av. Dom Carlos I, Lisboa',
    fotos: 2,
  ),
  Registo(
    id: 6,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Matemática Discreta',
    titulo: 'Método de Jacobi',
    texto: 'Comparei o método de Jacobi com o de Gauss Seidel.',
    data: diasAtras(4, 11, 0),
    projeto: 'Matemática Discreta',
    local: 'Biblioteca IADE',
    morada: 'Av. Dom Carlos I, Lisboa',
  ),
  Registo(
    id: 7,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Redes',
    titulo: 'Endereçamento IP',
    texto: 'Treinei subredes e máscaras com os exercícios da aula.',
    data: diasAtras(5, 17, 45),
    projeto: 'Redes',
    local: 'Casa',
    morada: 'Rua de São Bento, Lisboa',
  ),
  Registo(
    id: 8,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Prog. Móvel',
    titulo: 'Navegação entre ecrãs',
    texto: 'Aprendi a usar o Navigator para mudar de ecrã.',
    data: diasAtras(6, 15, 10),
    visibilidade: Visibilidade.amigos,
    projeto: 'App MyDay',
    local: 'Casa',
    morada: 'Rua de São Bento, Lisboa',
  ),
  Registo(
    id: 9,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Bases de Dados',
    titulo: 'Modelo de dados – versão 1',
    texto: 'Primeira versão das tabelas do projeto MyDay.',
    data: diasAtras(7, 10, 30),
    visibilidade: Visibilidade.publico,
    projeto: 'App MyDay',
    local: 'Laboratório de Química',
    morada: 'Campus IADE, Lisboa',
    fotos: 1,
  ),
  Registo(
    id: 10,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Matemática Discreta',
    titulo: 'Relações de equivalência',
    texto: 'Percebi as propriedades reflexiva, simétrica e transitiva.',
    data: diasAtras(8, 9, 50),
    projeto: 'Matemática Discreta',
    local: 'Biblioteca IADE',
    morada: 'Av. Dom Carlos I, Lisboa',
  ),
  Registo(
    id: 11,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Redes',
    titulo: 'Wireshark',
    texto: 'Capturei pacotes e identifiquei um pedido HTTP.',
    data: diasAtras(9, 18, 15),
    projeto: 'Redes',
    local: 'Casa',
    morada: 'Rua de São Bento, Lisboa',
  ),
  Registo(
    id: 12,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Prog. Móvel',
    titulo: 'Wireframes no Figma',
    texto: 'Desenhámos os primeiros ecrãs da aplicação.',
    data: diasAtras(10, 14, 0),
    visibilidade: Visibilidade.publico,
    projeto: 'App MyDay',
    local: 'Jardim da Estrela',
    morada: 'Praça da Estrela, Lisboa',
    fotos: 4,
  ),
  Registo(
    id: 13,
    autorEmail: 'rodrigo@escola.pt',
    disciplina: 'Bases de Dados',
    titulo: 'Chaves primárias e estrangeiras',
    texto: 'Revi como as tabelas se ligam entre si.',
    data: diasAtras(11, 16, 40),
    projeto: 'Bases de Dados',
    local: 'Laboratório de Química',
    morada: 'Campus IADE, Lisboa',
  ),
  Registo(
    id: 14,
    autorEmail: 'cecilia@escola.pt',
    disciplina: 'Química – laboratório',
    titulo: 'Titulação Ácido-Base',
    texto: 'Registei a mudança de cor no ponto de equivalência.',
    data: horasAtras(2),
    visibilidade: Visibilidade.amigos,
    fotos: 1,
    comentarios: comentariosDemo(4),
  ),
  Registo(
    id: 15,
    autorEmail: 'tiago@escola.pt',
    disciplina: 'Algoritmos',
    titulo: 'Listas Ligadas',
    texto: 'Fiz o exemplo das aulas passo a passo no caderno.',
    data: horasAtras(5),
    visibilidade: Visibilidade.publico,
    fotos: 1,
    comentarios: [
      ...comentariosDemo(6),
      Comentario(
        id: 99,
        autor: 'estudante_10',
        texto: 'Que trabalho tão mau, mais valia desistires.',
        data: horasAtras(3),
      ),
    ],
  ),
  Registo(
    id: 16,
    autorEmail: 'ines@escola.pt',
    disciplina: 'Prog. Móvel',
    titulo: 'Estado com setState',
    texto: 'Percebi finalmente quando o Flutter redesenha um widget.',
    data: horasAtras(24),
    visibilidade: Visibilidade.publico,
    comentarios: comentariosDemo(2),
  ),
  Registo(
    id: 17,
    autorEmail: 'estudante45@escola.pt',
    disciplina: 'Física',
    titulo: 'Resumo de Física – exame',
    texto: 'Resumo completo para o exame de Física.',
    data: horasAtras(6),
    visibilidade: Visibilidade.publico,
    fotos: 1,
  ),
];
