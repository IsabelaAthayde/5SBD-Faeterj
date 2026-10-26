/*
Isabela de Oliveira Athayde 
Disciplina: 5SBD

ATIVIDADE PRÁTICA 5

-- Questão 1
-- Escreva uma instrução de inserção (`INSERT`) que tente registrar uma venda amarrada a um ID de cliente inexistente (ex: `9999`).
-- Execute o comando e analise qual constraint impediu o registro e qual regra comercial ela garante.
*/

INSERT INTO TB_VENDA (ID_VENDA, ID_CLIENTE, ID_VENDEDOR, STATUS, CANAL, VALOR_BRUTO, DESCONTO_TOTAL, VALOR_LIQUIDO)
VALUES (200, 99999,1,'ABERTA','APP',1000,200,800)

/*
ORA-02291: integrity constraint (WKSP_5SBDFAETERJ.FK_TB_VENDA_CLIENTE) violated - parent key not found
OU SEJA, A TABELA VENDA_CLIENTE AO TENTAR RELACIONAR OS DADOS,  NÃO ACHOU O ID_CLIENTE QUE ERA PRA ESTAR NA TABELA, ENTÃO NÃO FOI POSSÍVEL FINALIZAR O RELACIONAMENTO. JÁ QUE, SE O CLIENTE NÃO EXISTE ENTÃO ELE NÃO PODE COMPRAR.

**Questão 2: Violação de Domínio (CHECK Constraint)**
Escreva um comando de atualização (`UPDATE`) que tente alterar
o status de uma venda para o valor inválido `'PENDENTE'`.
Analise qual erro o banco retorna e por que essa validação deve
 residir no banco de dados e não apenas no aplicativo.
*/

UPDATE TB_VENDA SET STATUS = 'PENDENTE' WHERE ID_VENDA = 1
/*ORA-02290: check constraint (WKSP_5SBDFAETERJ.CK_TB_VENDA_STATUS) violated
A VALIDAÇÃO DEVE ESTAR NO BANCO PARA PODER GARANTIR QUE O VALOR INVÁLIDO NÃO VÁ SER INSERIDO OU ALTERADO, MESMO QUE O DADO VENHA DE OUTRO LUGAR.

**Questão 3: Impedindo Preços Absurdos**
Escreva uma instrução para inserir um novo produto na tabela
`tb_produto` informando um preço unitário negativo (ex: `-15.00`).
Teste e identifique qual constraint do modelo físico foi acionada
para blindar o sistema.
*/

INSERT INTO TB_PRODUTO VALUES (230, 3, 'PROD-MAC-01', 'MAC PC', -15.00, 'S', '5/10/2026')
/*
ORA-02290: check constraint (WKSP_5SBDFAETERJ.CK_TB_PRODUTO_PRECO) violated

Questão 4: Limite de Desconto de Itens (CHECK)**
Escreva um comando DDL (`ALTER TABLE`) para adicionar uma nova constraint
`CHECK` na tabela `tb_venda_item` que garanta, no nível do banco de dados,
que nenhum desconto unitário (`desconto_item`) concedido em uma venda possa
ultrapassar 50% do preço unitário cadastrado para o respectivo produto.
*/

ALTER TABLE TB_VENDA_ITEM
ADD CONSTRAINT DESC_ITEN_CT
CHECK (DESCONTO_ITEM <= (PRECO_UNIT/2))

/*
Error at line 2/16: ORA-02293: cannot validate (WKSP_5SBDFAETERJ.DESC_ITEN_CT) - check constraint violated
1. ALTER TABLE TB_VENDA_ITEM
2. ADD CONSTRAINT DESC_ITEN_CT
3. CHECK (DESCONTO_ITEM <= (PRECO_UNIT/2))

 **Questão 5: Garantia de Unicidade de Contato (UNIQUE)**

Escreva um comando DDL para adicionar uma restrição de unicidade (`UNIQUE`)
na coluna `telefone` da tabela `tb_cliente`, impedindo que dois clientes distintos
compartilhem acidentalmente o mesmo canal de contato no CRM.
*/

ALTER TABLE TB_CLIENTE
ADD UNIQUE(TELEFONE)

/*
*Questão 6: Exclusão em Cascata (ON DELETE CASCADE)**
Delete um registro de venda pai (`tb_venda`) que possua registros
filhos em `tb_venda_item`. Analise o comportamento automático do
banco de dados ao limpar os registros associados e discuta o perigo
 do uso indiscriminado dessa cláusula.
*/

DELETE FROM TB_VENDA
WHERE ID_VENDA = (SELECT ID_VENDA FROM TB_VENDA_ITEM FETCH FIRST 1 ROW ONLY)

/*
COM O ON DELETE CASCADE, SE EXCLUIR A VENDA PAI, OS DADOS
ASSOCIADOS A ELE EM TB_VENDA_ITEM TAMBÉM SERÃO EXCLUÍDOS AUTOMATICAMENTE.
POR ISSO, O ON DELETE CASCADE DEVE SER USADO COM CUIDADO.


**Questão 7: Exclusão Lógica (Soft Delete)**
Escreva um comando SQL para desativar logicamente
um vendedor que se desligou da empresa 
(atualizando a coluna `ativo` para `'N'`).
 Justifique por que essa técnica de exclusão lógica é preferível
 em relação à remoção física (`DELETE`) em
 bancos corporativos com histórico de faturamento.
*/

UPDATE TB_VENDEDOR
SET ATIVO = 'N'
WHERE ID_VENDEDOR = 1;

/*
A NÃO EXCLUSÃO É UTILIZADA PARA QUE SE MANTENHA UM HISTÓRICO,
 DESSA MANEIRA INFORMAÇÕES ANTIGAS COMO VENDEDORES INATIVOS E 
 SUAS VENDAS PODEM SER ACESSADOS A QUALQUER MOMENTO. SE O VENDEDOR FOSSE EXCLUÍDO,
  PODERIA ACABAR PERDENDO OU PREJUDICANDO O HISTÓRICO DAS VENDAS.
*/
