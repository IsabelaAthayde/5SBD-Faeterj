--Atividade prática 8 - Indexação
--------------------------------------------------------------
--------------------------------------------------------------
--Exercício 1 (Seletividade e Leading Column)
/*
Enunciado: Execute a consulta abaixo no Oracle APEX e inspecione o plano de execução gerado via botão Explain Plan:

SELECT nome, salario
FROM tb_funcionarios
WHERE cargo = 'ANALISTA';

Pergunta: Explique detalhadamente por que o índice
composto idx_func_dep_cargo_sal (criado na Etapa 5) não gerou um INDEX RANGE SCAN
direto e eficiente nesta instrução, e como a regra da Leading Column (coluna líder)
fundamenta esse comportamento do otimizador Oracle.*/

/*Resposta: 
A restrição presente na clausula WHERE em "WHERE cargo = 'ANALISTA'" utiliza somente 
a coluna cargo, na qual a prioridade do index "idx_func_dep_cargo_sal" segue a ordem: 
departamento > cargo > salario. Como a coluna lider e com prioridade no indice é 
departamento e ela não foi informada, o oracle não consegue fazer diretamente um 
"INDEX RANGE SCAN" pela coluna cargo, onde o indice está organizado primeiro pelos 
departamentos e depois pelos cargos dentro de cada um. 
Dessa maneira, ele tem que fazer a busca dos cargos de analistas existentes dentro 
dos diferentes departamentos para encontrar o que precisa, o que pode gerar uma perda 
de eficiência. Além disso, a query seleciona a coluna nome, que não está no índice 
desse exercício. Ou seja, para concluir a instrução, ele ainda teria que fazer leituras 
adicionais, acessando a tabela novamente para conseguir os nomes dos funcionários, 
aumentando o tempo de execução.
Assim, a regra da Leading Column explica esse comportamento porque o Oracle dá prioridade 
à primeira coluna do índice na hora de organizar e buscar os dados. Como ela não foi 
informada na consulta, a busca acaba sendo menos direta, fazendo com que o otimizador 
avalie qual modo de execução é o mais eficiente.
*/
--------------------------------------------------------------
--------------------------------------------------------------
--Exercício 2 (Indexação Temporal)
/*Enunciado: Suponha uma demanda em que o relatório de auditoria fiscal realiza consultas frequentes 
buscando funcionários admitidos em um determinado ano, utilizando a sintaxe:

SELECT * 
FROM tb_funcionarios 
WHERE EXTRACT(YEAR FROM data_admissao) = 2022;

Tarefa: Escreva a instrução SQL completa DDL para criar um Function-Based Index 
apropriado para essa consulta e apresente a sintaxe SQL de validação utilizando 
o Dicionário de Dados do Oracle (USER_INDEXES).
*/

/*
Resposta:
*/
CREATE INDEX idx_func_ano_admissao
ON tb_funcionarios(EXTRACT(YEAR FROM data_admissao));

SELECT index_name, index_type, status
FROM user_indexes
WHERE index_name = 'IDX_FUNC_ANO_ADMISSAO';


--------------------------------------------------------------
--------------------------------------------------------------
--Exercício 3 (Análise Crítica de Trade-offs)
/*
Enunciado: Um desenvolvedor júnior propôs a criação de índices individuais 
para todas as colunas da tabela tb_funcionarios com o objetivo de "garantir 
que nenhuma consulta do sistema fique lenta".

Tarefa: Elabore uma justificativa técnica (mínimo de 2 parágrafos) 
desconstruindo essa abordagem para a equipe de arquitetura. Aborde os 
impactos físicos e de infraestrutura nos seguintes tópicos:
*/

/*
Resposta:
A criação de índices individuais em todas as colunas da tabela não garante que as consultas 
fiquem mais rápidas, porque os índices também geram custos para o banco de dados.

No item 1, em cada INSERT, além de inserir o registro na tabela, o Oracle também precisa 
adicionar as informações em todos os índices existentes. Por exemplo, com 10.000 inserções, 
cada uma das estruturas dos índices também é atualizada. No UPDATE, quando uma coluna que 
possui índice é editada, o índice dela também precisa ser atualizado. Já no DELETE, além de 
remover a informação da tabela, o Oracle precisa deletar as informações de cada um dos índices. 
Ou seja, quanto mais índices, mais trabalho o banco tem nessas operações, e isso prejudica o desempenho.

No item 2, quanto mais índices existirem, maior será o gasto de espaço em disco, já que cada 
um precisa guardar suas próprias informações. Os índices também usam o Buffer Cache, que é a 
memória onde o Oracle guarda os dados que está usando, e isso aumenta o gasto. Dependendo da 
capacidade total, muitos índices podem deixar a memória perto do limite. E essa memória poderia 
estar sendo usada para coisas mais importantes para o banco.

no item 3, mesmo que tenha muitos índices, nem sempre todos vai ser usados. Como o otimizador sempre calcula 
a forma mais eficiente de realizar suas consultas, dependendo da quantidade de índices e de dados, ele pode 
decidir usar FULL TABLE SCAN, ao inves dos índices criados, por exemplo quando a consulta retorna uma grande 
parte da tabela. Então muitos índices podem atrapalhar um sistema que poderia estar tendo um melhor desempenho 
se tivesse menos índices, gerando gastos desnecessários e que não beneficiam nas consultas.
*/