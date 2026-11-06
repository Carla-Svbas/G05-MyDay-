const express = require('express');
const bcrypt = require('bcryptjs');
const bd = require('../bd');
const { criarToken, obrigatorio } = require('../autenticacao');

const rotas = express.Router();

const CAMPOS = `id, email, nome_utilizador as nomeUtilizador, nome, bio, instituicao, curso, papel,
  consent_localizacao as consentLocalizacao, consent_audio as consentAudio, criado_em as criadoEm`;

rotas.post('/login', async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');
  if (!email || !password) return res.status(400).json({ erro: 'Escreve o email e a palavra-passe.' });

  const [linhas] = await bd.query('select password_hash, id from utilizador where email = ?', [email]);
  if (linhas.length === 0) {
    return res.status(404).json({ erro: 'Não existe nenhuma conta com este email. Cria uma conta.', semConta: true });
  }
  const certa = await bcrypt.compare(password, linhas[0].password_hash);
  if (!certa) return res.status(401).json({ erro: 'Palavra-passe incorreta.' });

  const [utilizador] = await bd.query(`select ${CAMPOS} from utilizador where id = ?`, [linhas[0].id]);
  res.json({ token: criarToken(utilizador[0]), utilizador: utilizador[0] });
});

rotas.post('/registar', async (req, res) => {
  const nome = String(req.body.nome || '').trim();
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');
  const curso = String(req.body.curso || '').trim() || null;

  if (!nome) return res.status(400).json({ erro: 'Escreve o teu nome.' });
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return res.status(400).json({ erro: 'Escreve um email válido.' });
  if (password.length < 6) return res.status(400).json({ erro: 'A palavra-passe tem de ter pelo menos 6 caracteres.' });

  const [existe] = await bd.query('select id from utilizador where email = ?', [email]);
  if (existe.length > 0) return res.status(409).json({ erro: 'Já existe uma conta com este email.' });

  const base = email.split('@')[0].replace(/[^a-z0-9._]/g, '').slice(0, 40) || 'estudante';
  const nomeUtilizador = `${base}${Math.floor(Math.random() * 9000 + 1000)}`;
  const hash = await bcrypt.hash(password, 10);
  const [resultado] = await bd.query(
    'insert into utilizador (email, password_hash, nome_utilizador, nome, curso) values (?, ?, ?, ?, ?)',
    [email, hash, nomeUtilizador, nome, curso],
  );
  const [utilizador] = await bd.query(`select ${CAMPOS} from utilizador where id = ?`, [resultado.insertId]);
  res.status(201).json({ token: criarToken(utilizador[0]), utilizador: utilizador[0] });
});

rotas.get('/eu', obrigatorio, async (req, res) => {
  const [utilizador] = await bd.query(`select ${CAMPOS} from utilizador where id = ?`, [req.utilizador.id]);
  if (utilizador.length === 0) return res.status(404).json({ erro: 'A conta já não existe.' });
  res.json(utilizador[0]);
});

module.exports = rotas;
