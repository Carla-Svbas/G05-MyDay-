const express = require('express');
const bd = require('../bd');
const { obrigatorio } = require('../autenticacao');

const rotas = express.Router();

// Perfil: dados, estatísticas (view), dias seguidos (função) e conquistas
rotas.get('/:id', obrigatorio, async (req, res) => {
  const id = req.params.id === 'eu' ? req.utilizador.id : Number(req.params.id);
  const [linhas] = await bd.query(
    `select u.id, u.nome, u.nome_utilizador as nomeUtilizador, u.bio, u.instituicao, u.curso, u.papel,
       e.registos, e.projetos, e.seguidores, e.a_seguir as aSeguir, fn_dias_seguidos(u.id) as diasSeguidos,
       exists (select 1 from seguimento s where s.seguidor_id = ? and s.seguido_id = u.id) as euSigo
     from utilizador u join v_estatisticas_utilizador e on e.id = u.id
     where u.id = ?`, [req.utilizador.id, id]);
  if (!linhas.length) return res.status(404).json({ erro: 'Utilizador não encontrado.' });

  const [conquistas] = await bd.query(
    `select c.codigo, c.nome, c.descricao, uc.obtida_em as obtidaEm
     from conquista c left join utilizador_conquista uc on uc.conquista_id = c.id and uc.utilizador_id = ?
     order by c.id`, [id]);
  res.json({ ...linhas[0], euSigo: Boolean(linhas[0].euSigo), conquistas: conquistas.map((c) => ({ ...c, desbloqueada: c.obtidaEm !== null })) });
});

// Definições de privacidade (consentimentos)
rotas.patch('/eu/consentimentos', obrigatorio, async (req, res) => {
  await bd.query(
    `update utilizador set consent_localizacao = ?, consent_audio = ?, consent_data = now() where id = ?`,
    [Boolean(req.body.localizacao), Boolean(req.body.audio), req.utilizador.id]);
  res.json({ ok: true });
});

// Lembretes
rotas.get('/eu/lembretes', obrigatorio, async (req, res) => {
  const [linhas] = await bd.query(
    'select id, titulo, hora, dias_semana as diasSemana, ativo from lembrete where utilizador_id = ? order by hora',
    [req.utilizador.id]);
  res.json(linhas.map((l) => ({ ...l, ativo: Boolean(l.ativo) })));
});

// Apagar a minha conta (stored procedure)
rotas.delete('/eu', obrigatorio, async (req, res) => {
  const [resultado] = await bd.query('call sp_apagar_conta(?)', [req.utilizador.id]);
  if (resultado[0][0].apagados === 0) return res.status(400).json({ erro: 'Esta conta não pode ser apagada aqui.' });
  res.status(204).end();
});

module.exports = rotas;
