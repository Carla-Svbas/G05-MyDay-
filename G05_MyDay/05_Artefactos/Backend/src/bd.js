const mysql = require('mysql2/promise');

const bd = mysql.createPool({
  host: process.env.BD_HOST || 'localhost',
  port: Number(process.env.BD_PORTA || 3306),
  user: process.env.BD_UTILIZADOR || 'myday',
  password: process.env.BD_PASSWORD || '',
  database: process.env.BD_NOME || 'myday',
  charset: 'utf8mb4',
  dateStrings: true,
  connectionLimit: 10,
});

module.exports = bd;
