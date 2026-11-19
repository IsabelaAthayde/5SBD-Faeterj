--Atividade prática 13 - Funções
--------------------------------------------------------------
--------------------------------------------------------------
/*Exercício 1 (Função de Tempo de Casa em Anos): Crie uma função chamada fnc_calcular_tempo_casa que 
receba p_data_admissao IN DATE e retorne um NUMBER representando a quantidade de anos completos 
trabalhados pelo colaborador.
Dica: Utilize as funções nativas MONTHS_BETWEEN(SYSDATE, p_data_admissao) e FLOOR().*/
/*Resposta: */
CREATE OR REPLACE FUNCTION FNC_CALCULAR_TEMPO_CASA (P_DATA_ADMISSAO IN DATE) RETURN NUMBER
IS
BEGIN
    RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, P_DATA_ADMISSAO) / 12);
END FNC_CALCULAR_TEMPO_CASA;
/

SELECT NOME, DATA_ADMISSAO, FNC_CALCULAR_TEMPO_CASA(DATA_ADMISSAO) AS ANOS_TRABALHADOS FROM TB_COLABORADORES;

/*Exercício 2 (Violação de Pureza e Erro ORA-14551): Crie uma função experimental que tente executar 
um comando UPDATE na tabela tb_colaboradores antes de retornar um valor numérico. Tente executá-la 
através do comando SELECT fnc_teste_dml() FROM DUAL;. Documente a ocorrência da exceção 
ORA-14551: cannot perform a DML operation inside a query.*/
/*Resposta: 
Ocorre esse erro porque a função tenta alterar um registro da tabela 
usando UPDATE enquanto está sendo chamada por um SELECT. Nesse caso, o Oracle 
não permite executar essa alteração dentro da consulta.*/

CREATE OR REPLACE FUNCTION FNC_TESTE_DML RETURN NUMBER
IS BEGIN
    UPDATE TB_COLABORADORES SET SALARIO_BASE = SALARIO_BASE + 1 WHERE ID_COLABORADOR = 1;
    RETURN 1;
END FNC_TESTE_DML;
/

SELECT FNC_TESTE_DML() FROM DUAL;

/*Exercício 3 (Otimização com DETERMINISTIC): Crie um Function-Based Index (FBI) na tabela 
tb_colaboradores baseado na função fnc_calcular_irrf(salario_base). Utilize o recurso 
explain Plan do APEX para comparar o custo de execução da consulta antes e depois do índice.*/
CREATE INDEX IDX_IRRF_COLABORADORES ON TB_COLABORADORES (FNC_CALCULAR_IRRF(SALARIO_BASE));
/*Resposta: 
O índice foi criado com sucesso utilizando a função FNC_CALCULAR_IRRF(SALARIO_BASE). 
Antes da criação do índice, o Oracle precisou verificar todos os registros da tabela, 
e depois passou a utilizar o índice para encontrar os resultados, reduzindo o custo da 
consulta de 5 para 3. Isso mostrou também que o índice ajudou a melhorar a execução da consulta.
*/