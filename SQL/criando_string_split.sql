/*CRIANDO A FUNÇÃO STRING_SPLIT 
POR CONTA DO SQL 12 SER DESATUALIZADO E NAO TER A FUNÇÃO STRING_SPLIT */

ALTER FUNCTION [dbo].[fn_SplitTexto] 
( 
    @string NVARCHAR(MAX),    -- O texto completo que você quer quebrar (ex: o elenco)
    @delimitador CHAR(1)      -- O caractere que separa os itens (ex: a vírgula)
) 
RETURNS @resultado TABLE (value NVARCHAR(MAX)) -- A função devolve uma tabela com a coluna 'value'
AS 
BEGIN 
    -- 1. DECLARAÇÃO DA VARIÁVEL XML
    -- Usamos XML porque o SQL Server antigo não tem uma função de "quebrar texto" nativa eficiente.
    DECLARE @xml XML;

    -- 2. CONVERSÃO DO TEXTO EM ESTRUTURA XML
    -- O 'SELECT @string FOR XML PATH('')' limpa caracteres especiais (como o '&' de Sci-Fi & Fantasy).
    -- O 'REPLACE' troca a vírgula por tags XML </x><x>, criando blocos separados.
    -- No fim, o texto "A, B" vira "<x>A</x><x>B</x>".
    SET @xml = CAST('<x>' + REPLACE((SELECT @string FOR XML PATH('')), @delimitador, '</x><x>') + '</x>' AS XML);
    
    -- 3. INSERÇÃO DOS DADOS NA TABELA DE RETORNO
    INSERT INTO @resultado(value) 
    SELECT 
        -- LTRIM e RTRIM removem espaços vazios acidentais que sobram ao redor das palavras
        LTRIM(RTRIM(t.value('.', 'NVARCHAR(MAX)'))) 
    FROM @xml.nodes('/x') AS t(t); -- O comando .nodes('/x') fatia o XML e transforma cada tag <x> em uma linha de tabela

    RETURN; 
END