import '../models/grupo_estudo.dart';
import '../models/projeto.dart';
import '../models/registo.dart';
import 'registos_demo.dart';

final projetosDemo = [
  Projeto(
    id: 1,
    donoEmail: 'rodrigo@escola.pt',
    nome: 'Matemática Discreta',
    descricao: 'Exercícios e resumos de Matemática Discreta.',
    criadoEm: diasAtras(40, 9, 0),
    cor: 0,
  ),
  Projeto(
    id: 2,
    donoEmail: 'rodrigo@escola.pt',
    nome: 'App MyDay',
    descricao: 'Registo do desenvolvimento da aplicação para '
        'Programação Móvel e Bases de Dados.',
    criadoEm: diasAtras(23, 9, 0),
    visibilidade: Visibilidade.publico,
    cor: 1,
  ),
  Projeto(
    id: 3,
    donoEmail: 'rodrigo@escola.pt',
    nome: 'Redes',
    descricao: 'Apontamentos e laboratórios de Redes.',
    criadoEm: diasAtras(30, 9, 0),
    visibilidade: Visibilidade.amigos,
    cor: 2,
  ),
  Projeto(
    id: 4,
    donoEmail: 'rodrigo@escola.pt',
    nome: 'Bases de Dados',
    descricao: 'Modelação e SQL.',
    criadoEm: diasAtras(35, 9, 0),
    visibilidade: Visibilidade.amigos,
    cor: 3,
  ),
];

const gruposDemo = [
  GrupoEstudo(
    nome: 'Grupo BD 2026',
    membros: ['Tiago Reis', 'Inês Martins', 'Rodrigo Rodrigues', 'Cecília Francisco', 'Ana Lopes'],
    registosPartilhados: 12,
  ),
];
