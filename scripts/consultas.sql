

SELECT 
    c.id,
    p.nome                  AS paciente,
    pr.nome                 AS profissional,
    c.data_hora,
    c.status,
    c.modalidade,
    c.duracao_min
FROM consulta c
JOIN paciente p     ON c.paciente_id = p.id
JOIN profissional pr ON c.profissional_id = pr.id
ORDER BY c.data_hora;

-- 5. Prontuários com detalhes
SELECT 
    pron.id,
    p.nome                  AS paciente,
    pr.nome                 AS profissional,
    pron.data_registro,
    pron.queixa_principal,
    pron.avaliacao,
    pron.plano_tratamento
FROM prontuario pron
JOIN paciente p     ON pron.paciente_id = p.id
JOIN profissional pr ON pron.profissional_id = pr.id
ORDER BY pron.data_registro DESC;

-- 6. Disponibilidade dos profissionais
SELECT 
    pr.nome             AS profissional,
    d.dia_semana,
    d.hora_inicio,
    d.hora_fim
FROM disponibilidade d
JOIN profissional pr ON d.profissional_id = pr.id
WHERE d.ativo = TRUE
ORDER BY pr.nome, d.dia_semana;

-- 7. Histórico de alterações de consultas
SELECT 
    ac.id,
    p.nome                    AS paciente,
    ac.tipo_alteracao,
    ac.data_hora_anterior,
    ac.data_hora_nova,
    ac.motivo,
    ac.alterado_em
FROM alteracao_consulta ac
JOIN consulta c ON ac.consulta_id = c.id
JOIN paciente p ON c.paciente_id = p.id
ORDER BY ac.alterado_em DESC;

-- 8. Quantidade de consultas por status
SELECT 
    status,
    COUNT(*) AS quantidade
FROM consulta 
GROUP BY status;
