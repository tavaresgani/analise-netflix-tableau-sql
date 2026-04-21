/*
===========================================================
PROJETO: Análise de Dados da Netflix
AUTORA: Gabriela Tavares
OBJETIVO:
Analisar padrões de conteúdo da Netflix com foco em:
- Crescimento da plataforma
- Distribuição de conteúdo
- Participação do Brasil
===========================================================
*/



-- =========================================
-- 1. VISÃO GERAL DOS DADOS
-- =========================================
SELECT TOP 10* from dbo.netflix_final;


-- =========================================
-- 2. FILMES VS SÉRIES
-- =========================================
SELECT 
	type,
	COUNT(*) AS TOTAL 
FROM dbo.netflix_final
GROUP BY type;


-- =========================================
-- 3. CRESCIMENTO AO LONGO DOS ANOS
-- =========================================
SELECT 
	release_year,
	COUNT(*) AS total_lancamentos
FROM dbo.netflix_final
GROUP BY release_year
ORDER BY release_year;


-- =========================================
-- 4. TOP PAÍSES (COM FOCO NO BRASIL)
-- =========================================
SELECT TOP 10
	country,
	COUNT(*) AS TOTAL
FROM dbo.netflix_final
WHERE country IS NOT NULL
GROUP BY country
ORDER BY TOTAL DESC;

-- Conteúdo do Brasil ao longo do tempo
SELECT
	release_year,
	COUNT(*) AS TOTAL
FROM dbo.netflix_final
WHERE country = 'Brazil'
GROUP BY release_year
ORDER BY release_year;

-- =========================================
-- 5. TOP GÊNEROS
-- =========================================
SELECT 
    value AS GENERO, --VALUE = TABELA GENERO
    COUNT(*) AS TOTAL
FROM dbo.netflix_final
CROSS APPLY dbo.fn_SplitTexto(listed_in, ',') -- quebra a linha onde tem virgula
GROUP BY value 
ORDER BY TOTAL DESC;

-- =========================================
-- 6. SÉRIES COM MAIS TEMPORADAS
-- =========================================
SELECT
	title,
	duration
FROM dbo.netflix_final
WHERE type = 'TV Show'
/* 1. CHARINDEX: Localiza o espaço após o número
   2. LEFT: Corta o texto para manter apenas os dígitos
   3. CAST: Transforma o texto em número para permitir a comparação (> 5)
*/
AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

-- =========================================
-- 7. CONTEÚDOS RECENTES (ÚLTIMOS 7 ANOS)
-- =========================================
SELECT * 
FROM dbo.netflix_final
WHERE release_year >= YEAR(GETDATE()) -7;

-- =========================================
-- 8. QUALIDADE DOS DADOS (SEM DIRETOR)
-- =========================================
SELECT
	COUNT(*) AS SEM_DIRETOR
FROM dbo.netflix_final
WHERE director = 'Desconhecido'

-- =========================================
-- 9. TOP ATORES
-- =========================================
SELECT TOP 10
    value AS ATOR, --COLUNA VALUE CRIADA NA FUNÇÃO fn_SplitTexto
    COUNT(*) AS TOTAL
FROM dbo.netflix_final
CROSS APPLY dbo.fn_SplitTexto(cast, ',')
-- Filtros para limpar o resultado estranho:
WHERE cast IS NOT NULL 
  AND cast <> ''           -- Remove vazios
  AND LEN(value) > 1       -- Remove letras sozinhas
GROUP BY value
ORDER BY TOTAL DESC;

-- =========================================
-- 10. CLASSIFICAÇÃO DE CONTEÚDO 
-- =========================================
SELECT 
	CASE
		WHEN description LIKE '%kill%'
		OR  description LIKE '%violence%'
		THEN 'Violento'
		ELSE 'Leve'
	END AS categoria,
	COUNT(*) AS Total
FROM dbo.netflix_final
GROUP BY
	CASE
		WHEN description LIKE '%kill%'
		OR  description LIKE '%violence%'
		THEN 'Violento'
		ELSE 'Leve'
	END;

	

-- =========================================
-- 11. CRIAÇÃO DE VIEWS (PARA BI)
-- =========================================

-- Crescimento ao longo do tempo
CREATE VIEW vw_crescimento AS
SELECT
	release_year,
	COUNT(*) AS Total
FROM dbo.netflix_final
GROUP BY release_year;

-- Gêneros
CREATE VIEW vw_generos AS
SELECT 
    value AS GENERO, --VALUE = TABELA GENERO
    COUNT(*) AS TOTAL
FROM dbo.netflix_final
CROSS APPLY dbo.fn_SplitTexto(listed_in, ',') -- quebra a linha onde tem virgula
GROUP BY value;

-- Filmes vs Séries
CREATE VIEW vw_tipo_conteudo AS
SELECT 
	type,
	COUNT(*) AS Total
FROM dbo.netflix_final
GROUP BY type;

select * from vw_tipo_conteudo