-- MyDay - G05
-- Dados de exemplo. Correr depois do create.sql

use myday;
set names utf8mb4;
start transaction;

insert into utilizador (email, password_hash, nome_utilizador, nome, bio, avatar_caminho, instituicao, curso, papel, consent_localizacao, consent_audio, consent_data, criado_em) values
('ines.carvalho02@gmail.com', '$2b$10$Kq8vZ1mT4xR7pL2nW9eYbOu3sJ6dF0hA5cV8gN1kM4tQ7rB2yE6iS', 'inesmcarvalho', 'Inês Marques Carvalho', '3.º ano de Química na FCUL. Orgânica > tudo o resto', 'uploads/avatars/u1_8f2a.jpg', 'Faculdade de Ciências da Universidade de Lisboa', 'Química', 'estudante', true, true, '2026-09-21 18:42:10', '2026-09-21 18:42:10'),
('tiagofgomes@hotmail.com', '$2b$10$Xp3cH7wN2bL9mQ5tR8vZ1eUo4kJ6sD0fA3gY7nB5cM2xW9qE1rT4u', 'tiago.gomes', 'Tiago Ferreira Gomes', null, null, 'Faculdade de Ciências da Universidade de Lisboa', 'Química', 'estudante', true, false, '2026-09-23 22:15:03', '2026-09-23 22:15:03'),
('beatriz.antunes@tecnico.ulisboa.pt', '$2b$10$Lm6nB3vX8cZ1qW4eR7tY0uI2oP5aS9dF3gH6jK8lN1mQ4wE7rT0yU', 'bea_antunes', 'Beatriz Antunes', 'Eng. Química @ IST', 'uploads/avatars/u3_c41d.png', 'Instituto Superior Técnico', 'Engenharia Química', 'estudante', false, false, '2026-09-30 10:05:47', '2026-09-30 10:05:47'),
('diogo.sequeira@campus.fct.unl.pt', '$2b$10$Tz9yV2cX5bN8mL1kJ4hG7fD0sA3qW6eR9tY2uI5oP8aS1dF4gH7jK', 'dsequeira', 'Diogo Sequeira', 'bioquímica, café e pouco sono', null, 'FCT NOVA', 'Bioquímica', 'estudante', true, true, '2026-10-02 14:31:22', '2026-10-02 14:31:22'),
('sofia.rebelo@myday.pt', '$2b$10$Hd4fG7jK0lM3nB6vC9xZ2aS5dF8gH1jK4lQ7wE0rT3yU6iO9pA2sD', 'sofia.admin', 'Sofia Rebelo', null, null, null, null, 'administrador', false, false, null, '2026-09-15 09:00:00');

insert into seguimento (seguidor_id, seguido_id, criado_em) values
(1, 2, '2026-09-24 08:12:55'),
(2, 1, '2026-09-24 09:40:17'),
(3, 1, '2026-10-01 21:03:40'),
(4, 1, '2026-10-03 16:22:08'),
(4, 3, '2026-10-03 16:23:51');

insert into mensagem (remetente_id, destinatario_id, texto, lida_em, criado_em) values
(1, 2, 'já tens os valores da titulação? preciso de comparar com os meus', '2026-10-13 19:02:11', '2026-10-13 18:47:30'),
(2, 1, 'sim, deu-me 4,8% de ácido acético. acho que passei um bocadinho o ponto de viragem na 2.ª', '2026-10-13 19:05:44', '2026-10-13 19:04:02'),
(4, 3, 'olá! vi o teu registo da condutividade, que condutímetro usaste?', null, '2026-10-16 11:20:15');

insert into disciplina (nome, area) values
('Química Orgânica I', 'Química'),
('Química Analítica', 'Química'),
('Química Física', 'Química'),
('Bioquímica Estrutural', 'Bioquímica'),
('Laboratórios de Química Orgânica', 'Química');

insert into tag (nome) values
('titulação'), ('recristalização'), ('espectrofotometria'), ('destilação'), ('extração'), ('cromatografia');

insert into utilizador_segue_tag (utilizador_id, tag_id) values
(1, 2), (1, 4), (1, 6), (2, 1), (3, 3), (4, 5);

insert into utilizador_segue_disciplina (utilizador_id, disciplina_id) values
(1, 1), (1, 5), (2, 2), (3, 3), (4, 4);

insert into projeto (utilizador_id, disciplina_id, titulo, descricao, visibilidade, criado_em) values
(1, 1, 'Síntese do acetato de isoamilo', 'Esterificação de Fischer entre álcool isoamílico e ácido acético. Objetivo: rendimento acima de 60%.', 'publico', '2026-10-07 20:14:33'),
(2, 2, 'Acidez do vinagre comercial', 'Determinação do teor de ácido acético em 3 marcas de vinagre por titulação com NaOH.', 'amigos', '2026-10-12 17:55:09'),
(3, 3, 'Cinética da hidrólise do acetato de etilo', 'Seguimento da reação por condutimetria a 25 ºC.', 'privado', '2026-10-14 22:30:41'),
(4, 4, 'Extração de cafeína do chá preto', 'Extração sólido-líquido e líquido-líquido, seguida de sublimação.', 'publico', '2026-10-21 13:08:26');

