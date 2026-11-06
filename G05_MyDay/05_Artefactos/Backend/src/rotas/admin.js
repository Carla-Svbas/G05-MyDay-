const express = require('express');
const bd = require('../bd');
const { soAdmin } = require('../autenticacao');

const rotas = express.Router();
rotas.use(soAdmin);

// Fila de moderação (view)
rotas.get('/denuncias', async (req, res) => {
  const [linhas] = await bd.query('select * from v_denuncias_pendentes order by criado_em');
  res.json(linhas);
});

// Aceitar (oculta o registo) ou rejeitar uma denúncia (stored procedure)
rotas.patch('/denuncias/:id', async (req, res) => {
  const estado = req.body.estado;
  if (!['aceite', 'rejeitada'].includes(estado)) return res.status(400).json({ erro: 'Estado inválido: aceite ou rejeitada.' });
  const [existe] = await bd.query("select id from denuncia where id = ? and estado = 'pendente'", [req.params.id]);
  if (!existe.length) return res.status(404).json({ erro: 'Denúncia não encontrada ou já tratada.' });
  await bd.query('call sp_tratar_denuncia(?, ?, ?)', [req.params.id, req.utilizador.id, estado]);
  res.json({ ok: true, estado });
});

// Registo de ações
rotas.get('/acoes', async (req, res) => {
  const [linhas] = await bd.query(
    `select a.id, a.acao, a.entidade_tipo as entidadeTipo, a.entidade_id as entidadeId, a.detalhes,
       a.criado_em as criadoEm, u.nome as administrador
     from registo_acoes a join utilizador u on u.id = a.admin_id
     order by a.criado_em desc limit 50`);
  res.json(linhas);
});

// Estatísticas gerais
rotas.get('/estatisticas', async (req, res) => {
  const [linhas] = await bd.query(
    `select
       (select count(*) from utilizador where papel = 'estudante') as estudantes,
       (select count(*) from registo) as registos,
       (select count(*) from registo where date(data_registo) = curdate()) as registosHoje,
       (select count(*) from projeto) as projetos,
       (select count(*) from denuncia where estado = 'pendente') as denunciasPendentes`);
  res.json(linhas[0]);
});

module.exports = rotas;
