const express = require('express');
const bd = require('../bd');
const { obrigatorio, opcional } = require('../autenticacao');
const { COLUNAS_REGISTO, PODE_VER, paramsPodeVer, arrumar } = require('../visibilidade');

const rotas = express.Router();

// Feed: "a-seguir" (de quem sigo) ou "descobrir" (tudo o que posso ver), com pesquisa
rotas.get('/feed', opcional, async (req, res) => {
  const eu = req.utilizador ? req.utilizador.id : 0;
  const filtros = [PODE_VER, 'v.utilizador_id <> ?'];
  const valores = [...paramsPodeVer(req.utilizador), eu];
  if (req.query.separador === 'a-seguir') {
    filtros.push('exists (select 1 from seguimento s where s.seguidor_id = ? and s.seguido_id = v.utilizador_id)');
    valores.push(eu);
  }
  if (req.query.pesquisa) {
    filtros.push('(v.titulo like ? or v.texto like ? or v.autor like ? or v.disciplina like ?)');
    const termo = `%${req.query.pesquisa}%`;
    valores.push(termo, termo, termo, termo);
  }
  const [linhas] = await bd.query(
    `select ${COLUNAS_REGISTO} from v_registo v where ${filtros.join(' and ')} order by v.data_registo desc limit 50`,
    valores,
  );
  res.json(linhas.map(arrumar));
});

// Quem eu sigo e quem me segue
rotas.get('/seguimentos', obrigatorio, async (req, res) => {
  const [aSeguir] = await bd.query(
    `select u.id, u.nome from seguimento s join utilizador u on u.id = s.seguido_id where s.seguidor_id = ?`,
    [req.utilizador.id]);
  const [seguidores] = await bd.query(
    `select u.id, u.nome from seguimento s join utilizador u on u.id = s.seguidor_id where s.seguido_id = ?`,
    [req.utilizador.id]);
  res.json({ aSeguir, seguidores });
});

// Seguir ou deixar de seguir alguém
rotas.post('/seguir/:id', obrigatorio, async (req, res) => {
  const outro = Number(req.params.id);
  if (outro === req.utilizador.id) return res.status(400).json({ erro: 'Não te podes seguir a ti próprio.' });
  const [apagado] = await bd.query('delete from seguimento where seguidor_id = ? and seguido_id = ?', [req.utilizador.id, outro]);
  if (apagado.affectedRows === 0) {
    await bd.query('insert into seguimento (seguidor_id, seguido_id) values (?, ?)', [req.utilizador.id, outro]);
  }
  res.json({ aSeguir: apagado.affectedRows === 0 });
});

// Desafio da semana em curso
rotas.get('/desafio', async (req, res) => {
  const [linhas] = await bd.query(
    `select id, titulo, descricao, data_inicio as dataInicio, data_fim as dataFim
     from desafio where curdate() between data_inicio and data_fim order by data_inicio desc limit 1`);
  res.json(linhas[0] || null);
});

// Grupos de estudo de que faço parte
rotas.get('/grupos', obrigatorio, async (req, res) => {
  const [linhas] = await bd.query(
    `select g.id, g.nome, g.descricao, gm.papel,
       (select count(*) from grupo_membro x where x.grupo_id = g.id) as membros,
       (select count(*) from grupo_registo x where x.grupo_id = g.id) as registos
     from grupo g join grupo_membro gm on gm.grupo_id = g.id and gm.utilizador_id = ?
     order by g.nome`, [req.utilizador.id]);
  res.json(linhas);
});

module.exports = rotas;