insert into registo (uuid_cliente, utilizador_id, projeto_id, disciplina_id, titulo, texto, latitude, longitude, latitude_aprox, longitude_aprox, morada, data_registo, criado_em) values
('3f9c2a71-8b4e-4d2f-9a6c-1e7b5d0f4a82', 1, 1, 1, 'Refluxo - 1.ª tentativa', '15 mL de álcool isoamílico + 20 mL de ácido acético glacial + 1 mL de H2SO4 conc. Refluxo durante 1h. A mistura ficou ligeiramente amarelada no fim.', 38.756820, -9.158030, 38.76, -9.16, 'Faculdade de Ciências, Campo Grande, Lisboa', '2026-10-08 10:12:00', '2026-10-08 10:14:27'),
('b7e1d4c0-2f6a-4e9b-8c3d-5a1f7e2b9d64', 1, 1, 1, 'Destilação e rendimento', 'Recolhi a fração entre 138 e 143 ºC. Massa obtida 9,8 g, rendimento de 54%. Cheira mesmo a banana.', null, null, null, null, null, '2026-10-08 12:40:00', '2026-10-08 13:02:51'),
('c2a8f5e3-6d1b-4a7c-9e0f-3b8d2c6a1e75', 2, 2, 2, 'Padronização do NaOH', 'Padronizado com hidrogenoftalato de potássio seco na estufa. Média de 3 ensaios: 0,0987 M.', 38.756820, -9.158030, 38.76, -9.16, 'Faculdade de Ciências, Campo Grande, Lisboa', '2026-10-13 15:05:00', '2026-10-13 15:09:13'),
('e4d0b9a2-7c3f-4b8e-a1d6-9f2e5c7b3a08', 2, 2, 2, 'Titulação do vinagre (marca branca)', 'Vinagre diluído 1:10. Volumes gastos: 8,15 / 8,20 / 8,10 mL. Dá cerca de 4,8% (m/v).', 38.756820, -9.158030, 38.76, -9.16, 'Faculdade de Ciências, Campo Grande, Lisboa', '2026-10-13 16:20:00', '2026-10-13 16:31:45'),
('a6f3c8d1-4e2b-49a0-b7c5-8d1e3f6a2b97', 3, 3, 3, 'Leituras de condutividade', 'Leituras de 2 em 2 min durante 40 min. A condutividade desce bem no início e depois estabiliza. Falta fazer o gráfico.', 38.736900, -9.138600, 38.74, -9.14, 'Instituto Superior Técnico, Av. Rovisco Pais, Lisboa', '2026-10-15 09:47:00', '2026-10-15 10:35:02'),
('d9b2e7f4-1a5c-4d3e-8f6b-2c9a4e1d7f30', 4, 4, 4, 'Extração com diclorometano', '3 extrações de 15 mL de DCM. Formou-se emulsão na 2.ª, tive de esperar uns 10 min. Fase orgânica seca com Na2SO4 anidro.', 38.660900, -9.203300, 38.66, -9.20, 'FCT NOVA, Caparica', '2026-10-22 14:30:00', '2026-10-22 15:48:19'),
('f1c5a9b3-8e2d-4f7a-9b0c-6e3d1a8f5c24', 1, null, 5, 'TLC do produto da aula', 'Eluente hexano:acetato de etilo 4:1. Duas manchas, Rf 0,62 e 0,35. Ainda há reagente por reagir.', 38.756820, -9.158030, 38.76, -9.16, 'Faculdade de Ciências, Campo Grande, Lisboa', '2026-10-27 11:05:00', '2026-10-27 11:21:36');

insert into ficheiro (registo_id, tipo, caminho, mime_type, tamanho_bytes, duracao_seg, ordem) values
(1, 'foto',  'uploads/registos/1/IMG_20261008_101034.jpg', 'image/jpeg', 2843117, null, 0),
(1, 'foto',  'uploads/registos/1/IMG_20261008_110512.jpg', 'image/jpeg', 3102564, null, 1),
(2, 'video', 'uploads/registos/2/VID_20261008_123815.mp4', 'video/mp4', 18452990, 27, 0),
(4, 'foto',  'uploads/registos/4/IMG_20261013_161847.jpg', 'image/jpeg', 2517803, null, 0),
(5, 'audio', 'uploads/registos/5/nota_voz_0947.m4a', 'audio/mp4', 412776, 48, 0),
(6, 'foto',  'uploads/registos/6/IMG_20261022_143302.heic', 'image/heic', 1964230, null, 0),
(7, 'foto',  'uploads/registos/7/IMG_20261027_110148.jpg', 'image/jpeg', 2290415, null, 0);

