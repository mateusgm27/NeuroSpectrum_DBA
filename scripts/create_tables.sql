-- =============================================
-- NEUROSPECTRUM - Script de Criação do Banco
-- Desenvolvido por: Mateus (DBA) e Fernando
-- =============================================

-- 1. Tabela PACIENTE
CREATE TABLE paciente (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100)    NOT NULL,
    data_nascimento DATE            NOT NULL,
    cpf             VARCHAR(14)     NOT NULL UNIQUE,
    telefone        VARCHAR(20),
    email           VARCHAR(100),
    endereco        VARCHAR(200),
    convenio        VARCHAR(100),
    num_convenio    VARCHAR(50),
    data_cadastro   TIMESTAMP       DEFAULT NOW()
);

-- 2. Tabela PROFISSIONAL
CREATE TABLE profissional (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100)    NOT NULL,
    tipo            VARCHAR(50)     NOT NULL,
    crm_crp         VARCHAR(30)     NOT NULL UNIQUE,
    especialidade   VARCHAR(100),
    telefone        VARCHAR(20),
    email           VARCHAR(100),
    ativo           BOOLEAN         DEFAULT TRUE
);

-- 3. Tabela DISPONIBILIDADE
CREATE TABLE disponibilidade (
    id              SERIAL PRIMARY KEY,
    profissional_id INT          NOT NULL,
    dia_semana      VARCHAR(20)  NOT NULL,
    hora_inicio     TIME         NOT NULL,
    hora_fim        TIME         NOT NULL,
    ativo           BOOLEAN      DEFAULT TRUE,
    FOREIGN KEY (profissional_id) REFERENCES profissional(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. Tabela CONSULTA
CREATE TABLE consulta (
    id              SERIAL PRIMARY KEY,
    paciente_id     INT          NOT NULL,
    profissional_id INT          NOT NULL,
    data_hora       TIMESTAMP    NOT NULL,
    duracao_min     INT,
    status          VARCHAR(30)  DEFAULT 'agendada',
    modalidade      VARCHAR(30),
    observacoes     TEXT,
    criado_em       TIMESTAMP    DEFAULT NOW(),
    FOREIGN KEY (paciente_id)    REFERENCES paciente(id)    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (profissional_id) REFERENCES profissional(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 5. Tabela PRONTUARIO
CREATE TABLE prontuario (
    id               SERIAL PRIMARY KEY,
    paciente_id      INT       NOT NULL,
    profissional_id  INT       NOT NULL,
    consulta_id      INT,
    data_registro    TIMESTAMP DEFAULT NOW(),
    queixa_principal TEXT,
    avaliacao        TEXT,
    plano_tratamento TEXT,
    prescricao       TEXT,
    FOREIGN KEY (paciente_id)    REFERENCES paciente(id)    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (profissional_id) REFERENCES profissional(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consulta_id)    REFERENCES consulta(id)    ON DELETE SET NULL ON UPDATE CASCADE
);

-- 6. Tabela ALTERACAO_CONSULTA
CREATE TABLE alteracao_consulta (
    id                 SERIAL PRIMARY KEY,
    consulta_id        INT         NOT NULL,
    usuario_id         INT         NOT NULL,
    tipo_alteracao     VARCHAR(50) NOT NULL,
    data_hora_anterior TIMESTAMP,
    data_hora_nova     TIMESTAMP,
    motivo             TEXT,
    alterado_em        TIMESTAMP   DEFAULT NOW(),
    FOREIGN KEY (consulta_id) REFERENCES consulta(id)        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (usuario_id)  REFERENCES profissional(id)   ON DELETE RESTRICT ON UPDATE CASCADE
);

