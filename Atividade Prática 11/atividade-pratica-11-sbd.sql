--Atividade prática 11 - Synonyms
--------------------------------------------------------------
--------------------------------------------------------------
/*Exercício 1: Simulação de Ambiente Multi-Schema e Privilégios
Cenário: Explique e elabore o fluxo completo de comandos SQL e DCL necessários para que o usuário ANALISTA_BI 
consiga consultar a tabela EMPLOYEES pertencente ao schema HR, utilizando simplesmente a instrução SELECT * FROM func;*/

/*Resposta:
Primeiramente, o usuário HR ou um administrador deve conceder ao usuário ANALISTA_BI
o privilégio de consulta à tabela EMPLOYEES. Em seguida, conectado como ANALISTA_BI,
deve-se criar um sinônimo privado chamado FUNC, apontando para HR.EMPLOYEES.
Assim, será possível consultar a tabela utilizando apenas o nome do sinônimo.*/
GRANT SELECT ON hr.employees TO analista_bi;
CREATE SYNONYM func FOR hr.employees;
SELECT * FROM func;

/*Exercício 2: Ordem de Resolução de Nomes
Cenário: Considere que o usuário conectado possui em seu ambiente:
    Uma tabela física própria chamada PEDIDOS.
    Um sinônimo privado chamado PEDIDOS (apontando para FATURAMENTO.TB_PEDIDOS).
    Um sinônimo público chamado PEDIDOS (apontando para GLOBAL.TB_PEDIDOS).
Ao executar a consulta SELECT * FROM pedidos;, qual objeto será retornado pelo Oracle Database? 
Justifique com base nas regras de parsing.*/

/*Resposta: O resultado será a tabela PEDIDOS criada no próprio schema do usuário.
Mesmo existindo dois sinônimos com o mesmo nome, o Oracle utiliza primeiro
o objeto local. Por isso, os sinônimos de FATURAMENTO e GLOBAL são ignorados.*/

/*Exercício 3: Sinônimos Inválidos / Órfãos
Cenário: O que acontece com um sinônimo se o objeto subjacente para o qual ele 
aponta (ex: tabela base) for excluído com a instrução DROP TABLE? O sinônimo 
é removido automaticamente? O que ocorre ao tentar consultá-lo?*/

/*Resposta: Não. Mesmo que a tabela seja excluída, o sinônimo continua existindo no banco.
Porém, ele não consegue mais encontrar a tabela para a qual apontava.
Ao tentar fazer uma consulta por ele, o Oracle retorna o erro ORA-00942:
table or view does not exist.*/