-- =============================================
-- NEUROSPECTRUM - Script de Criação do Banco
-- Desenvolvido por: Mateus (DBA) 
-- =============================================

CREATE DATABASE NeuroSpectrum;
USE NeuroSpectrum;

CREATE TABLE administrador (
    administrador_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14)  NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha  VARCHAR(20) NOT NULL,
    telefone VARCHAR(20),
    ativo TINYINT DEFAULT 1,
    criado_em DATETIME    
);


CREATE TABLE profissional (
    profissional_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14)  NOT NULL UNIQUE,
    crm_crp  VARCHAR(30)  NOT NULL UNIQUE,
    tipo  VARCHAR(50)  NOT NULL, 
    especialidade VARCHAR(100),
    telefone VARCHAR(20),
    email VARCHAR(100),
    ativo  TINYINT DEFAULT 1,
    criado_em DATETIME  
);


CREATE TABLE paciente (
    paciente_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf VARCHAR(14)  NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco  VARCHAR(200),
    convenio VARCHAR(100),
    num_convenio VARCHAR(50),
    data_cadastro DATETIME 
);

CREATE TABLE disponibilidade(
disponibilidade_id INT AUTO_INCREMENT PRIMARY KEY,
dia_semana VARCHAR(50) NOT NULL,
periodo VARCHAR(50) NOT NULL,
hora_inicio TIME NOT NULL,
hora_fim TIME NOT NULL,
ativo TINYINT NOT NULL DEFAULT 1,
criado_em DATETIME );

-- Tabela Intermediária Prof_Disponibilidade (Muitos para Muitos)
CREATE TABLE prof_disponibilidade(
prof_disponibilidade_id INT AUTO_INCREMENT PRIMARY KEY,
profissional_id INT NOT NULL,
disponibilidade_id INT NOT NULL,
FOREIGN KEY (profissional_id) REFERENCES profissional (profissional_id),
FOREIGN KEY (disponibilidade_id) REFERENCES disponibilidade (disponibilidade_id));

CREATE TABLE consulta(
consulta_id INT AUTO_INCREMENT PRIMARY KEY,
paciente_id INT,
profissional_id INT,
administrador_id INT,
data_hora DATETIME,
duracao_min INT,
status ENUM('Agendada','Cancelada','Realizada'),
modalidade VARCHAR(50),
comparecimento VARCHAR(20),
observacoes TEXT,
criado_em DATETIME ,
FOREIGN KEY(paciente_id) REFERENCES paciente (paciente_id),
FOREIGN KEY (profissional_id) REFERENCES profissional (profissional_id),
FOREIGN KEY (administrador_id) REFERENCES administrador (administrador_id));

CREATE TABLE prontuario(
prontuario_id INT AUTO_INCREMENT PRIMARY KEY,
paciente_id INT,
profissional_id INT,
consulta_id INT,
data_registro DATETIME,
queixa_principal TEXT,
avaliacao TEXT,
plano_tratamento TEXT,
prescricao TEXT,
FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id),
FOREIGN KEY (profissional_id) REFERENCES profissional (profissional_id),
FOREIGN KEY (consulta_id) REFERENCES consulta (consulta_id));


CREATE TABLE receita(
receita_id INT AUTO_INCREMENT PRIMARY KEY,
consulta_id INT,
paciente_id INT,
descricao TEXT,
medicamento VARCHAR(100),
dosagem VARCHAR(50),
instrucoes VARCHAR(100),
data_emissao DATETIME ,
FOREIGN KEY(consulta_id) REFERENCES consulta (consulta_id),
FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id));

CREATE TABLE diagnostico(
diagnostico_id INT AUTO_INCREMENT PRIMARY KEY,
consulta_id INT,
paciente_id INT,
descricao TEXT,
data_registro DATETIME ,
FOREIGN KEY (consulta_id) REFERENCES consulta (consulta_id),
FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id));

CREATE TABLE tratamento(
tratamento_id INT AUTO_INCREMENT PRIMARY KEY,
consulta_id INT,
paciente_id INT,
descricao TEXT,
data_inicio DATETIME ,
data_fim DATETIME ,
status ENUM('Em andamento','Finalizado','Cancelado'),
observacoes VARCHAR(50),
FOREIGN KEY (consulta_id) REFERENCES consulta (consulta_id),
FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id));


CREATE TABLE exame(
exame_id INT AUTO_INCREMENT PRIMARY KEY,
consulta_id INT,
paciente_id INT,
tipo_exame VARCHAR(30) NOT NULL,
descricao TEXT,
data_solicitacao DATE,
data_resultado DATE,
resultado VARCHAR(100),
status ENUM('Solicitado','Em Analise','Concluido','Cancelado'),
FOREIGN KEY (consulta_id) REFERENCES consulta (consulta_id),
FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id));


-- 1. ADMINISTRADORES ( Responsáveis pelo atendimento e recepção)

INSERT INTO administrador (nome, cpf, email, senha, telefone, criado_em) VALUES
('Carlos Silva', '111.111.111-11', 'carlos.atendimento@neuro.com', 'admin123', '(61) 98888-1111', '2026-01-05 08:00:00'),
('Ana Oliveira', '222.222.222-22', 'ana.recepcao@neuro.com', 'admin128', '(61) 98888-2222', '2026-01-05 08:30:00'),
('Marcos Souza', '333.333.333-33', 'marcos.ti@neuro.com', 'admin129', '(61) 98888-3333', '2026-01-06 09:00:00'),
('Julia Costa', '444.444.444-44', 'julia.agendamentos@neuro.com', 'admin121', '(61) 98888-4444', '2026-01-06 10:15:00'),
('Roberto Alves', '555.555.555-55', 'roberto.gestao@neuro.com', 'admin102', '(61) 98888-5555', '2026-01-07 11:00:00');

-- -----------------------------------------------------------------------------
-- 2. PROFISSIONAIS (Exatamente 10 - Apenas Psicólogos, Psiquiatras e Psicopedagogas)
-- -----------------------------------------------------------------------------

