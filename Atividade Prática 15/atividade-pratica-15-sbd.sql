--Atividade prática 15 - Trigger
--------------------------------------------------------------
--------------------------------------------------------------
/*Exercício 1 (Trigger INSTEAD OF): 
Crie uma View complexa com junção (JOIN) ou agregações 
e construa uma Trigger INSTEAD OF INSERT que intercepte a tentativa de inserção na view e 
direcione as colunas corretas para as tabelas subjacentes correspondentes.*/
/*Resposta:*/
CREATE OR REPLACE VIEW VW_EMPREGADOS_RESUMO AS
SELECT CARGO, COUNT(*) TOTAL_EMPREGADOS, AVG(SALARIO) MEDIA_SALARIAL
FROM TB_EMPREGADOS
GROUP BY CARGO;

CREATE OR REPLACE TRIGGER TRG_VW_EMPREGADOS_INSERT
INSTEAD OF INSERT ON VW_EMPREGADOS_RESUMO
FOR EACH ROW
BEGIN
    INSERT INTO TB_EMPREGADOS(NOME, CARGO, SALARIO) VALUES('NOVO EMPREGADO', :NEW.CARGO, :NEW.MEDIA_SALARIAL);
END TRG_VW_EMPREGADOS_INSERT;

INSERT INTO VW_EMPREGADOS_RESUMO(CARGO, TOTAL_EMPREGADOS, MEDIA_SALARIAL) VALUES('ANALISTA DE SISTEMAS', 1, 5000);
SELECT * FROM TB_EMPREGADOS;

/*Exercício 2 (Simulação de Mutating Table - ORA-04091): 
Crie um trigger AFTER INSERT OR 
UPDATE ON tb_empregados FOR EACH ROW que tente executar SELECT COUNT(*) FROM tb_empregados 
WHERE cargo = :NEW.cargo. Tente fazer uma alteração de dados, observe o erro ORA-04091: 
table is mutating e explique por que o Oracle impede essa leitura concorrente.*/

/*Resposta: O erro ORA-04091 acontece porque o trigger tenta consultar a tabela TB_EMPREGADOS 
enquanto ela ainda está sendo alterada. O Oracle impede essa consulta para evitar problemas 
durante a atualização dos dados.*/

CREATE OR REPLACE TRIGGER TRG_EMPREGADOS_MUTATING
AFTER INSERT OR UPDATE ON TB_EMPREGADOS
FOR EACH ROW
DECLARE
    V_TOTAL NUMBER;
BEGIN
    SELECT COUNT(*) INTO V_TOTAL FROM TB_EMPREGADOS WHERE CARGO = :NEW.CARGO;
END TRG_EMPREGADOS_MUTATING;

UPDATE TB_EMPREGADOS SET CARGO = 'ANALISTA DE SISTEMAS' WHERE ID_EMPREGADO = 1;


/*Exercício 3 (Cláusula WHEN):
Modifique o gatilho de auditoria salarial utilizando a 
cláusula WHEN (NEW.salario <> OLD.salario) na própria definição do cabeçalho do trigger, 
explicando a economia de processamento em relação a fazer a checagem com IF dentro do 
corpo PL/SQL.*/

/*Resposta: A cláusula WHEN verifica se o salário foi alterado antes de executar o corpo do 
trigger. Assim, o registro na tabela de auditoria só acontece quando existe uma mudança no salário, 
evitando executar etapas desnecessárias.*/

CREATE OR REPLACE TRIGGER TRG_EMPREGADOS_AUDITORIA
AFTER UPDATE ON TB_EMPREGADOS
FOR EACH ROW
WHEN (NEW.SALARIO <> OLD.SALARIO)
BEGIN
    INSERT INTO TB_AUDITORIA_SALARIOS(ID_EMPREGADO, OPERACAO, SALARIO_ANTERIOR, SALARIO_NOVO) VALUES(:OLD.ID_EMPREGADO, 'UPDATE', :OLD.SALARIO, :NEW.SALARIO);
END TRG_EMPREGADOS_AUDITORIA;

UPDATE TB_EMPREGADOS SET SALARIO = 11000 WHERE ID_EMPREGADO = 2;
SELECT * FROM TB_AUDITORIA_SALARIOS ORDER BY ID_AUDIT;