insert into registo_tag (registo_id, tag_id) values
(1, 4), (2, 4), (3, 1), (4, 1), (6, 5), (7, 6);

insert into comentario (utilizador_id, registo_id, projeto_id, texto, criado_em) values
(2, 2, null, '54% está dentro do esperado, o meu grupo no ano passado ficou nos 50 e tal', '2026-10-08 18:20:44'),
(4, 6, null, 'a emulsão acontece-me sempre, experimenta juntar um pouco de NaCl', '2026-10-22 19:11:07'),
(3, null, 1, 'Fizeste lavagem com bicarbonato antes de destilar?', '2026-10-09 09:32:58'),
(1, null, 1, 'fiz sim, 2 lavagens com NaHCO3 a 5%', '2026-10-09 10:05:13');

insert into favorito (utilizador_id, registo_id, projeto_id, criado_em) values
(2, 1, null, '2026-10-08 18:18:02'),
(3, 7, null, '2026-10-27 20:45:31'),
(4, null, 1, '2026-10-09 22:10:49');

insert into grupo (criador_id, nome, descricao, criado_em) values
(1, 'Lab QO - turno P3', 'Turno de 4.ª de manhã de Laboratórios de Química Orgânica', '2026-09-25 12:30:18');

insert into grupo_membro (grupo_id, utilizador_id, papel, entrou_em) values
(1, 1, 'dono',   '2026-09-25 12:30:18'),
(1, 2, 'membro', '2026-09-25 13:02:47');

insert into grupo_registo (grupo_id, registo_id, partilhado_por, partilhado_em) values
(1, 1, 1, '2026-10-08 13:10:05'),
(1, 7, 1, '2026-10-27 11:25:40');

insert into lembrete (utilizador_id, titulo, hora, dias_semana, ativo) values
(1, 'Passar notas do lab', '19:30:00', 31, true),
(3, 'Atualizar caderno de lab', '22:00:00', 127, true),
(4, 'Fotos das extrações', '17:45:00', 31, false);

insert into conquista (codigo, nome, descricao) values
('primeiro_registo', 'Primeira experiência', 'Criaste o teu primeiro registo'),
('semana_completa', 'Semana completa', 'Registaste algo em 5 dias seguidos'),
('primeiro_projeto', 'Mãos à obra', 'Criaste o teu primeiro projeto');

insert into utilizador_conquista (utilizador_id, conquista_id, obtida_em) values
(1, 1, '2026-10-08 10:14:27'),
(1, 3, '2026-10-07 20:14:33'),
(2, 1, '2026-10-13 15:09:13'),
(4, 1, '2026-10-22 15:48:19');

insert into denuncia (denunciante_id, registo_id, projeto_id, comentario_id, motivo, estado, tratada_por, tratada_em, criado_em) values
(3, 4, null, null, 'acho que as fotos são do relatório de outra pessoa', 'rejeitada', 5, '2026-10-15 10:02:30', '2026-10-14 23:41:16');

insert into desafio (criado_por, titulo, descricao, data_inicio, data_fim) values
(5, 'Novembro no laboratório', 'Faz pelo menos um registo por semana durante o mês de novembro.', '2026-11-01', '2026-11-30');

insert into destaque (registo_id, projeto_id, escolhido_por, criado_em) values
(null, 1, 5, '2026-10-10 09:15:00');

insert into registo_acoes (admin_id, acao, entidade_tipo, entidade_id, detalhes, criado_em) values
(5, 'rejeitar_denuncia', 'denuncia', 1, '{"motivo": "fotos confirmadas como originais da autora"}', '2026-10-15 10:02:30'),
(5, 'destacar', 'projeto', 1, '{"seccao": "feed_principal"}', '2026-10-10 09:15:00');

insert into cache_api (chave, resposta, expira_em) values
('geocode:38.76,-9.16', '{"display_name": "Campo Grande, Lisboa, Portugal", "postcode": "1749-016"}', '2026-11-11 15:00:00'),
('geocode:38.66,-9.20', '{"display_name": "Caparica, Almada, Setúbal, Portugal", "postcode": "2829-516"}', '2026-11-11 15:00:00');

-- Contas de teste: os hashes acima são de exemplo, por isso todas as contas
-- passam a usar a palavra-passe myday123 (bcrypt) para se poder entrar na app.
update utilizador set password_hash = '$2a$10$3uiP7tvlPSMeLSuHOpo/BOgvroROMSB9vetpCNwLgxXD3l/Cg5gem' where id > 0;

commit;