INSERT INTO profissional (nome, cpf, crm_crp, tipo, especialidade, telefone, email, criado_em) VALUES
('Dra. Letícia Camargo', '101.101.101-10', 'CRP-DF 12345', 'Psicopedagoga', 'Dificuldades de Aprendizagem e Escrita', '(61) 99111-0001', 'leticia.psico@neuro.com', '2026-01-10 08:00:00'),
('Dra. Beatriz Rocha', '202.202.202-20', 'CRP-DF 54321', 'Psicopedagoga', 'Intervenção Cognitiva Infantil', '(61) 99111-0002', 'beatriz.psico@neuro.com', '2026-01-10 09:00:00'),
('Dra. Paula Coelho', '909.909.909-90', 'CRP-DF 22334', 'Psicopedagoga', 'Transtornos de Leitura e Escrita', '(61) 99111-0009', 'paula.psico@neuro.com', '2026-01-10 10:00:00'),
('Dra. Amanda Silva', '303.303.303-30', 'CRP-DF 67890', 'Neuropsicopedagoga', 'Avaliação Neurocognitiva e Aplicadora ABA', '(61) 99111-0003', 'amanda.neuro@neuro.com', '2026-01-11 08:30:00'),
('Dra. Heloísa Meireles', '343.343.343-34', 'CRP-DF 11445', 'Neuropsicopedagoga', 'Intervenção no Espectro Autista', '(61) 99111-0011', 'heloisa.neuro@neuro.com', '2026-01-11 09:30:00'),
('Dra. Simone Tebet', '404.404.404-40', 'CRP-DF 09876', 'Psicólogo', 'Manejo de Comportamento e Métodos ABA', '(61) 99111-0004', 'simone.psi@neuro.com', '2026-01-12 14:00:00'),
('Dra. Adriana Esteves', '505.505.505-50', 'CRP-DF 11223', 'Psicólogo', 'Ludoterapia e Psicoterapia Infantil', '(61) 99111-0005', 'adriana.ludo@neuro.com', '2026-01-12 15:00:00'),
('Dra. Glória Pires', '606.606.606-60', 'CRP-DF 44556', 'Psicólogo', 'Suporte Emocional e Desenvolvimento', '(61) 99111-0006', 'gloria.psi@neuro.com', '2026-01-12 16:00:00'),
('Dr. Renato Aragão', '707.707.707-70', 'CRM-DF 77889', 'Psiquiatra Infantil', 'Autismo, TDAH e Transtornos de Humor', '(61) 99111-0007', 'renato.med@neuro.com', '2026-01-15 09:00:00'),
('Dr. Roberto Cláudio', '808.808.808-80', 'CRM-DF 99001', 'Psiquiatra Infantil', 'Transtornos do Neurodesenvolvimento e Tiques', '(61) 99111-0008', 'roberto.med@neuro.com', '2026-01-15 10:00:00');


-- -----------------------------------------------------------------------------
-- 3. PACIENTES (30 Crianças e Adolescentes que frequentam a clínica)
-- -----------------------------------------------------------------------------
INSERT INTO paciente (nome, data_nascimento, cpf, telefone, email, endereco, convenio, num_convenio, data_cadastro) VALUES
('Enzo Gabriel', '2015-04-12', '121.121.121-12', '(61) 99999-1111', 'enzo@gmail.com', 'Santa Maria QR 214', 'Unimed', '111222333', '2026-01-20 14:00:00'),
('Valentina Souza', '2018-08-22', '232.232.232-23', '(61) 99999-2222', 'valentina@gmail.com', 'Gama Setor Central', 'SulAmérica', '444555666', '2026-01-22 15:30:00'),
('Arthur Lima', '2012-01-30', '343.343.343-34', '(61) 99999-3333', 'arthur@gmail.com', 'Santa Maria Clis', 'Bradesco Saúde', '777888999', '2026-01-25 09:15:00'),
('Maria Alice', '2019-11-05', '454.454.454-45', '(61) 99999-4444', 'alice@gmail.com', 'Guará II', 'Amil', '000111222', '2026-01-28 11:00:00'),
('João Miguel', '2014-06-15', '565.565.565-56', '(61) 99999-5555', 'joao@gmail.com', 'Águas Claras Av. Araucárias', 'Particular', NULL, '2026-02-02 10:00:00'),
('Laura Rocha', '2016-03-25', '676.676.676-67', '(61) 99999-6666', 'laura@gmail.com', 'Cruzeiro Velho', 'Unimed', '333444555', '2026-02-05 14:20:00'),
('Pedro Henrique', '2011-09-18', '787.787.787-78', '(61) 99999-7777', 'pedro.h@gmail.com', 'Sobradinho Q 12', 'Cassi', '999888777', '2026-02-10 09:00:00'),
('Sophia Mendes', '2017-07-07', '898.898.898-89', '(61) 99999-8888', 'sophia@gmail.com', 'Planaltina', 'Particular', NULL, '2026-02-12 16:45:00'),
('Heitor Alves', '2013-12-12', '909.909.909-90', '(61) 99999-9999', 'heitor@gmail.com', 'Ceilândia Centro', 'Geap', '555666777', '2026-02-15 11:30:00'),
('Heloísa Garcia', '2020-02-02', '010.210.010-02', '(61) 99999-0000', 'heloisa@gmail.com', 'Samambaia Norte', 'Amil', '888999000', '2026-02-18 15:00:00'),
('Davi Lucca', '2015-05-14', '111.222.333-44', '(61) 98888-1234', 'davi@gmail.com', 'Asa Norte SQN 405', 'Unimed', '123456789', '2026-02-20 08:30:00'),
('Manuela Costa', '2017-09-19', '222.333.444-55', '(61) 98888-2345', 'manuela@gmail.com', 'Santa Maria QR 312', 'SulAmérica', '987654321', '2026-02-22 10:15:00'),
('Bernardo Silva', '2013-02-11', '333.444.554-66', '(61) 98888-3456', 'bernardo@gmail.com', 'Sudoeste SQSW 302', 'Particular', NULL, '2026-02-25 14:00:00'),
('Gabriel Jesus', '2014-10-25', '444.555.666-77', '(61) 98888-4567', 'gabriel.j@gmail.com', 'Recanto das Emas', 'Bradesco Saúde', '112233445', '2026-02-28 16:20:00'),
('Isabella Melo', '2016-07-04', '555.666.777-88', '(61) 98888-5678', 'isabella@gmail.com', 'Riacho Fundo I', 'Amil', '556677889', '2026-03-02 09:45:00'),
('Matheus Nunes', '2012-12-31', '666.777.888-99', '(61) 98888-6789', 'matheus.n@gmail.com', 'Vicente Pires', 'Unimed', '998877665', '2026-03-04 11:15:00'),
('Giovanna Anton', '2018-04-15', '777.888.999-00', '(61) 98888-7890', 'giovanna.a@gmail.com', 'Asa Sul SQS 410', 'Cassi', '443322110', '2026-03-06 15:00:00'),
('Lucas Gabriel', '2015-01-08', '888.999.000-11', '(61) 98888-8901', 'lucas.g@gmail.com', 'Taguatinga Sul', 'Particular', NULL, '2026-03-09 10:30:00'),
('Beatriz Ramos', '2019-06-22', '999.000.111-22', '(61) 98888-9012', 'beatriz.r@gmail.com', 'Guará I', 'Geap', '776655443', '2026-03-11 14:00:00'),
('Samuel Dias', '2013-08-14', '000.111.222-33', '(61) 98888-0123', 'samuel@gmail.com', 'Sobradinho II', 'Amil', '221100334', '2026-03-13 09:00:00'),
('Mariana Rios', '2016-11-20', '123.456.789-01', '(61) 97777-1234', 'mariana.r@gmail.com', 'São Sebastião', 'Unimed', '887766990', '2026-03-16 11:00:00'),
('Vitor Hugo', '2014-03-03', '234.567.890-12', '(61) 97777-2345', 'vitor@gmail.com', 'Paranoá', 'SulAmérica', '110099223', '2026-03-18 15:30:00'),
('Ana Clara', '2017-05-17', '345.678.901-23', '(61) 97777-3456', 'anaclara@gmail.com', 'Santa Maria QR 118', 'Particular', NULL, '2026-03-20 10:45:00'),
('Nicolas Vieira', '2015-07-29', '456.788.901-34', '(61) 97777-4567', 'nicolas@gmail.com', 'Brazlândia', 'Bradesco Saúde', '665544778', '2026-03-23 14:15:00'),
('Beatriz Ortiz', '2018-10-02', '567.890.123-45', '(61) 97777-5678', 'ortiz@gmail.com', 'Asa Norte SQN 208', 'Amil', '993322114', '2026-03-25 09:30:00'),
('Guilherme Font', '2012-06-12', '678.901.234-56', '(61) 97777-6789', 'gui@gmail.com', 'Sudoeste SQSW 104', 'Unimed', '772211009', '2026-03-27 16:00:00'),
('Lara Croft', '2019-01-24', '789.012.345-67', '(61) 97777-7890', 'lara@gmail.com', 'Águas Claras Rua 36 Sul', 'Cassi', '339988771', '2026-03-30 11:00:00'),
('Gustavo Lima', '2014-09-09', '890.123.456-78', '(61) 97777-8901', 'gustavol@gmail.com', 'Ceilândia Sul', 'Particular', NULL, '2026-03-31 15:15:00'),
('Cecília Meire', '2016-02-14', '901.234.567-89', '(61) 97777-9012', 'cecilia@gmail.com', 'Taguatinga Centro', 'Geap', '441100882', '2026-03-31 16:30:00'),
('Murilo Couto', '2015-08-08', '012.345.678-90', '(61) 97777-0123', 'muriloc@gmail.com', 'Samambaia Sul', 'Amil', '552233114', '2026-03-31 17:00:00');


