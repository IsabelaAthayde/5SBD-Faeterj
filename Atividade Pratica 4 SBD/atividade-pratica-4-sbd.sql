/*Atividade Prática 04 - SQL para Análise de Dados

1- Jornada de Compras do Cliente: A equipe de CRM quer entender o comportamento de recompra dos clientes. 
Escreva uma consulta que liste o nome do cliente, a data da venda (dt_venda) e o valor líquido. 
Adicione uma coluna calculada chamada numero_compra utilizando a função ROW_NUMBER(). 
Essa coluna deve numerar cronologicamente as compras de cada cliente (a primeira compra do cliente recebe 1, a segunda 2, e assim por diante). 
Considere apenas vendas com status 'FECHADA'.
*/

SELECT C.NOME, VD.DT_VENDA, VD.VALOR_LIQUIDO, ROW_NUMBER() OVER(ORDER BY VD.DT_VENDA) AS NUMERO_COMPRA
FROM TB_VENDA VD JOIN TB_CLIENTE C USING(ID_CLIENTE)
WHERE VD.STATUS = 'FECHADA'
GROUP BY C.NOME, VD.DT_VENDA, VD.VALOR_LIQUIDO
ORDER BY C.NOME, VD.DT_VENDA;

/*2- Ranking Mensal de Vendedores: O RH precisa do pódio mensal de vendas. 
Crie uma consulta (você pode usar uma CTE antes para facilitar) que calcule o total vendido por cada vendedor em cada mês. 
Em seguida, adicione uma coluna chamada posicao_ranking utilizando a função DENSE_RANK(). 
O ranking deve ser reiniciado a cada mês (use PARTITION BY) e ordenado do maior para o menor faturamento.
*/
WITH VENDASCTE
AS
(
    SELECT 
    VDR.NOME, TO_CHAR(VD.DT_VENDA, 'MM/YYYY') MES_ANO, 
    SUM(VD.VALOR_LIQUIDO) TOTAL
    FROM TB_VENDA VD 
    JOIN TB_VENDEDOR VDR ON VD.ID_VENDEDOR = VDR.ID_VENDEDOR
    GROUP BY VDR.NOME, MES_ANO
)
SELECT 
NOME,
MES_ANO,
TOTAL,
DENSE_RANK() OVER (
        PARTITION BY MES_ANO
        ORDER BY TOTAL DESC
    ) AS POSICAO_RANKING
FROM VENDASCTE

/*3- Os 2 Produtos Mais Vendidos por Categoria: Descubra quais são os "carros-chefes" de cada categoria.
 Crie uma consulta que calcule a quantidade total vendida de cada produto. Usando DENSE_RANK() particionado por categoria, gere um ranking. 
 Na consulta final, filtre para exibir apenas os 2 primeiros colocados de cada categoria. 
 (Lembre-se: não é possível usar funções analíticas direto na cláusula WHERE, você precisará de uma subquery ou CTE).
*/
WITH ITEMCTE
AS
(
    SELECT 
    P.NOME, CT.NOME CATEGORIA, SUM(V_ITEM.QUANTIDADE) QTD_TOTAL,
    DENSE_RANK() OVER (
        PARTITION BY CT.NOME
        ORDER BY SUM(V_ITEM.QUANTIDADE) DESC
    ) AS POSICAO_RANKING
    FROM TB_VENDA_ITEM V_ITEM 
    JOIN TB_PRODUTO P ON P.ID_PRODUTO = V_ITEM.ID_PRODUTO
    JOIN TB_CATEGORIA CT ON P.ID_CATEGORIA = CT.ID_CATEGORIA
    GROUP BY P.NOME, CT.NOME
)
SELECT DISTINCT NOME, CATEGORIA, QTD_TOTAL, POSICAO_RANKING
FROM ITEMCTE
WHERE POSICAO_RANKING <=2;

/*4- Participação no Faturamento (Market Share Interno): A diretoria quer saber a fatia do bolo de cada vendedor. 
Calcule o faturamento total de cada vendedor (apenas vendas fechadas). 
Em uma coluna ao lado, mostre o percentual que esse valor representa em relação ao faturamento total da empresa. 
(Dica: Divida a receita do vendedor pela soma total usando SUM(receita) OVER() e multiplique por 100).
*/
SELECT 
    NOME,
    FATURAMENTO,
    ROUND(FATURAMENTO / SUM(FATURAMENTO) OVER() * 100, 2) || '%' AS PERCENTUAL
FROM
(
    SELECT 
        VDR.NOME,
        SUM(VD.VALOR_LIQUIDO) AS FATURAMENTO
    FROM TB_VENDA VD
    JOIN TB_VENDEDOR VDR 
        ON VD.ID_VENDEDOR = VDR.ID_VENDEDOR
    WHERE VD.STATUS = 'FECHADA'
    GROUP BY VDR.NOME
);

/*5- Termômetro de Vendas (Acima ou Abaixo da Média?): Liste o id_venda, o valor_liquido e crie duas colunas analíticas extras:
media_geral: A média de valor de todas as vendas da empresa.
diferenca_media: O valor líquido da venda menos a média geral .
*/

SELECT
ID_VENDA, 
VALOR_LIQUIDO,
MEDIA_GERAL,
ROUND(VALOR_LIQUIDO - MEDIA_GERAL, 2) AS DIFERENCA_MEDIA
FROM (
    SELECT 
    ID_VENDA,
    VALOR_LIQUIDO,
    ROUND(AVG(VALOR_LIQUIDO) OVER(),2) AS MEDIA_GERAL
    FROM TB_VENDA
)