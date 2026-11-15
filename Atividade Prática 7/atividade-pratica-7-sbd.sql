--Atividade prática 7 - Materialized Views
--------------------------------------------------------------
--------------------------------------------------------------
/*Exercício 1: 
Crie uma Materialized View chamada mv_vendas_categoria agrupando 
o faturamento total e quantidade de vendas por categoria de produto 
(requer JOIN entre tb_vendas e tb_produtos). 
Configure-a com REFRESH COMPLETE ON DEMAND.*/
/*
Resposta:
*/
CREATE MATERIALIZED VIEW MV_VENDAS_CATEGORIA
REFRESH COMPLETE ON DEMAND
BUILD IMMEDIATE
AS
SELECT PR.CATEGORIA, SUM(VD.VALOR_TOTAL) FATURAMENTO_TOTAL, SUM(VD.QUANTIDADE) TOTAL_VENDIDO
FROM TB_VENDAS VD
JOIN TB_PRODUTOS PR ON VD.ID_PRODUTO = PR.ID_PRODUTO
GROUP BY PR.CATEGORIA;

SELECT CATEGORIA, FATURAMENTO_TOTAL, TOTAL_VENDIDO
FROM MV_VENDAS_CATEGORIA
ORDER BY CATEGORIA;

/*Exercício 2: Altere o modo de atualização de uma visão materializada para 
ON COMMIT em um ambiente de desenvolvimento local. Teste a inserção de novos 
registros com COMMIT e analise as implicações em termos de retenção de locks 
transacionais e tempo de resposta.*/
/*
Resposta sql:
*/
ALTER MATERIALIZED VIEW MV_VENDAS_POR_PRODUTO REFRESH COMPLETE ON COMMIT;
INSERT INTO TB_VENDAS (ID_PRODUTO, QUANTIDADE, VALOR_TOTAL) VALUES (2, 3, 3600.00);
COMMIT;
SELECT * FROM MV_VENDAS_POR_PRODUTO WHERE ID_PRODUTO = 2;

/*Resposta de analise: Com o modo do ON COMMIT, a Materialized View é atualizada automaticamente 
sempre que há a confirmação de uma transação. Isso ajuda manter os dados atualizados, 
mas também pode fazer o COMMIT demorar um pouco mais, já que o banco precisa 
atualizar a view antes de finalizar a operação. E com isso, os locks transacionais 
podem ficar ativos por mais tempo, o que pode atrapalhar outras operações que 
estejam acontecendo ao mesmo tempo.*/

/*Exercício 3: Inspecione o dicionário de dados do Oracle para verificar o 
status e metadados das MViews e Logs criados no seu schema:*/
/*
Resposta:
*/
SELECT MVIEW_NAME, BUILD_MODE, REFRESH_MODE, REFRESH_METHOD, STALENESS, LAST_REFRESH_DATEFROM USER_MVIEWS;
SELECT MASTER, LOG_TABLE, ROWS_IN_MVIEWFROM USER_MVIEW_LOGS;