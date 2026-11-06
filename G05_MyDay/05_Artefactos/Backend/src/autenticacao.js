const jwt = require('jsonwebtoken');

const SEGREDO = process.env.JWT_SEGREDO || 'segredo-de-desenvolvimento';

function criarToken(utilizador) {
  return jwt.sign({ id: utilizador.id, papel: utilizador.papel }, SEGREDO, { expiresIn: '7d' });
}

function lerToken(req) {
  const cabecalho = req.headers.authorization || '';
  if (!cabecalho.startsWith('Bearer ')) return null;
  try {
    return jwt.verify(cabecalho.slice(7), SEGREDO);
  } catch {
    return null;
  }
}

function opcional(req, res, next) {
  req.utilizador = lerToken(req);
  next();
}

function obrigatorio(req, res, next) {
  req.utilizador = lerToken(req);
  if (!req.utilizador) return res.status(401).json({ erro: 'Tens de entrar na tua conta.' });
  next();
}

function soAdmin(req, res, next) {
  req.utilizador = lerToken(req);
  if (!req.utilizador) return res.status(401).json({ erro: 'Tens de entrar na tua conta.' });
  if (req.utilizador.papel !== 'administrador') return res.status(403).json({ erro: 'Só para administradores.' });
  next();
}

module.exports = { criarToken, opcional, obrigatorio, soAdmin };
