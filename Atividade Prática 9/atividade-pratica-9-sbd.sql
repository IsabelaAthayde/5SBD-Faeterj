--Atividade prática 9 - Sequences
--------------------------------------------------------------
--------------------------------------------------------------
--Exercício 1: Sequence com Reinício (CYCLE)
/*Crie uma sequência chamada seq_ticket_diario com START WITH 1, INCREMENT BY 1, 
MINVALUE 1, MAXVALUE 5, CYCLE e CACHE 2. Execute chamadas sucessivas a NEXTVAL 
e documente o comportamento do sistema ao ultrapassar o valor 5.
*/

CREATE SEQUENCE SEQ_TICKET_DIARIO
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 5
CACHE 2
CYCLE;
    
SELECT SEQ_TICKET_DIARIO.NEXTVAL FROM DUAL;
SELECT SEQ_TICKET_DIARIO.NEXTVAL FROM DUAL;
SELECT SEQ_TICKET_DIARIO.NEXTVAL FROM DUAL;
SELECT SEQ_TICKET_DIARIO.NEXTVAL FROM DUAL;
SELECT SEQ_TICKET_DIARIO.NEXTVAL FROM DUAL;
SELECT SEQ_TICKET_DIARIO.NEXTVAL FROM DUAL;

/*Resposta: Quando a sequência chega no número 5, ela volta a começar
pelo número 1, pois foi criada com a opção CYCLE. Assim, depois de
chegar ao limite definido, ela não apresenta erro, apenas começa
a contagem denovo.
*/
--------------------------------------------------------------
--------------------------------------------------------------
--Exercício 2: Migração Trigger vs DEFAULT
/*Escreva um código demonstrando a atribuição clássica de uma sequência via Trigger 
BEFORE INSERT (padrão pré-Oracle 12c) e compare-o com a sintaxe moderna DEFAULT seq.NEXTVAL. 
Destaque as melhorias em termos de legibilidade, manutenção e performance de execução.
*/

CREATE SEQUENCE SEQ_FUNCIONARIO_ID START WITH 1 INCREMENT BY 1;

CREATE TABLE TB_FUNCIONARIOS_TRIGGER (
    ID_FUNCIONARIO NUMBER,
    NOME VARCHAR2(100),
    CONSTRAINT PK_FUNC_TRIGGER PRIMARY KEY (ID_FUNCIONARIO)
);

CREATE OR REPLACE TRIGGER TRG_FUNCIONARIO_ID
BEFORE INSERT ON TB_FUNCIONARIOS_TRIGGER FOR EACH ROW
BEGIN
    IF :NEW.ID_FUNCIONARIO IS NULL THEN
        :NEW.ID_FUNCIONARIO := SEQ_FUNCIONARIO_ID.NEXTVAL;
    END IF;
END;
/

CREATE SEQUENCE SEQ_FUNCIONARIO_DEFAULT START WITH 1 INCREMENT BY 1;

CREATE TABLE TB_FUNCIONARIOS_DEFAULT (
    ID_FUNCIONARIO NUMBER DEFAULT SEQ_FUNCIONARIO_DEFAULT.NEXTVAL,
    NOME VARCHAR2(100),
    CONSTRAINT PK_FUNC_DEFAULT PRIMARY KEY (ID_FUNCIONARIO)
);

/*Resposta: A diferença é que usando o DEFAULT não é preciso criar um trigger separado 
só para inserir o ID. A própria tabela já fica configurada para buscar o próximo número 
que tiver na sequência quando um novo insert for feito sem informar esse campo.
Já com o trigger, é preciso escrever um código a mais para fazer essa atribuição. 
Por isso, o DEFAULT é mais prático, pois deixa a estrutura mais simples e facilita ao ser
feito alguma alteração depois.
*/
--------------------------------------------------------------
--------------------------------------------------------------
--Exercício 3: Análise de Concorrência e CACHE
/*Explique os impactos arquiteturais da opção NOCACHE em um sistema de alta concorrência (OLTP), 
abordando a contenção na área de memória compartilhada (row cache lock na SGA) e os gargalos de 
I/O na atualização do dicionário de dados.
*/

/*Resposta: 
O NOCACHE pode acabar atrapalhando o desempenho quando há muitas pessoas usando o sistema ao mesmo 
tempo, pois os números não ficam guardados na memória para serem utilizados depois. Com isso, o 
Oracle precisa acessar as informações da sequência com mais frequência, o que pode causar uma 
disputa entre as sessões pelo acesso a esses dados (row cache lock). Também podem ocorrer mais 
operações relacionadas ao dicionário de dados, aumentando o tempo das inserções.
Por isso, em sistemas que possuem muitas operações ao mesmo tempo, o CACHE acaba sendo uma opção 
melhor para evitar esse tipo de problema.
*/