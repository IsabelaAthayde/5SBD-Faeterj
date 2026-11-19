--Atividade prática 14 - Packages
--------------------------------------------------------------
--------------------------------------------------------------
/*Exercício 1 (Adição de Subprograma de Reposição): Adicione à especificação 
e ao corpo do pkg_gestao_vendas uma procedure pública chamada 
repor_estoque(p_id_produto IN NUMBER, p_quantidade IN NUMBER). A rotina deve 
validar se a quantidade é positiva e atualizar o saldo da tabela tb_prod_estoque.*/
/*Respostas, respectivamente a alteração da especificacao e do body:*/

/*PROCEDURE repor_estoque(p_id_produto IN NUMBER, p_quantidade IN NUMBER);*/
CREATE OR REPLACE PACKAGE pkg_gestao_vendas AS
    e_estoque_insuficiente EXCEPTION;
    FUNCTION verificar_disponibilidade(p_id_produto IN NUMBER, p_quantidade IN NUMBER) RETURN BOOLEAN;
    PROCEDURE realizar_venda(p_id_produto IN NUMBER, p_quantidade IN NUMBER, p_valor_final OUT NUMBER);
    PROCEDURE realizar_venda(p_id_produto IN NUMBER, p_quantidade IN NUMBER, p_desconto_pct IN NUMBER, p_valor_final OUT NUMBER);
    FUNCTION faturamento_diario RETURN NUMBER;
    PROCEDURE repor_estoque(p_id_produto IN NUMBER, p_quantidade IN NUMBER);
END pkg_gestao_vendas;
/

/*PROCEDURE repor_estoque(p_id_produto IN NUMBER, p_quantidade IN NUMBER) IS
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'A quantidade deve ser positiva.');
    END IF;

    UPDATE tb_prod_estoque SET qtd_estoque = qtd_estoque + p_quantidade WHERE id_produto = p_id_produto;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Produto não encontrado.');
    END IF;

    COMMIT;
END repor_estoque;*/
CREATE OR REPLACE PACKAGE BODY pkg_gestao_vendas AS

    /* ... outras coisas já que esse body do enunciado tem bastante coisa */

    PROCEDURE repor_estoque(p_id_produto IN NUMBER, p_quantidade IN NUMBER) IS
    BEGIN
        IF p_quantidade <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'A quantidade deve ser positiva.');
        END IF;

        UPDATE tb_prod_estoque
        SET qtd_estoque = qtd_estoque + p_quantidade
        WHERE id_produto = p_id_produto;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Produto não encontrado.');
        END IF;

        COMMIT;
    END repor_estoque;

    /* ... */

END pkg_gestao_vendas;


/*Exercício 2 (Análise de Dependências e Invalidação): Se você modificar a lógica 
interna de um procedimento dentro do PACKAGE BODY e recompilá-lo, os programas 
externos que chamam a especificação ficam inválidos? E se você alterar a assinatura 
de um procedimento na PACKAGE SPECIFICATION? Justifique tecnicamente com base no
 modelo de dependência do Oracle.*/
/*Resposta:

Não. Quando apenas a lógica interna do PACKAGE BODY é alterada, os programas que 
utilizam o pacote continuam funcionando normalmente, pois a parte pública não foi 
modificada. Porém, se a PACKAGE SPECIFICATION for alterada, os programas que 
dependem dela podem ficar inválidos e precisar de recompilação, pois houve mudança 
na forma como o pacote é utilizado.
*/

/*Exercício 3 (Variáveis Globais de Sessão): Adicione uma função pública no pacote 
chamada obter_total_vendas_sessao RETURN NUMBER que retorne o valor da variável de 
sessão g_total_vendas_sessao. Abra duas abas/sessões diferentes no APEX e analise 
se a contagem é compartilhada ou isolada por sessão.
*/
/*Resposta:*/
FUNCTION obter_total_vendas_sessao RETURN NUMBER;

FUNCTION obter_total_vendas_sessao RETURN NUMBER IS
BEGIN
    RETURN g_total_vendas_sessao;
END obter_total_vendas_sessao;

SELECT pkg_gestao_vendas.obter_total_vendas_sessao() FROM DUAL;

/*
analise: A contagem é separada por sessão. Isso significa que cada sessão 
possui seu próprio contador. Portanto, as vendas realizadas em uma aba não alteram
a contagem de outra sessão.
*/