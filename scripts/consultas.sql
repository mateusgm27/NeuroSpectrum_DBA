-- =============================================================================
--  PRINCIPAIS CONSULTAS E RELATÓRIOS (DML - SELECTs)
-- =============================================================================

-- SELECT 1: Listagem da Visão Geral da Agenda 
-- Descrição: Traz a visão limpa do calendário unindo os nomes de pacientes e profissionais.
SELECT a.agenda_id AS id, p.nome AS paciente_nome, pr.nome AS profissional_nome, a.data_hora, a.status
FROM agenda a
INNER JOIN paciente p ON a.paciente_id = p.paciente_id
INNER JOIN profissional pr ON a.profissional_id = pr.profissional_id
ORDER BY a.data_hora;

-- SELECT 2: Listagem Detalhada de Consultas (Paciente + Profissional + Admin)
-- Descrição: Relatório completo mapeando quem agendou, qual recepcionista atendeu e o formato.
SELECT c.consulta_id AS id, p.nome AS paciente, pr.nome AS profissional,
a.nome AS recepcionista , c.data_hora, c.status AS status, c.modalidade AS modalidade
FROM consulta c
JOIN paciente p ON c.paciente_id = p.paciente_id
JOIN profissional pr ON c.profissional_id = pr.profissional_id
JOIN administrador a ON c.administrador_id = a.administrador_id
ORDER BY c.data_hora;

-- SELECT 3: Grade de Disponibilidade Ativa dos Profissionais de Saúde
-- Descrição: Útil para a secretaria verificar os dias e períodos que os profissionais atendem.
SELECT pro.nome AS profissional , pro.especialidade AS especialidade, dispo.dia_semana, dispo.periodo
FROM prof_disponibilidade AS prof
JOIN profissional pro ON prof.profissional_id = pro.profissional_id
JOIN disponibilidade dispo ON prof.disponibilidade_id = dispo.disponibilidade_id
WHERE dispo.ativo = 1
ORDER BY pro.nome, dispo.dia_semana;

-- SELECT 4: Painel Estatístico: Quantidade de Consultas por Status
-- Descrição: Agrupamento numérico para gerar gráficos gerenciais de produtividade da clínica.
SELECT status AS 'status da consulta', COUNT(*) AS 'quantidade total'
FROM consulta
GROUP BY status;

-- SELECT 5: Filtro de Pacientes com Convênio Ativo (Faturamento da Recepção)
-- Descrição: Filtra todos os pacientes que não são particulares para envio de guias médicas.
SELECT nome, convenio, num_convenio FROM paciente WHERE convenio != 'Particular';

-- SELECT 6: Busca por Nome de Paciente Específico (Filtro Dinâmico com LIKE)
-- Descrição: Pesquisa rápida utilizada na barra de busca das telas da secretaria.
SELECT paciente_id AS id, nome, telefone, endereco FROM paciente WHERE nome LIKE '%Enzo%';

-- SELECT 7: Total de Minutos de Atendimento Clínico por Profissional (Uso de SUM)
-- Descrição: Mapeia o total de tempo que cada profissional passou em consulta com status 'Realizada'.
SELECT p.nome AS nome, COUNT(c.consulta_id) AS total_consultas, SUM(c.duracao_min) AS total_minutos
FROM consulta c 
JOIN profissional p ON c.profissional_id = p.profissional_id
WHERE c.status = 'Realizada'
GROUP BY p.nome
ORDER BY total_minutos DESC;

-- SELECT 8: Média de Duração das Consultas por Modalidade (Uso de AVG)
-- Descrição: Analisa se as consultas presenciais duram mais ou menos que as online.
SELECT modalidade, AVG(duracao_min) AS media_minutos FROM consulta GROUP BY modalidade;

-- SELECT 9: Ranking de Profissionais Mais Requisitados (Foco em Agendamentos)
-- Descrição: Mostra quais profissionais possuem mais consultas registradas no sistema (atendimentos totais).
SELECT pr.nome AS profissional, pr.tipo AS especialidade, COUNT(c.consulta_id) AS total_agendamentos
FROM consulta c
JOIN profissional pr ON c.profissional_id = pr.profissional_id
GROUP BY pr.nome, pr.tipo
ORDER BY total_agendamentos DESC;

