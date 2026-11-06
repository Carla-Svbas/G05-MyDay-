-- MyDay - G05
-- Conta do MySQL usada pela API (correr uma vez, como root):
--   mysql -u root -p < criar_utilizador_app.sql

create user if not exists 'myday'@'localhost' identified by 'myday_local_2026';
grant all privileges on myday.* to 'myday'@'localhost';
flush privileges;