-- -----------------------------------------------------------------------------
-- 4. DISPONIBILIDADES (Horários de Segunda a Sábado com base no funcionamento do IVV)
-- -----------------------------------------------------------------------------

INSERT INTO disponibilidade (dia_semana, periodo, hora_inicio, hora_fim, criado_em) VALUES
('Segunda-Feira', 'Tarde', '15:00:00', '16:00:00', '2026-01-08 08:00:00'), 
('Terça-Feira', 'Manhã', '08:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Terça-Feira', 'Tarde', '13:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Quarta-Feira', 'Manhã', '08:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Quarta-Feira', 'Tarde', '13:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Quinta-Feira', 'Manhã', '08:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Quinta-Feira', 'Tarde', '13:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Sexta-Feira', 'Manhã', '08:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Sexta-Feira', 'Tarde', '13:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Sábado', 'Manhã', '08:00:00', '13:00:00', '2026-01-08 08:00:00'), 
('Terça-Feira', 'Tarde', '14:00:00', '18:00:00', '2026-01-08 08:00:00'),
('Quarta-Feira', 'Tarde', '14:00:00', '18:00:00', '2026-01-08 08:00:00'),
('Quinta-Feira', 'Tarde', '14:00:00', '18:00:00', '2026-01-08 08:00:00'),
('Sexta-Feira', 'Tarde', '14:00:00', '18:00:00', '2026-01-08 08:00:00'),
('Sábado', 'Manhã', '09:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Terça-Feira', 'Manhã', '09:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Quarta-Feira', 'Manhã', '09:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Quinta-Feira', 'Manhã', '09:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Sexta-Feira', 'Manhã', '09:00:00', '12:00:00', '2026-01-08 08:00:00'),
('Segunda-Feira', 'Tarde', '15:30:00', '16:30:00', '2026-01-08 08:00:00'),
('Terça-Feira', 'Tarde', '15:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Quarta-Feira', 'Tarde', '15:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Quinta-Feira', 'Tarde', '15:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Sexta-Feira', 'Tarde', '15:00:00', '17:00:00', '2026-01-08 08:00:00'),
('Sábado', 'Manhã', '10:00:00', '13:00:00', '2026-01-08 08:00:00'),
('Terça-Feira', 'Manhã', '08:30:00', '11:30:00', '2026-01-08 08:00:00'),
('Quarta-Feira', 'Manhã', '08:30:00', '11:30:00', '2026-01-08 08:00:00'),
('Quinta-Feira', 'Manhã', '08:30:00', '11:30:00', '2026-01-08 08:00:00'),
('Sexta-Feira', 'Manhã', '08:30:00', '11:30:00', '2026-01-08 08:00:00'),
('Sábado', 'Manhã', '08:30:00', '12:30:00', '2026-01-08 08:00:00');


-- -----------------------------------------------------------------------------
-- 5. INTERMEDIÁRIA PROF_DISPONIBILIDADE (Vincula os 10 profissionais às agendas)
-- -----------------------------------------------------------------------------
INSERT INTO prof_disponibilidade (profissional_id, disponibilidade_id) VALUES
(1,1), (1,2), (2,3), (2,4), (3,5), (3,6), (4,7), (4,8), (5,9), (5,10),
(6,11), (6,12), (7,13), (7,14), (8,15), (8,16), (9,17), (9,18), (10,19), (10,20),
(1,21), (2,22), (3,23), (4,24), (5,25), (6,26), (7,27), (8,28), (9,29), (10,30);

