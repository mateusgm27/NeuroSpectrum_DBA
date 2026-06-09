-- 1. Listagem Geral de Consultas (Mapeando Paciente, Profissional e Admin)
SELECT c.consulta_id AS id, p.nome AS paciente, pr.nome AS profissional,
a.nome AS recepcionista , c.data_hora,c.status AS status, c.modalidade AS modalidade
FROM consulta c
JOIN paciente p ON c.paciente_id = p.paciente_id
JOIN profissional pr ON c.profissional_id = pr.profissional_id
JOIN administrador a ON c.administrador_id = a.administrador_id
Order by c.data_hora;

-- 2. Prontuários com Detalhes Clínicos e Evolução do Paciente
SELECT pron.prontuario_id AS id, p.nome AS paciente, pro.profissional_id AS profissional,
pron.data_registro AS data_registro, pron.queixa_principal AS queixa_principal, pron.avaliacao
AS avaliacao
FROM prontuario pron
JOIN paciente p ON pron.paciente_id = p.paciente_id
JOIN profissional pro ON pron.profissional_id = pro.profissional_id
order by pron.data_registro DESC;

-- 3. Grade de Disponibilidade Ativa dos Profissionais de Saúde
SELECT pro.nome AS profissional , pro.especialidade AS especialidade
FROM prof_disponibilidade AS prof
JOIN profissional pro ON prof.profissional_id = pro.profissional_id
JOIN disponibilidade dispo ON prof.disponibilidade_id = dispo.disponibilidade_id
WHERE dispo.ativo = 1
ORDER BY pro.nome , dispo.dia_semana;

-- 4. Painel Estatístico: Quantidade de Consultas por Status
SELECT status AS 'status da consulta',
COUNT(*)  AS 'quantidade total'
FROM consulta
GROUP BY status;

-- 5 Relatório de Diagnósticos (CIDs) por Paciente
SELECT diag.descricao AS descricao, p.nome AS paciente, con.consulta_id AS consulta,
prof.nome AS profissional
FROM diagnostico diag
JOIN paciente p ON diag.paciente_id = p.paciente_id
JOIN consulta con ON diag.consulta_id = con.consulta_id
JOIN profissional prof ON con.profissional_id = prof.profissional_id
ORDER BY p.nome;

-- 6. Filtro de Pacientes por Convênio (Útil para faturamento da recepção)
SELECT nome FROM paciente
WHERE convenio != 'particular';


-- 7. Próximas Consultas Agendadas (Foco em gerenciamento futuro)
SELECT con.status AS status, con.data_hora AS 'data/hora', p.nome AS nome , prof.nome AS profissional
FROM consulta con
JOIN paciente p ON con.paciente_id = p.paciente_id
JOIN profissional prof ON con.profissional_id = prof.profissional_id
WHERE status = 'Agendada'
ORDER BY con.data_hora ASC;

-- 8. Listagem de Receitas Emitidas com Instruções de Medicamentos
SELECT r.receita_id AS id, r.instrucoes AS instrucoes,p.nome AS nome
FROM receita r
JOIN paciente p ON r.paciente_id = p.paciente_id
ORDER BY data_emissao DESC;

-- 9. Controle de Exames: Listar todos os exames que ainda estão 'Solicitado'
SELECT e.exame_id AS id, e.tipo_exame AS tipo_exame, p.nome AS nome
FROM exame e
JOIN paciente p ON e.paciente_id = p.paciente_id
WHERE status = 'Solicitado';

-- 10. Histórico de Tratamentos em Andamento
SELECT t.tratamento_id AS id, t.descricao AS descricao , p.nome AS nome
FROM tratamento t
JOIN paciente p ON t.paciente_id = p.paciente_id
WHERE t.status = 'Em andamento';

-- 11. Busca por Nome de Paciente Específico (Exemplo: Filtrando por 'Enzo')
SELECT paciente_id AS id,
nome AS nome,
DATE_FORMAT(data_nascimento, '%d/%m/%Y') AS 'data_nascimento',
telefone AS telefone,
endereco AS endereco
FROM paciente
WHERE nome LIKE '%Enzo%'
ORDER BY  nome;

-- 12. Total de Minutos de Atendimento Clínico por Profissional (Uso de SUM e GROUP BY)
SELECT SUM(c.consulta_id) AS id, SUM(c.duracao_min) AS duracao_consulta , p.nome AS nome
FROM consulta c 
JOIN profissional p ON c.profissional_id = p.profissional_id
WHERE c.status = 'Realizada'
GROUP BY p.nome , p.tipo;

-- 13. Média de Duração das Consultas por Modalidade (Uso de AVG)
SELECT AVG(duracao_min) FROM consulta
GROUP BY modalidade;

-- 14. Ranking de Profissionais com Mais Pacientes em Prontuário
SELECT prof.tipo AS especialidade , prof.nome AS nome,
COUNT(DISTINCT p.paciente_id) AS total_pacientes_unicos
FROM prontuario p
JOIN profissional prof ON p.profissional_id = prof.profissional_id
GROUP BY prof.nome, prof.tipo
ORDER BY total_pacientes_unicos;

-- 15.Exames Clínicos que já possuem Resultados Concluídos
SELECT 
    p.nome AS Paciente,
    e.tipo_exame AS Exame,
    e.resultado AS 'Resultado do Laudo',
    e.data_resultado AS 'Data de Conclusão'
FROM exame e
JOIN paciente p ON e.paciente_id = p.paciente_id
WHERE e.status = 'Concluido'
ORDER BY e.data_resultado DESC;




