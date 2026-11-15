--Atividade prática 10 - Indexação
--------------------------------------------------------------
--------------------------------------------------------------
---Exercício 1 (Métodos Construtores Personalizados)
/*Crie um tipo de objeto chamado `t_retangulo` com os atributos `largura` (NUMBER) 
e `altura` (NUMBER). Adicione duas funções ao tipo: `MEMBER FUNCTION calcular_area 
RETURN NUMBER` e `MEMBER FUNCTION calcular_perimetro RETURN NUMBER`. 
Escreva a especificação, o corpo (`BODY`) e execute um bloco anônimo PL/SQL ou 
comando `SELECT` para testar a instanciação e o cálculo das funções.*/
/*
Resposta:
*/
CREATE OR REPLACE TYPE t_retangulo AS OBJECT (
    largura NUMBER,
    altura NUMBER,
    MEMBER FUNCTION calcular_area RETURN NUMBER,
    MEMBER FUNCTION calcular_perimetro RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY t_retangulo AS
    MEMBER FUNCTION calcular_area RETURN NUMBER IS
    BEGIN
        RETURN largura * altura;
    END;

    MEMBER FUNCTION calcular_perimetro RETURN NUMBER IS
    BEGIN
        RETURN (largura * 2) + (altura * 2);
    END;
END;

---Exercício 2 (Método MAP para Ordenação)
/*
Modifique a especificação e o corpo do tipo `t_retangulo` criado no Exercício 1 
para incluir um método `MAP MEMBER FUNCTION ordenar RETURN NUMBER`. A função deve 
retornar a área total do retângulo. 

Teste a ordenação criando uma tabela simples 
de retângulos e executando uma consulta com a cláusula `ORDER BY` diretamente 
sobre a coluna do tipo objeto.
*/

/*
Respostas:
*/
CREATE OR REPLACE TYPE t_retangulo AS OBJECT (
    largura NUMBER,
    altura NUMBER,
    MEMBER FUNCTION calcular_area RETURN NUMBER,
    MEMBER FUNCTION calcular_perimetro RETURN NUMBER,
    MAP MEMBER FUNCTION ordenar RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY t_retangulo AS
    MEMBER FUNCTION calcular_area RETURN NUMBER IS
    BEGIN
        RETURN largura * altura;
    END;

    MEMBER FUNCTION calcular_perimetro RETURN NUMBER IS
    BEGIN
        RETURN (largura * 2) + (altura * 2);
    END;

    MAP MEMBER FUNCTION ordenar RETURN NUMBER IS
    BEGIN
        RETURN largura * altura;
    END;
END;

CREATE TABLE tb_retangulos (
    id_retangulo NUMBER PRIMARY KEY,
    retangulo t_retangulo
);
INSERT INTO tb_retangulos VALUES (1, t_retangulo(10, 5));
INSERT INTO tb_retangulos VALUES (2, t_retangulo(4, 3));
INSERT INTO tb_retangulos VALUES (3, t_retangulo(8, 6));
INSERT INTO tb_retangulos VALUES (4, t_retangulo(2, 2));

SELECT t.id_retangulo, t.retangulo.largura AS largura, t.retangulo.altura AS altura, t.retangulo.calcular_area() AS area
FROM tb_retangulos t 
ORDER BY t.retangulo;

---Exercício 3 (Análise Crítica de Engenharia)
/*Considere o cenário de modelagem de dados para um sistema corporativo. Elabore um texto 
comparativo analisando o uso de `Nested Tables` como colunas versus a modelagem relacional 
tradicional (duas tabelas distintas vinculadas por Foreign Key de 1:N). Enderece em sua resposta:
   * Flexibilidade de consulta SQL.
   * Manutenção de integridade referencial.
   * Suporte por ferramentas de integração/ORM.
   * Performance em cargas massivas (ETL).
*/
/*
Resposta:

Nas Nested Tables, vários dados ficam guardados dentro de uma coluna da tabela principal, o 
que pode dificultar as consultas e alterações, na qual podem exigir configurações específicas 
das ferramentas ORM e gerar mais trabalho ao acessar e atualizar os dados em ETL. Já no modelo 
tradicional, os dados ficam em duas tabelas separadas, ligadas por uma chave estrangeira em um 
relacionamento como 1:N, facilitando as consultas. Além disso, esse modelo costuma ter maior 
compatibilidade com ferramentas ORM e facilitar cargas de muitos dados em ETL. Por isso, o modelo 
tradicional geralmente é mais simples de utilizar e manter em sistemas corporativos,
enquanto as Nested Tables são melhores em casos específicos de agrupamento de dados em estruturas hierárquicas
*/

