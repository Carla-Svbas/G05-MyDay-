const express = require('express');
const bd = require('../bd');
const { obrigatorio, opcional } = require('../autenticacao');
const { COLUNAS_REGISTO, PODE_VER, paramsPodeVer, arrumar } = require('../visibilidade');

const rotas = express.Router();
const VISIBILIDADES = ['privado', 'amigos', 'publico'];

const COLUNAS_PROJETO = `
  p.id, p.titulo, p.descricao, p.visibilidade, p.criado_em as criadoEm,
  p.utilizador_id as autorId, u.nome as autor, d.id as disciplinaId, d.nome as disciplina,
  (select count(*) from registo r where r.projeto_id = p.id) as registos,
  (select max(r.data_registo) from registo r where r.projeto_id = p.id) as ultimoRegisto`;

// Os meus projetos (filtro opcional por visibilidade)
rotas.get('/', obrigatorio, async (req, res) => {
  const valores = [req.utilizador.id];
  let filtro = '';
  if (VISIBILIDADES.includes(req.query.visibilidade)) {
    filtro = 'and p.visibilidade = ?';
    valores.push(req.query.visibilidade);
  }
  const [linhas] = await bd.query(
    `select ${COLUNAS_PROJETO} from projeto p
     join utilizador u on u.id = p.utilizador_id
     left join disciplina d on d.id = p.disciplina_id
     where p.utilizador_id = ? ${filtro}
     order by coalesce((select max(r.data_registo) from registo r where r.projeto_id = p.id), p.criado_em) desc`,
    valores,
  );
  res.json(linhas);
});

// Detalhe do projeto com a linha temporal dos registos que o utilizador pode ver
rotas.get('/:id', opcional, async (req, res) => {
  const [linhas] = await bd.query(
    `select ${COLUNAS_PROJETO} from projeto p
     join utilizador u on u.id = p.utilizador_id
     left join disciplina d on d.id = p.disciplina_id
     where p.id = ?`, [req.params.id]);
  const projeto = linhas[0];
  const eu = req.utilizador ? req.utilizador.id : 0;
  if (!projeto || (projeto.autorId !== eu && projeto.visibilidade === 'privado')) {
    return res.status(404).json({ erro: 'Projeto não encontrado.' });
  }
  const [registos] = await bd.query(
    `select ${COLUNAS_REGISTO} from v_registo v where v.projeto_id = ? and ${PODE_VER} order by v.data_registo desc`,
    [projeto.id, ...paramsPodeVer(req.utilizador)],
  );
  const [comentarios] = await bd.query(
    `select c.id, c.texto, c.criado_em as criadoEm, u.nome as autor
     from comentario c join utilizador u on u.id = c.utilizador_id
     where c.projeto_id = ? order by c.criado_em`, [projeto.id]);
  res.json({ ...projeto, linhaTemporal: registos.map(arrumar), comentarios });
});

// Criar projeto
rotas.post('/', obrigatorio, async (req, res) => {
  const titulo = String(req.body.titulo || '').trim();
  if (!titulo) return res.status(400).json({ erro: 'Escreve o nome do projeto.' });
  const visibilidade = req.body.visibilidade || 'privado';
  if (!VISIBILIDADES.includes(visibilidade)) return res.status(400).json({ erro: 'Visibilidade inválida.' });

  const [repetido] = await bd.query('select id from projeto where utilizador_id = ? and titulo = ?', [req.utilizador.id, titulo]);
  if (repetido.length) return res.status(409).json({ erro: 'Já tens um projeto com esse nome.' });

  const [resultado] = await bd.query(
    'insert into projeto (utilizador_id, disciplina_id, titulo, descricao, visibilidade) values (?, ?, ?, ?, ?)',
    [req.utilizador.id, req.body.disciplinaId || null, titulo, req.body.descricao || null, visibilidade],
  );
  await bd.query(
    `insert ignore into utilizador_conquista (utilizador_id, conquista_id)
     select ?, id from conquista where codigo = 'primeiro_projeto'`, [req.utilizador.id]);
  const [novo] = await bd.query(
    `select ${COLUNAS_PROJETO} from projeto p join utilizador u on u.id = p.utilizador_id
     left join disciplina d on d.id = p.disciplina_id where p.id = ?`, [resultado.insertId]);
  res.status(201).json(novo[0]);
});

// Editar nome, descrição ou visibilidade
rotas.patch('/:id', obrigatorio, async (req, res) => {
  const campos = [];
  const valores = [];
  if (req.body.titulo !== undefined) {
    const titulo = String(req.body.titulo).trim();
    if (!titulo) return res.status(400).json({ erro: 'O nome não pode ficar vazio.' });
    campos.push('titulo = ?'); valores.push(titulo);
  }
  if (req.body.descricao !== undefined) { campos.push('descricao = ?'); valores.push(req.body.descricao); }
  if (req.body.visibilidade !== undefined) {
    if (!VISIBILIDADES.includes(req.body.visibilidade)) return res.status(400).json({ erro: 'Visibilidade inválida.' });
    campos.push('visibilidade = ?'); valores.push(req.body.visibilidade);
  }
  if (!campos.length) return res.status(400).json({ erro: 'Nada para alterar.' });
  const [resultado] = await bd.query(
    `update projeto set ${campos.join(', ')} where id = ? and utilizador_id = ?`, [...valores, req.params.id, req.utilizador.id]);
  if (resultado.affectedRows === 0) return res.status(404).json({ erro: 'Projeto não encontrado.' });
  res.json({ ok: true });
});

module.exports = rotas;