-- SELECT 10: Próximas Consultas Agendadas Futuras (Painel de Alertas)
-- Descrição: Filtra apenas consultas com status 'Agendada' ordenando cronologicamente pelas mais próximas.
SELECT con.data_hora AS 'Data/Hora', p.nome AS paciente, prof.nome AS profissional, con.modalidade
FROM consulta con
JOIN paciente p ON con.paciente_id = p.paciente_id
JOIN profissional prof ON con.profissional_id = prof.profissional_id
WHERE con.status = 'Agendada'
ORDER BY con.data_hora ASC;

-- SELECT 11: Controle de Faltas e Abandono (Comparecimento Pendente ou Faltas)
-- Descrição: Lista consultas realizadas onde o status de comparecimento precisa de atenção ou auditoria.
SELECT c.consulta_id AS id, p.nome AS paciente, pr.nome AS profissional, c.data_hora, c.comparecimento
FROM consulta c
JOIN paciente p ON c.paciente_id = p.paciente_id
JOIN profissional pr ON c.profissional_id = pr.profissional_id
WHERE c.comparecimento = 'Pendente' AND c.status = 'Realizada';

-- SELECT 12: Produtividade Mensal da Recepção (Ações por Administrador)
-- Descrição: Conta quantas consultas cada recepcionista/administrador agendou no sistema.
SELECT a.nome AS recepcionista, COUNT(c.consulta_id) AS consultas_agendadas
FROM consulta c
JOIN administrador a ON c.administrador_id = a.administrador_id
GROUP BY a.nome
ORDER BY consultas_agendadas DESC;

-- SELECT 13: Média de Idade dos Pacientes Atendidos por Profissional (Uso de AVG e TIMESTAMPDIFF)
-- Descrição: Calcula a média de idade dos pacientes vinculados às consultas de cada profissional.
SELECT pr.nome AS profissional, pr.tipo AS especialidade, 
       ROUND(AVG(TIMESTAMPDIFF(YEAR, p.data_nascimento, con.data_hora)), 1) AS media_idade_pacientes
FROM consulta con
JOIN paciente p ON con.paciente_id = p.paciente_id
JOIN profissional pr ON con.profissional_id = pr.profissional_id
GROUP BY pr.nome, pr.tipo
ORDER BY media_idade_pacientes ASC;

-- SELECT 14: Relatório Estatístico de Agendamentos da Semana por Período
-- Descrição: Cruza a tabela de disponibilidade com a agenda para identificar picos de atendimento (Manhã vs Tarde).
SELECT d.periodo, COUNT(c.consulta_id) AS total_consultas_no_periodo
FROM consulta c
JOIN profissional pr ON c.profissional_id = pr.profissional_id
JOIN prof_disponibilidade pd ON pr.profissional_id = pd.profissional_id
JOIN disponibilidade d ON pd.disponibilidade_id = d.disponibilidade_id
GROUP BY d.periodo;

-- SELECT 15: Histórico de Consultas Canceladas com Observações preenchidas
-- Descrição: Permite mapear os motivos de cancelamento informados pela secretaria nas observações textuais.
SELECT c.consulta_id AS id, p.nome AS paciente, pr.nome AS profissional, c.data_hora, c.observacoes
FROM consulta c
JOIN paciente p ON c.paciente_id = p.paciente_id
JOIN profissional pr ON c.profissional_id = pr.profissional_id
WHERE c.status = 'Cancelada';

-- =============================================================================
-- 11. TESTES DE VALIDAÇÃO DA PROCEDURE (PGSQL / PROCEDURAL)
-- =============================================================================
-- Execute uma linha por vez para testar os fluxos automáticos do IF/ELSE:

 CALL AgendarConsulta(1, 2, 1, '2026-06-25 14:00:00', 50, 'Presencial', 'Sessão de teste otimizada');
 CALL AgendarConsulta(1, 2, 1, '2026-06-25 14:00:00', 50, 'Presencial', 'Tentando duplicar o horário');




