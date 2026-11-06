const express = require('express');
const crypto = require('crypto');
const bd = require('../bd');
const { obrigatorio, opcional } = require('../autenticacao');
const { COLUNAS_REGISTO, arrumar, procurarRegisto } = require('../visibilidade');

const rotas = express.Router();
const VISIBILIDADES = ['privado', 'amigos', 'publico'];

// Diário: os meus registos (com filtros opcionais por disciplina, projeto ou texto)
rotas.get('/', obrigatorio, async (req, res) => {
  const filtros = ['v.utilizador_id = ?'];
  const valores = [req.utilizador.id];
  if (req.query.disciplina) { filtros.push('v.disciplina_id = ?'); valores.push(req.query.disciplina); }
  if (req.query.projeto) { filtros.push('v.projeto_id = ?'); valores.push(req.query.projeto); }
  if (req.query.pesquisa) {
    filtros.push('(v.titulo like ? or v.texto like ?)');
    valores.push(`%${req.query.pesquisa}%`, `%${req.query.pesquisa}%`);
  }
  const [linhas] = await bd.query(
    `select ${COLUNAS_REGISTO} from v_registo v where ${filtros.join(' and ')} order by v.data_registo desc`,
    valores,
  );
  res.json(linhas.map(arrumar));
});

// Detalhe de um registo: ficheiros e comentários
rotas.get('/:id', opcional, async (req, res) => {
  const registo = await procurarRegisto(req.params.id, req.utilizador);
  if (!registo) return res.status(404).json({ erro: 'Registo não encontrado.' });

  const [ficheiros] = await bd.query(
    `select id, tipo, caminho, mime_type as mimeType, tamanho_bytes as tamanhoBytes, duracao_seg as duracaoSeg
     from ficheiro where registo_id = ? order by ordem`, [registo.id]);
  const [comentarios] = await bd.query(
    `select c.id, c.texto, c.criado_em as criadoEm, u.id as autorId, u.nome as autor
     from comentario c join utilizador u on u.id = c.utilizador_id
     where c.registo_id = ? order by c.criado_em`, [registo.id]);
  let favorito = false;
  if (req.utilizador) {
    const [f] = await bd.query('select 1 from favorito where utilizador_id = ? and registo_id = ?', [req.utilizador.id, registo.id]);
    favorito = f.length > 0;
  }
  res.json({ ...registo, ficheiros, listaComentarios: comentarios, favorito });
});

// Novo registo
rotas.post('/', obrigatorio, async (req, res) => {
  const titulo = String(req.body.titulo || '').trim();
  if (!titulo) return res.status(400).json({ erro: 'Escreve um título para o registo.' });
  const visibilidade = req.body.visibilidade || null;
  if (visibilidade && !VISIBILIDADES.includes(visibilidade)) return res.status(400).json({ erro: 'Visibilidade inválida.' });

  const projetoId = req.body.projetoId || null;
  if (projetoId) {
    const [p] = await bd.query('select id from projeto where id = ? and utilizador_id = ?', [projetoId, req.utilizador.id]);
    if (p.length === 0) return res.status(400).json({ erro: 'Esse projeto não é teu.' });
  }

  const ligacao = await bd.getConnection();
  try {
    await ligacao.beginTransaction();
    const [resultado] = await ligacao.query(
      `insert into registo (uuid_cliente, utilizador_id, projeto_id, disciplina_id, titulo, texto, visibilidade,
         latitude, longitude, latitude_aprox, longitude_aprox, morada, data_registo)
       values (?, ?, ?, ?, ?, ?, ?, ?, ?, round(?, 2), round(?, 2), ?, ?)`,
      [
        req.body.uuidCliente || crypto.randomUUID(), req.utilizador.id, projetoId, req.body.disciplinaId || null,
        titulo, req.body.texto || null, visibilidade,
        req.body.latitude ?? null, req.body.longitude ?? null, req.body.latitude ?? null, req.body.longitude ?? null,
        req.body.morada || null, req.body.dataRegisto || new Date(),
      ],
    );
    const tags = [...new Set((req.body.tags || []).map((t) => String(t).trim().toLowerCase()).filter(Boolean))];
    for (const nome of tags) {
      await ligacao.query('insert ignore into tag (nome) values (?)', [nome]);
      await ligacao.query(
        'insert into registo_tag (registo_id, tag_id) select ?, id from tag where nome = ?', [resultado.insertId, nome]);
    }
    await ligacao.query(
      `insert ignore into utilizador_conquista (utilizador_id, conquista_id)
       select ?, id from conquista where codigo = 'primeiro_registo'`, [req.utilizador.id]);
    await ligacao.commit();
    res.status(201).json(await procurarRegisto(resultado.insertId, req.utilizador));
  } catch (erro) {
    await ligacao.rollback();
    throw erro;
  } finally {
    ligacao.release();
  }
});

// Apagar um registo meu
rotas.delete('/:id', obrigatorio, async (req, res) => {
  const [resultado] = await bd.query('delete from registo where id = ? and utilizador_id = ?', [req.params.id, req.utilizador.id]);
  if (resultado.affectedRows === 0) return res.status(404).json({ erro: 'Registo não encontrado.' });
  res.status(204).end();
});

// Comentar
rotas.post('/:id/comentarios', obrigatorio, async (req, res) => {
  const texto = String(req.body.texto || '').trim();
  if (!texto) return res.status(400).json({ erro: 'Escreve um comentário.' });
  const registo = await procurarRegisto(req.params.id, req.utilizador);
  if (!registo) return res.status(404).json({ erro: 'Registo não encontrado.' });
  const [resultado] = await bd.query(
    'insert into comentario (utilizador_id, registo_id, texto) values (?, ?, ?)', [req.utilizador.id, registo.id, texto]);
  const [comentario] = await bd.query(
    `select c.id, c.texto, c.criado_em as criadoEm, u.id as autorId, u.nome as autor
     from comentario c join utilizador u on u.id = c.utilizador_id where c.id = ?`, [resultado.insertId]);
  res.status(201).json(comentario[0]);
});

// Favorito: liga e desliga
rotas.post('/:id/favorito', obrigatorio, async (req, res) => {
  const registo = await procurarRegisto(req.params.id, req.utilizador);
  if (!registo) return res.status(404).json({ erro: 'Registo não encontrado.' });
  const [apagado] = await bd.query('delete from favorito where utilizador_id = ? and registo_id = ?', [req.utilizador.id, registo.id]);
  if (apagado.affectedRows === 0) {
    await bd.query('insert into favorito (utilizador_id, registo_id) values (?, ?)', [req.utilizador.id, registo.id]);
  }
  res.json({ favorito: apagado.affectedRows === 0 });
});

// Denunciar
rotas.post('/:id/denuncias', obrigatorio, async (req, res) => {
  const motivo = String(req.body.motivo || '').trim();
  if (!motivo) return res.status(400).json({ erro: 'Escolhe o motivo da denúncia.' });
  const registo = await procurarRegisto(req.params.id, req.utilizador);
  if (!registo) return res.status(404).json({ erro: 'Registo não encontrado.' });
  const [resultado] = await bd.query(
    'insert into denuncia (denunciante_id, registo_id, motivo) values (?, ?, ?)', [req.utilizador.id, registo.id, motivo]);
  res.status(201).json({ id: resultado.insertId, estado: 'pendente' });
});

module.exports = rotas;
