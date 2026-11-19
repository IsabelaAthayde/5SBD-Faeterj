--Atividade prática 12 - Procedures
--------------------------------------------------------------
--------------------------------------------------------------
/*
Exercício 1 (Procedure de Reajuste Salarial)
Crie uma procedure chamada prc_reajustar_saldo_em_massa que receba
como parâmetro de entrada o percentual de reajuste (p_percentual 
IN NUMBER) e retorne, em um parâmetro de saída (p_total_atualizado 
OUT NUMBER), a quantidade exata de contas com status 'ATIVA' que 
sofreram reajuste.
*/
/*Resposta:*/
CREATE OR REPLACE PROCEDURE PRC_REAJUSTAR_SALDO_EM_MASSA (P_PERCENTUAL IN  NUMBER, P_TOTAL_ATUALIZADO OUT NUMBER) IS
BEGIN
    UPDATE TB_CONTAS SET SALDO = SALDO + (SALDO * P_PERCENTUAL / 100) WHERE STATUS = 'ATIVA';
    P_TOTAL_ATUALIZADO := SQL%ROWCOUNT;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_TOTAL_ATUALIZADO := 0;
        RAISE;
END PRC_REAJUSTAR_SALDO_EM_MASSA;

/*
Exercício 2 (Bloqueio Concorrente com FOR UPDATE)
Explique tecnicamente a importância da cláusula FOR UPDATE utilizada 
na consulta de saldo da procedure prc_transferir_fundos. O que aconteceria 
em um ambiente corporativo com dezenas de transações simultâneas se 
essa cláusula fosse omitida?
*/
/*Resposta:
O for update trava a conta enquanto a transferência acontece. quando o programa 
consulta o saldo, o oracle segura aquela linha e ninguém mais mexe nela até 
terminar (commit ou rollback). Até mesmo quem tentar fica esperando na fila. Então,
sem ele o select só espia o saldo e não trava nada. Duas transferências podem ler o mesmo 
saldo ao mesmo tempo, ambas acham que tem dinheiro e ambas debitam. 
Por exemplo, com R$ 1000 na conta e duas transferências de R$ 650, a conta 
fica com -R$ 300. isso se chama condição de corrida (atualização perdida).
numa empresa com dezenas de transações juntas, isso geraria saldo errado, 
conta negativa indevida e extrato diferente do saldo real. com o for 
update, a segunda espera, lê o saldo já atualizado (R$ 350) e é recusada.
*/

/*
Exercício 3 (Manipulação de Parâmetros IN OUT)
Escreva uma procedure denominada prc_sanitizar_texto que utilize um único parâmetro 
bidirecional p_texto IN OUT VARCHAR2. A procedure deve remover espaços em branco 
sobressalentes nas extremidades (TRIM) e converter todos os caracteres para 
maiúsculas (UPPER).
*/
/*Resposta:*/
create or replace procedure prc_sanitizar_texto (p_texto in out varchar2) is
begin
    p_texto := upper(trim(p_texto));
end prc_sanitizar_texto;
