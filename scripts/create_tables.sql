-- =============================================================================
-- NEUROSPECTRUM - Módulo de Agendamentos & Agenda Integrada
--  (Script Completo - Mantendo Dados Base e Integrando com Figma/Backend)
-- Desenvolvido por: Mateus (DBA) | Projeto ADS
-- =============================================================================

CREATE DATABASE IF NOT EXISTS NeuroSpectrum;
USE NeuroSpectrum;

-- 1. Tabela: ADMINISTRADOR (Secretárias e equipe administrativa)
CREATE TABLE administrador (
    administrador_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(20) NOT NULL,
    telefone VARCHAR(20),
    ativo TINYINT DEFAULT 1,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela: PROFISSIONAL (Psicólogos, Psiquiatras e Psicopedagogas)
CREATE TABLE profissional (
    profissional_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    crm_crp VARCHAR(30) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL, 
    especialidade VARCHAR(100),
    telefone VARCHAR(20),
    email VARCHAR(100),
    ativo TINYINT DEFAULT 1,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela: PACIENTE (Crianças e adolescentes em atendimento)
CREATE TABLE paciente (
    paciente_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(200),
    convenio VARCHAR(100),
    num_convenio VARCHAR(50),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabela: DISPONIBILIDADE (Grades de horários da clínica)
CREATE TABLE disponibilidade (
    disponibilidade_id INT AUTO_INCREMENT PRIMARY KEY,
    dia_semana VARCHAR(50) NOT NULL,
    periodo VARCHAR(50) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    ativo TINYINT NOT NULL DEFAULT 1,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabela Intermediária: PROF_DISPONIBILIDADE (Relacionamento N:N)
CREATE TABLE prof_disponibilidade (
    prof_disponibilidade_id INT AUTO_INCREMENT PRIMARY KEY,
    profissional_id INT NOT NULL,
    disponibilidade_id INT NOT NULL,
    FOREIGN KEY (profissional_id) REFERENCES profissional (profissional_id) ON DELETE CASCADE,
    FOREIGN KEY (disponibilidade_id) REFERENCES disponibilidade (disponibilidade_id) ON DELETE CASCADE
);

-- 6. Tabela: CONSULTA (Tabela Central do Módulo de Agendamentos)
CREATE TABLE consulta (
    consulta_id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    profissional_id INT,
    administrador_id INT,
    data_hora DATETIME,
    duracao_min INT,
    status ENUM('Agendada', 'Cancelada', 'Realizada', 'Concluido', 'Em Andamento') DEFAULT 'Agendada',
    modalidade VARCHAR(50),
    comparecimento VARCHAR(20) DEFAULT 'Pendente',
    observacoes TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id) ON DELETE RESTRICT,
    FOREIGN KEY (profissional_id) REFERENCES profissional (profissional_id) ON DELETE RESTRICT,
    FOREIGN KEY (administrador_id) REFERENCES administrador (administrador_id) ON DELETE SET NULL
);

-- 7. NOVA TABELA: AGENDA (Sincronizada com Figma e o Backend do Fernando)
CREATE TABLE agenda (
    agenda_id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    profissional_id INT NOT NULL,
    consulta_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    status VARCHAR(50) DEFAULT 'Pendente',
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paciente_id) REFERENCES paciente (paciente_id) ON DELETE CASCADE,
    FOREIGN KEY (profissional_id) REFERENCES profissional (profissional_id) ON DELETE CASCADE,
    FOREIGN KEY (consulta_id) REFERENCES consulta (consulta_id) ON DELETE CASCADE
);

-- =============================================================================
-- 8. PROGRAMAÇÃO PROCEDURAL (STORED PROCEDURE COM VALIDAÇÃO IF/ELSE)
-- =============================================================================

DELIMITER $$

CREATE PROCEDURE AgendarConsulta(
    IN p_paciente_id INT,
    IN p_profissional_id INT,
    IN p_administrador_id INT,
    IN p_data_hora DATETIME,
    IN p_duracao_min INT,
    IN p_modalidade VARCHAR(30),
    IN p_observacoes TEXT
)
BEGIN
    DECLARE v_existe_conflito INT;
    DECLARE v_nova_consulta_id INT;

    -- Validação de conflito de horários
    SELECT COUNT(*) INTO v_existe_conflito
    FROM consulta
    WHERE profissional_id = p_profissional_id 
      AND data_hora = p_data_hora
      AND status = 'Agendada';

    IF v_existe_conflito > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Este profissional já possui uma consulta agendada para este dia e horário.';
    ELSE
        -- Insere na tabela consulta
        INSERT INTO consulta (paciente_id, profissional_id, administrador_id, data_hora, duracao_min, status, modalidade, comparecimento, observacoes, criado_em)
        VALUES (p_paciente_id, p_profissional_id, p_administrador_id, p_data_hora, p_duracao_min, 'Agendada', p_modalidade, 'Pendente', p_observacoes, NOW());
        
        -- Pega o ID gerado automaticamente
        SET v_nova_consulta_id = LAST_INSERT_ID();
        
        -- Alimenta a tabela agenda em sincronia com o fluxo do calendário
        INSERT INTO agenda (paciente_id, profissional_id, consulta_id, data_hora, status)
        VALUES (p_paciente_id, p_profissional_id, v_nova_consulta_id, p_data_hora, 'Pendente');
    END IF;
END $$

DELIMITER ;

-- =============================================================================
-- 9. INSERÇÃO DE DADOS DE TESTE (DML)
-- =============================================================================

-- 9.1 Administradores (5 registros)
INSERT INTO administrador (nome, cpf, email, senha, telefone, criado_em) VALUES
('Carlos Silva', '111.111.111-11', 'carlos.atendimento@neuro.com', 'admin123', '(61) 98888-1111', '2026-01-05 08:00:00'),
('Ana Oliveira', '222.222.222-22', 'ana.recepcao@neuro.com', 'admin128', '(61) 98888-2222', '2026-01-05 08:30:00'),
('Marcos Souza', '333.333.333-33', 'marcos.ti@neuro.com', 'admin129', '(61) 98888-3333', '2026-01-06 09:00:00'),
('Julia Costa', '444.444.444-44', 'julia.agendamentos@neuro.com', 'admin121', '(61) 98888-4444', '2026-01-06 10:15:00'),
('Roberto Alves', '555.555.555-55', 'roberto.gestao@neuro.com', 'admin102', '(61) 98888-5555', '2026-01-07 11:00:00');

-- 9.2 Profissionais (10 registros)
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

-- 9.3 Pacientes (30 registros)
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

-- 9.4 Disponibilidades
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

-- 9.5 Intermediária Prof_Disponibilidade Relacionamentos
INSERT INTO prof_disponibilidade (profissional_id, disponibilidade_id) VALUES
(1,1), (1,2), (2,3), (2,4), (3,5), (3,6), (4,7), (4,8), (5,9), (5,10),
(6,11), (6,12), (7,13), (7,14), (8,15), (8,16), (9,17), (9,18), (10,19), (10,20),
(1,21), (2,22), (3,23), (4,24), (5,25), (6,26), (7,27), (8,28), (9,29), (10,30);

-- 9.6 Carga de Consultas Base (30 registros completos)
INSERT INTO consulta (paciente_id, profissional_id, administrador_id, data_hora, duracao_min, status, modalidade, comparecimento, observacoes, criado_em) VALUES
(1, 8, 1, '2026-06-01 09:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Retorno de rotina médica', '2026-05-31 09:00:00'),
(2, 3, 1, '2026-06-01 10:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Avaliação Neuropsicopedagógica', '2026-05-31 10:00:00'),
(3, 1, 2, '2026-06-02 14:00:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão psicopedagógica', '2026-06-01 08:00:00'),
(4, 7, 2, '2026-06-02 15:30:00', 50, 'Realizada', 'Presencial', 'Compareceu', 'Sessão com Psicólogo', '2026-06-01 09:15:00'),
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

-- 9.7 NOVA CARGA: Tabela Agenda (Preenchendo o Calendário do Figma)
INSERT INTO agenda (paciente_id, profissional_id, consulta_id, data_hora, status) VALUES
(1, 8, 1, '2026-06-01 09:00:00', 'Confirmada'),
(2, 3, 2, '2026-06-01 10:30:00', 'Confirmada'),
(3, 1, 3, '2026-06-02 14:00:00', 'Confirmada'),
(4, 7, 4, '2026-06-02 15:30:00', 'Confirmada'),
(5, 2, 5, '2026-06-03 08:30:00', 'Pendente'),
(6, 4, 6, '2026-06-03 10:00:00', 'Pendente'),
(7, 10, 7, '2026-06-04 11:00:00', 'Pendente'),
(8, 5, 8, '2026-06-04 16:00:00', 'Pendente'),
(9, 6, 9, '2026-06-05 09:30:00', 'Pendente'),
(10, 9, 10, '2026-06-05 14:30:00', 'Pendente'),
(11, 1, 11, '2026-06-08 09:00:00', 'Pendente'),
(12, 2, 12, '2026-06-08 10:00:00', 'Pendente'),
(13, 3, 13, '2026-06-09 14:00:00', 'Pendente'),
(14, 4, 14, '2026-06-09 15:00:00', 'Pendente'),
(15, 5, 15, '2026-06-10 08:00:00', 'Pendente'),
(16, 6, 16, '2026-06-10 11:00:00', 'Confirmada'),
(17, 7, 17, '2026-06-11 15:00:00', 'Confirmada'),
(18, 8, 18, '2026-06-11 16:00:00', 'Confirmada'),
(19, 9, 19, '2026-06-12 09:30:00', 'Confirmada'),
(20, 10, 20, '2026-06-12 10:30:00', 'Confirmada'),
(21, 1, 21, '2026-06-15 14:00:00', 'Confirmada'),
(22, 2, 22, '2026-06-15 15:30:00', 'Confirmada'),
(23, 3, 23, '2026-06-16 08:30:00', 'Confirmada'),
(24, 4, 24, '2026-06-16 10:00:00', 'Confirmada'),
(25, 5, 25, '2026-06-17 11:00:00', 'Confirmada'),
(26, 6, 26, '2026-06-17 16:00:00', 'Confirmada'),
(27, 7, 27, '2026-06-18 09:30:00', 'Confirmada'),
(28, 8, 28, '2026-06-18 14:30:00', 'Confirmada'),
(29, 9, 29, '2026-06-19 09:00:00', 'Confirmada'),
(30, 10, 30, '2026-06-19 10:00:00', 'Confirmada');