-- -----------------------------------------------------------------------------
-- 6. CONSULTAS CORRIGIDAS (Observações preenchidas para evitar excesso de NULL)
-- -----------------------------------------------------------------------------
INSERT INTO consulta (paciente_id, profissional_id, administrador_id, data_hora, duracao_min, status, modalidade, comparecimento, observacoes,criado_em) VALUES
(1, 8, 1, '2026-06-01 09:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Retorno de rotina médica', '2026-05-31 09:00:00'),
(2, 3, 1, '2026-06-01 10:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Avaliação Neuropsicopedagógica', '2026-05-31 10:00:00'),
(3, 1, 2, '2026-06-02 14:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão psicopedagógica', '2026-06-01 08:00:00'),
(4, 7, 2, '2026-06-02 15:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão com Psicólogo', '2026-06-01 09:15:00'),
-- Consultas futuras (Agendadas com campo de observação NULL - Exatamente 11 registros)
(5, 2, 3, '2026-06-03 08:30:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-02 08:00:00'),
(6, 4, 3, '2026-06-03 10:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-02 09:30:00'),
(7, 10, 4, '2026-06-04 11:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-03 11:15:00'),
(8, 5, 4, '2026-06-04 16:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-03 14:00:00'),
(9, 6, 5, '2026-06-05 09:30:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-04 09:00:00'),
(10, 9, 5, '2026-06-05 14:30:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-04 10:30:00'),
(11, 1, 1, '2026-06-08 09:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-07 08:15:00'),
(12, 2, 2, '2026-06-08 10:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-07 09:00:00'),
(13, 3, 3, '2026-06-09 14:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-08 14:00:00'),
(14, 4, 4, '2026-06-09 15:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-08 14:30:00'),
(15, 5, 5, '2026-06-10 08:00:00', 50, 'Agendada', 'Presencial', 'Pendente', NULL, '2026-06-09 08:00:00'),
-- Consultas preenchidas com observações de acompanhamento regular
(16, 6, 1, '2026-06-10 11:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão semanal de ludoterapia', '2026-06-09 09:30:00'),
(17, 7, 2, '2026-06-11 15:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Treino fonológico focado em fala', '2026-06-10 14:00:00'),
(18, 8, 3, '2026-06-11 16:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Acompanhamento de manejo medicamentoso', '2026-06-10 15:15:00'),
(19, 9, 4, '2026-06-12 09:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Terapia ABA individualizada', '2026-06-11 08:00:00'),
(20, 10, 5, '2026-06-12 10:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Intervenção para seletividade alimentar', '2026-06-11 09:15:00'),
(21, 1, 1, '2026-06-15 14:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Apoio psicopedagógico em leitura', '2026-06-14 11:00:00'),
(22, 2, 2, '2026-06-15 15:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão regular de psicomotricidade', '2026-06-14 14:30:00'),
(23, 3, 3, '2026-06-16 08:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Avaliação de marcos do neurodesenvolvimento', '2026-06-15 08:00:00'),
(24, 4, 4, '2026-06-16 10:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Treino de habilidades sociais lúdicas', '2026-06-15 09:00:00'),
(25, 5, 5, '2026-06-17 11:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Manejo comportamental para TOD', '2026-06-16 10:15:00'),
(26, 6, 1, '2026-06-17 16:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'TCC focada em ansiedade escolar', '2026-06-16 14:00:00'),
(27, 7, 2, '2026-06-18 09:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Exercícios de comunicação alternativa', '2026-06-17 08:30:00'),
(28, 8, 3, '2026-06-18 14:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Análise de resposta sensorial tátil', '2026-06-17 11:15:00'),
(29, 9, 4, '2026-06-19 09:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão de estimulação cognitiva precoce', '2026-06-18 08:00:00'),
(30, 10, 5, '2026-06-19 10:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Orientação parental e entrega de relatório', '2026-06-18 09:00:00');


-- -----------------------------------------------------------------------------
-- 7. PRONTUÁRIOS (Evolução clínica dos pacientes infantojuvenis)
-- -----------------------------------------------------------------------------
INSERT INTO prontuario (paciente_id, profissional_id, consulta_id, queixa_principal, avaliacao, plano_tratamento, prescricao, data_registro) VALUES
(1, 8, 1, 'Agitação severa escolar', 'Paciente apresenta sinais clássicos de TDAH combinado.', 'Terapia comportamental semanal.', 'Ritalina 10mg pela manhã', '2026-06-01 09:50:00'),
(2, 3, 2, 'Dificuldade de interação social', 'Sinais compatíveis com TEA nível 1 de suporte.', 'Intervenção com método ABA.', 'Nenhuma medicação necessária no momento', '2026-06-01 11:20:00'),
(3, 1, 3, 'Dificuldade extrema em focar e seguir comandos simples', 'Sinais de atraso no desenvolvimento executivo e suspeita de TDAH desatento.', 'Iniciar terapia de estimulação neuropsicológica e rotinas visuais.', NULL, '2026-06-02 14:50:00'),
(4, 7, 4, 'Ansiedade crônica e insônia', 'Crises de choro mapeadas devido à pressão escolar.', 'TCC focada em controle de ansiedade na infância.', 'Passiflora infantil se necessário', '2026-06-02 16:20:00'),
(5, 2, NULL, 'Atraso na alfabetização', 'Dificuldade de processamento fonológico.', 'Reforço psicopedagógico lúdico.', NULL, '2026-06-03 09:15:00'),
(6, 4, NULL, 'Alterações bruscas de humor e birras intensas', 'Sintomas correlatos a desregulação emocional na infância.', 'Monitoramento de rotina e sono.', NULL, '2026-06-03 11:00:00'),
(7, 10, NULL, 'Isolamento em sala de aula', 'Timidez excessiva com indícios de ansiedade social na infância.', 'Dinâmicas de grupo guiadas para socialização.', NULL, '2026-06-04 12:00:00'),
(8, 5, NULL, 'Comportamentos repetitivos', 'Estereotipias motoras (flapping de mãos) sob estresse.', 'Ajuste sensorial ambiental com TO.', NULL, '2026-06-04 17:00:00'),
(9, 1, NULL, 'Dificuldade em focar na leitura', 'Indícios de dislexia de desenvolvimento.', 'Exercícios de leitura guiada lúdica.', NULL, '2026-06-05 10:30:00'),
(10, 2, NULL, 'Agressividade sem motivo aparente na escola', 'Desregulação emocional generalizada.', 'Orientação parental sistemática.', NULL, '2026-06-05 15:30:00'),
(11, 3, NULL, 'Fobia escolar latente', 'Ansiedade de separação materna crônica.', 'Aproximação escolar gradativa assistida.', NULL, '2026-06-08 10:00:00'),
(12, 5, NULL, 'Tiques motores e vocais piscando os olhos', 'Sintomatologia leve de tiques transitórios da infância.', 'Terapia de reversão de hábitos lúdicos.', NULL, '2026-06-08 11:00:00'),
(13, 6, NULL, 'Choro persistent e recusa em brincar com outras crianças', 'Episódio de retração social moderada pós-mudança escolar.', 'Ativação comportamental focada no brincar.', NULL, '2026-06-09 15:00:00'),
(14, 7, NULL, 'Dificuldade de seguir regras e desobediência crônica', 'Sintomas de Transtorno Opositor Desafiador (TOD).', 'Treinamento de manejo com os pais (Foco em reforço positivo).', NULL, '2026-06-09 16:00:00'),
(15, 8, NULL, 'Problemas graves com sono', 'Insônia inicial severa induzida por uso noturno de telas.', 'Higiene do sono infantil rigorosa.', NULL, '2026-06-10 09:00:00'),
(16, 9, NULL, 'Choro fácil nas tarefas escolares', 'Baixa tolerância à frustração observada.', 'Treino de resiliência emocional infantil.', NULL, '2026-06-10 12:00:00'),
(17, 10, NULL, 'Mutismo seletivo na escola', 'Comunicação verbal restrita estritamente a familiares próximos.', 'Dessensibilização sistemática no ambiente escolar.', NULL, '2026-06-11 16:00:00'),
(18, 1, NULL, 'Falta de coordenação motora e quedas frequentes', 'Transtorno do Desenvolvimento da Coordenação (TDC).', 'Encaminhamento para Psicomotricidade e TO.', NULL, '2026-06-11 17:00:00'),
(19, 2, NULL, 'Inquietação excessiva nas refeições', 'Hiperatividade motora periférica.', 'Estratégias de ancoragem física e cadeiras adaptadas.', NULL, '2026-06-12 10:30:00'),
(20, 3, NULL, 'Medo excessivo de barulhos como liquidificador', 'Hipersensibilidade auditiva sensorial mapeada.', 'Uso controlled de abafadores de ruído em crises.', NULL, '2026-06-12 11:30:00'),
(21, 5, NULL, 'Mania de organização estrita com brinquedos em linha', 'Traços rígidos de comportamento obsessivo comuns no TEA.', 'Flexibilização cognitiva guiada através do brincar.', NULL, '2026-06-15 15:00:00'),
(22, 6, NULL, 'Dificuldade de memorizar rotinas diárias simples', 'Déficit de funções executivas.', 'Uso de cronogramas visuais fixos no quarto.', NULL, '2026-06-15 16:30:00'),
(23, 7, NULL, 'Seletividade alimentar extrema recusando sólidos', 'Aversão a texturas pastosas e cores específicas.', 'Abordagem nutricional comportamental integrada à TO.', NULL, '2026-06-16 09:30:00'),
(24, 8, NULL, 'Pesadelos recorrentes noturnos e despertares em pânico', 'Terror noturno infantil esporádico.', 'Acompanhamento emocional e diário de sono com os pais.', NULL, '2026-06-16 11:00:00'),
(25, 9, NULL, 'Dificuldade em interpretar historinhas', 'Déficit de compreensão leitora infantil.', 'Treino de inferências textuais com figuras.', NULL, '2026-06-17 12:00:00'),
(26, 10, NULL, 'Roer unhas até sangrar em momentos de prova', 'Onicofagia severa associada a ansiedade escolar.', 'Substituição de hábitos motores por brinquedos de apertar.', NULL, '2026-06-17 17:00:00'),
(27, 4, NULL, 'Agitação extrema após o uso de tablet', 'Sobrecarga dopaminérgica digital infantil.', 'Redução drástica do tempo de tela diário.', NULL, '2026-06-18 10:30:00'),
(28, 1, NULL, 'Esquecimento de materiais escolares diariamente', 'Déficit crônico de atenção executiva (TDAH).', 'Estratégia de checklist visual colado na mochila.', NULL, '2026-06-18 15:30:00'),
(29, 2, NULL, 'Ansiedade ao apresentar trabalhos para a turma', 'Medo intenso de julgamento social e timidez.', 'Simulação de oratória assistida na clínica de forma lúdica.', NULL, '2026-06-19 10:00:00'),
(30, 6, NULL, 'Agitação motora e irritabilidade no final da tarde', 'Fadiga neurológica por sobrecarga sensorial escolar.', 'Protocolo de relaxamento e desaceleração passiva pós-escola.', NULL, '2026-06-19 11:00:00');


-- -----------------------------------------------------------------------------
-- 8. RECEITAS (Prescrições pediátricas emitidas após as consultas)
-- -----------------------------------------------------------------------------
INSERT INTO receita (consulta_id, paciente_id, descricao, medicamento, dosagem, instrucoes, data_emissao) VALUES
(1, 1, 'Tratamento Inicial TDAH Pediátrico', 'Ritalina 10mg', '1 comprimido', 'Tomar pela manhã após o café da manhã.', '2026-06-01 09:50:00'),
(2, 2, 'Controle de Agitação e Estereotipias Críticas', 'Risperidona 1mg', '0.5ml', 'Tomar por via oral à noite.', '2026-06-01 11:20:00'),
(3, 3, 'Suporte Foco Infantil', 'Neumentix Infantil', '1 cápsula', 'Tomar no café da manhã.', '2026-06-02 14:50:00'),
(4, 4, 'Tratamento de Crise de Ansiedade Aguda', 'Clonazepam Gotas 2.5mg/ml', '2 gotas', 'Se necessário em crises extremas de pânico.', '2026-06-02 16:20:00'),
(1, 1, 'Complemento de Vitaminas Neurodesenvolvimento', 'Metilfolato Infantil', '5 gotas', 'Tomar junto ao almoço.', '2026-06-01 09:55:00'),
(2, 2, 'Suporte Natural ao Sono Infantil', 'Melatonina Gotas', '2 gotas', '30 minutos antes do horário de dormir.', '2026-06-01 11:25:00'),
(3, 3, 'Suporte ao Foco e Atenção', 'Atentah 10mg', '1 cápsula', 'Pela manhã diariamente.', '2026-06-02 14:55:00'),
(4, 4, 'Indutor de Sono Seguro Pediátrico', 'Suplemento de Triptofano Gotas', '5 gotas', 'Antes de deitar.', '2026-06-02 16:25:00'),
(1, 1, 'Tratamento TDAH Continuado', 'Venvanse 30mg', '1 cápsula', 'Pela manhã em jejum.', '2026-06-01 10:00:00'),
(2, 2, 'Suporte Nutricional para Seletividade', 'Ômega 3 Infantil DHA', '1 cápsula', 'Junto ao almoço.', '2026-06-01 11:30:00'),
(3, 3, 'Suporte de Suplementação Cognitiva', 'Complexo B Infantil', '5ml', 'Pela manhã.', '2026-06-02 15:00:00'),
(4, 4, 'Antidepressivo / Ansiedade na Adolescência', 'Sertralina 25mg', 'Meio comprimido', 'Pela manhã diário.', '2026-06-02 16:30:00'),
(1, 1, 'Suporte Foco Escolar', 'Aritam Pediátrico', '1 comprimido', 'Pela manhã.', '2026-06-01 10:05:00'),
(2, 2, 'Ansiedade Infantil Geral', 'Buspirona 5mg', 'Meio comprimido', 'Pela manhã.', '2026-06-01 11:35:00'),
(3, 3, 'Suplementação Zinco e Magnésio', 'Magnésio Inositol Pediátrico', '1 sachê', 'Diluído em água à noite.', '2026-06-02 15:05:00'),
(4, 4, 'Suporte Alerta e Disfunção Executiva', 'Anfetamina Controlada', '1 cápsula', 'Conforme orientação rigorosa pela manhã.', '2026-06-02 16:35:00'),
(1, 1, 'Ajuste de Ansiedade Infantil', 'Fluoxetina Gotas 20mg/ml', '4 gotas', 'Pela manhã.', '2026-06-01 10:10:00'),
(2, 2, 'Complexo Mineral Infantil', 'Zinco Quelato 15mg', '1 cápsula', 'À noite.', '2026-06-01 11:40:00'),
(3, 3, 'Suporte Foco e Calma', 'L-Teanina Pediátrica 100mg', '1 cápsula', 'Antes da escola.', '2026-06-02 15:10:00'),
(4, 4, 'Fitoterápico Ansiedade Leve', 'Valeriana Gotas Pediátrica', '5 gotas', 'À tarde diluído.', '2026-06-02 16:40:00'),
(1, 1, 'Ajuste Melhora Foco', 'Neumentix 200mg', '1 cápsula', 'No café da manhã.', '2026-06-01 10:15:00'),
(2, 2, 'Estímulo Apetite Seletividade', 'Cobavital', '1 microcomprimido', '30 minutos antes do almoço.', '2026-06-01 11:45:00'),
(3, 3, 'Ajuste Impulsividade Infantil', 'Oxcarbazepina 300mg', 'Meio comprimido', 'À noite.', '2026-06-02 15:15:00'),
(4, 4, 'Antidepressivo Noturno Ansiedade', 'Mirtazapina 15mg', 'Meio comprimido', 'À noite ao deitar.', '2026-06-02 16:45:00'),
(1, 1, 'Ajuste de Agitação Noturna', 'Clonidina 0.1mg', 'Meio comprimido', 'À noite.', '2026-06-01 10:20:00'),
(2, 2, 'Suporte Gastro Intestinal Autismo', 'Probiótico Infantil Sachê', '1 sachê', 'Diluído em água pela manhã.', '2026-06-01 11:50:00'),
(3, 3, 'Suplemento de Ferro Pediátrico', 'Ferro Quelato Gotas', '10 gotas', 'Após o almoço.', '2026-06-02 15:20:00'),
(4, 4, 'Ajuste de Crises Severas Escolares', 'Alprazolam 0.25mg', 'Meio comprimido', 'Em caso de pânico extremo na escola.', '2026-06-02 16:50:00'),
(1, 1, 'Aminoácidos Foco', 'L-Teanina 200mg', '1 cápsula', 'Antes de ir para a escola.', '2026-06-01 10:25:00'),
(2, 2, 'Vitamina D Concentrada Pediátrica', 'Vitamina D3 2000UI', '1 gota', 'Pela manhã.', '2026-06-01 11:55:00');

-- -----------------------------------------------------------------------------
-- 9. DIAGNÓSTICOS (CID-10 focados em TEA, TDAH, TOD e atrasos de desenvolvimento)
-- -----------------------------------------------------------------------------
INSERT INTO diagnostico (consulta_id, paciente_id, descricao, data_registro) VALUES
(1, 1, 'F90.0 - Distúrbio da atividade e da atenção (TDAH)', '2026-06-01 09:30:00'),
(2, 2, 'F84.0 - Autismo Infantil (TEA Nível 1 de suporte)', '2026-06-01 11:00:00'),
(3, 3, 'F84.1 - Autismo Atípico (TEA Nível 2)', '2026-06-02 14:45:00'),
(4, 4, 'F41.1 - Ansiedade Generalizada na Infância', '2026-06-02 16:15:00'),
(1, 1, 'F91.3 - Transtorno Desafiador Opositor (TOD)', '2026-06-03 08:45:00'),
(2, 2, 'F80 - Transtornos de desenvolvimento da fala e da linguagem', '2026-06-03 08:45:00'),
(3, 3, 'F82 - Transtorno específico do desenvolvimento motor (Dispraxia)', '2026-06-03 08:45:00'),
(4, 4, 'F41.0 - Transtorno de Pânico Infantil', '2026-06-03 08:45:00'),
(1, 1, 'F98.8 - Outros transtornos comportamentais especificados da infância', '2026-06-04 10:30:00'),
(2, 2, 'F84.5 - Síndrome de Asperger', '2026-06-04 10:30:00'),
(3, 3, 'F88 - Outros transtornos do desenvolvimento psicológico (Atraso Global)', '2026-06-04 10:30:00'),
(4, 4, 'F51.0 - Insônia não orgânica na infância', '2026-06-04 10:30:00'),
(1, 1, 'F90.1 - Transtorno hipercinético de conduta', '2026-06-05 14:00:00'),
(2, 2, 'F95.1 - Transtorno de tiques motores ou vocais crônicos', '2026-06-05 14:00:00'),
(3, 3, 'F81.0 - Transtorno específico da leitura (Dislexia)', '2026-06-05 14:00:00'),
(4, 4, 'F43.2 - Transtornos de adaptação escolar', '2026-06-05 14:00:00'),
(1, 1, 'F90.8 - Outros transtornos hipercinéticos da infância', '2026-06-08 09:15:00'),
(2, 2, 'F93.0 - Transtorno de ansiedade de separação da infância', '2026-06-08 09:15:00'),
(3, 3, 'F81.1 - Transtorno específico da soletração (Disgrafia)', '2026-06-08 09:15:00'),
(4, 4, 'F32.0 - Episódio depressivo leve na infância', '2026-06-08 09:15:00'),
(1, 1, 'F92 - Transtornos mistos de conduta e das emoções', '2026-06-09 11:30:00'),
(2, 2, 'F98.5 - Gagueira Infantil (Espasmofemia)', '2026-06-09 11:30:00'),
(3, 3, 'F81.2 - Transtorno específico da aritmologia (Discalculia)', '2026-06-09 11:30:00'),
(4, 4, 'F42 - Transtorno obsessivo-compulsivo (TOC) Infantil', '2026-06-09 11:30:00'),
(1, 1, 'F91.0 - Transtorno de conduta restrito ao contexto familiar', '2026-06-10 15:20:00'),
(2, 2, 'F80.2 - Transtorno da recepção da linguagem (Aphasia de recepção)', '2026-06-10 15:20:00'),
(3, 3, 'R62.0 - Atraso do developmento psicomotor voluntário', '2026-06-10 15:20:00'),
(4, 4, 'F40.1 - Fobia Social Escolar', '2026-06-10 15:20:00'),
(1, 1, 'F93.8 - Outros transtornos emocionais da infância', '2026-06-11 16:40:00'),
(2, 2, 'F95.0 - Transtorno de tique transitório', '2026-06-11 16:40:00');

-- -----------------------------------------------------------------------------
-- 10. TRATAMENTOS (Método ABA, Psicopedagogia e suporte de inclusão)
-- -----------------------------------------------------------------------------
INSERT INTO tratamento (consulta_id, paciente_id, descricao, status, observacoes, data_inicio, data_fim) VALUES
(1, 1, 'Intervenção Psicoterapêutica TDAH', 'Em andamento', 'Sessões semanais', '2026-06-01 10:00:00', NULL),
(2, 2, 'Terapia Ocupacional Sensorial', 'Em andamento', 'Foco em regulação', '2026-06-01 11:30:00', NULL),
(3, 3, 'Reabilitação Cognitiva e Apoio Pedagógico', 'Em andamento', 'Estimulação lógica', '2026-06-02 15:00:00', NULL),
(4, 4, 'Psicoterapia de Abordagem TCC', 'Em andamento', 'Manejo de ansiedade', '2026-06-02 16:30:00', NULL),
(1, 1, 'Treinamento de Pais Metodologia ABA', 'Em andamento', 'Suporte familiar', '2026-06-03 09:00:00', NULL),
(2, 2, 'Fonoaudiologia focado em Linguagem', 'Em andamento', 'Treino fonológico', '2026-06-03 10:00:00', NULL),
(3, 3, 'Fisioterapia Motora Preventiva', 'Em andamento', 'Exercícios leves', '2026-06-04 11:30:00', NULL),
(4, 4, 'Grupo de Apoio Controle de Estresse', 'Em andamento', 'Partilha monitorada', '2026-06-04 15:00:00', NULL),
(1, 1, 'Acompanhamento Psicopedagógico Escolar', 'Em andamento', 'Adaptação curricular', '2026-06-05 09:00:00', NULL),
(2, 2, 'Equoterapia de Desenvolvimento', 'Em andamento', 'Ganho de tônus', '2026-06-05 10:30:00', NULL),
(3, 3, 'Musicoterapia Ativa Infantil', 'Em andamento', 'Estímulo sonoro', '2026-06-08 14:00:00', NULL),
(4, 4, 'Higiene do Sono Assistida', 'Em andamento', 'Rotina restrita', '2026-06-08 15:30:00', NULL),
(1, 1, 'Treino de Habilidades Sociais', 'Em andamento', 'Dinâmica em grupo', '2026-06-09 09:00:00', NULL),
(2, 2, 'Hidroterapia de Relaxamento', 'Em andamento', 'Redução de tônus', '2026-06-09 10:00:00', NULL),
(3, 3, 'Acompanhamento Nutricional Restrito', 'Em andamento', 'Ajuste de rotina', '2026-06-10 11:15:00', NULL),
(4, 4, 'Mindfulness Clínico Aplicado', 'Em andamento', 'Exercício de foco', '2026-06-10 16:00:00', NULL),
(1, 1, 'Manejo de Comportamento Destrutivo', 'Em andamento', 'Prevenção de crises', '2026-06-11 09:30:00', NULL),
(2, 2, 'Terapia ABA Intensiva Individual', 'Em andamento', 'Análise aplicada', '2026-06-11 14:30:00', NULL),
(3, 3, 'Arteterapia para Crianças com TEA', 'Em andamento', 'Estímulo expressivo', '2026-06-12 09:00:00', NULL),
(4, 4, 'Treino Desensibilização Fobias', 'Em andamento', 'Exposição guiada', '2026-06-12 10:00:00', NULL),
(1, 1, 'Suporte Inclusão Colégio', 'Em andamento', 'Mediação escolar', '2026-06-15 14:00:00', NULL),
(2, 2, 'Desenvolvimento Psicomotor', 'Em andamento', 'Coordenação ampla', '2026-06-15 15:30:00', NULL),
(3, 3, 'Atividades da Vida Diária (AVD) Infantil', 'Em andamento', 'Treino de autonomia', '2026-06-16 08:30:00', NULL),
(4, 4, 'Terapia de Aceitação e Compromisso', 'Em andamento', 'Foco em valores', '2026-06-16 10:00:00', NULL),
(1, 1, 'Regulação Emocional Prática', 'Em andamento', 'Identificação de gatilhos', '2026-06-17 11:00:00', NULL),
(2, 2, 'Integração Sensorial de Ayres', 'Em andamento', 'Clinica equipada', '2026-06-17 16:00:00', NULL),
(3, 3, 'Estimulação Magnética Transcraniana', 'Em andamento', 'Protocolo padrão', '2026-06-18 09:30:00', NULL),
(4, 4, 'Terapia Focada em Esquemas Infantis', 'Em andamento', 'Mapeamento profundo', '2026-06-18 14:30:00', NULL),
(1, 1, 'Manejo Opositor Desafiador', 'Em andamento', 'Reforço positivo', '2026-06-19 09:00:00', NULL),
(2, 2, 'Treino Alternativo de Comunicação', 'Em andamento', 'Uso de pranchas PEX', '2026-06-19 10:00:00', NULL);

-- -----------------------------------------------------------------------------
-- 11. EXAMES (Avaliações neuropsicológicas, escalas e rastreios)
-- -----------------------------------------------------------------------------
INSERT INTO exame (consulta_id, paciente_id, tipo_exame, descricao, data_solicitacao, data_resultado, resultado, status) VALUES
(1, 1, 'Eletroencefalograma (EEG)', 'Mapeamento cerebral em sono e vigília.', '2026-06-01', '2026-06-05', 'Padrão dentro da normalidade para a idade.', 'Concluido'),
(2, 2, 'Avaliação Neuropsicológica', 'Bateria de testes de funções executivas.', '2026-06-01', '2026-06-15', 'Acentuada disfunção executiva e seletividade.', 'Concluido'),
(3, 3, 'Ressonância do Crânio', 'Investigação de estruturas cerebrais.', '2026-06-02', '2026-06-06', 'Estrutura cortical hipocampal normal para a idade.', 'Concluido'),
(4, 4, 'Exame de Sangue Hormonal', 'Dosagem de Cortisol, TSH e T4 Livre.', '2026-06-02', '2026-06-04', 'Cortisol discretamente elevado. TSH normal.', 'Concluido'),
(1, 1, 'Polissonografia Completa', 'Avaliação de distúrbio do sono infantil.', '2026-06-03', NULL, NULL, 'Solicitado'),
(2, 2, 'Triagem Auditiva', 'Mapeamento de hipersensibilidade auditiva.', '2026-06-03', NULL, NULL, 'Solicitado'),
(3, 3, 'Tomografia Computadorizada', 'Investigação complementar neurológica.', '2026-06-04', NULL, NULL, 'Solicitado'),
(4, 4, 'Mapeamento Genético', 'Investigação de variantes genéticas e mutações.', '2026-06-04', NULL, NULL, 'Solicitado'),
(1, 1, 'Exame de Vista Processamento', 'Descarte de erros de refração crônicos.', '2026-06-05', NULL, NULL, 'Solicitado'),
(2, 2, 'Avaliação de Praxia de Fala', 'Investigação de apraxia verbal na infância.', '2026-06-05', NULL, NULL, 'Solicitado'),
(3, 3, 'Dosagem de Vitaminas', 'Monitoramento vitamínico pediátrico geral.', '2026-06-06', NULL, NULL, 'Solicitado'),
(4, 4, 'Eletrocardiograma (ECG)', 'Check-up prévio para medicação estimulante.', '2026-06-06', NULL, NULL, 'Solicitado'),
(1, 1, 'Teste de Atenção (TAVIS)', 'Medição computadorizada de impulsividade.', '2026-06-10', NULL, NULL, 'Solicitado'),
(2, 2, 'Avaliação ABA Linha Base', 'Mapeamento de marcos de desenvolvimento.', '2026-06-10', NULL, NULL, 'Solicitado'),
(3, 3, 'Teste de Rastreio Coletivo', 'Avaliação cognitiva lúdica inicial.', '2026-06-11', NULL, NULL, 'Solicitado'),
(4, 4, 'Inventário de Ansiedade Beck', 'Aplicação de escala de mensuração de estresse.', '2026-06-11', NULL, NULL, 'Solicitado'),
(1, 1, 'Hemograma Completo', 'Rotina pediátrica clínica de acompanhamento.', '2026-06-12', NULL, NULL, 'Solicitado'),
(2, 2, 'Avaliação Seletividade', 'Mapeamento de deficiências de nutrientes.', '2026-06-12', NULL, NULL, 'Solicitado'),
(3, 3, 'Doppler Transcraniano', 'Avaliação de fluxo sanguíneo cerebral infantil.', '2026-06-15', NULL, NULL, 'Solicitado'),
(4, 4, 'Escala Hamilton Ansiedade', 'Entrevista diagnóstica assistida.', '2026-06-15', NULL, NULL, 'Solicitado'),
(1, 1, 'Avaliação Psicopedagógica', 'Mapeamento de competências de grafia.', '2026-06-16', NULL, NULL, 'Solicitado'),
(2, 2, 'Videofluoroscopia', 'Análise de deglutição atípica e recusa alimentar.', '2026-06-16', NULL, NULL, 'Solicitado'),
(3, 3, 'Painel Bioquímico', 'Avaliação de eletrólitos séricos.', '2026-06-17', NULL, NULL, 'Solicitado'),
(4, 4, 'Teste Ergométrico Completo', 'Avaliação cardíaca de estresse físico.', '2026-06-17', NULL, NULL, 'Solicitado'),
(1, 1, 'Exame de Urina Rotina EAS', 'Descarte de infecções subclínicas comportamentais.', '2026-06-20', NULL, NULL, 'Solicitado'),
(2, 2, 'Avaliação Perfil Sensorial', 'Análise de perfil sensorial com os pais.', '2026-06-20', NULL, NULL, 'Solicitado'),
(3, 3, 'Glicemia de Jejum', 'Curva glicêmica metabólica basal.', '2026-06-21', NULL, NULL, 'Solicitado'),
(4, 4, 'Polissonografia Noite Inteira', 'Investigação de apneia obstrutiva na infância.', '2026-06-21', NULL, NULL, 'Solicitado'),
(1, 1, 'Escala SNAP-IV de TDAH', 'Questionário avaliativo enviado a professores.', '2026-06-22', NULL, NULL, 'Solicitado'),
(2, 2, 'Teste de Desempenho TDE', 'Mensuração de defasagem pedagógica escolar.', '2026-06-22', NULL, NULL, 'Solicitado');

