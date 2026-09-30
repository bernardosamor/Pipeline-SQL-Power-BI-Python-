-- ==============================================================================
-- PIPELINE DE LIMPEZA, TRATAMENTO E MODELAGEM DE DADOS (STAGING TO ANALYTICS)
-- Projeto: Análise do Mercado Imobiliário vs. Demografia de Belo Horizonte
-- Autor: Junior Data Analyst
-- ==============================================================================

USE imobiliario_db;

-- ------------------------------------------------------------------------------
-- ETAPA 1: TRATAMENTO DA BASE OFICIAL (PBH - DEMOGRAFIA)
-- Correção de encoding/mojibake gerado durante a ingestão do arquivo da prefeitura
-- ------------------------------------------------------------------------------
SET SQL_SAFE_UPDATES = 0;

UPDATE populacao_domicilio_bairro_2022 
SET bairro = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    bairro, 
    'Ã¡', 'á'), 'Ã£', 'ã'), 'Ã¢', 'â'), 'Ã\x00', 'à'),
    'Ã©', 'é'), 'Ãª', 'ê'),
    'Ã-', 'í'),
    'Ã³', 'ó'), 'Ã´', 'ô'), 'Ãµ', 'õ'),
    'Ãº', 'ú'),
    'Ã§', 'ç');

-- ------------------------------------------------------------------------------
-- ETAPA 2: LIMPEZA E PADRONIZAÇÃO DA BASE DE IMÓVEIS (KAGGLE)
-- Exclusão de ruídos de extração e padronização pontual de nomes de bairros
-- ------------------------------------------------------------------------------

-- 2.1 Remoção de registros sem bairro ou com lixo de web scraping
DELETE FROM imoveis_bh_kaggle 
WHERE neighborhood IS NULL 
   OR TRIM(neighborhood) = '' 
   OR TRIM(neighborhood) = 'I';

-- 2.2 De-para de bairros com divergências de nomenclatura/regional
UPDATE imoveis_bh_kaggle SET neighborhood = 'Sagrada Família' WHERE neighborhood LIKE '%Sagrada%';
UPDATE imoveis_bh_kaggle SET neighborhood = 'Piratininga'      WHERE neighborhood LIKE '%Piratininga%';
UPDATE imoveis_bh_kaggle SET neighborhood = 'São Luiz'         WHERE neighborhood LIKE '%São Lu%z%';
UPDATE imoveis_bh_kaggle SET neighborhood = 'Bonsucesso'      WHERE neighborhood LIKE '%Bonsucesso%';
UPDATE imoveis_bh_kaggle SET neighborhood = 'Itaipu'          WHERE neighborhood LIKE '%Itaipu%';
UPDATE imoveis_bh_kaggle SET neighborhood = 'Cardoso'         WHERE neighborhood LIKE '%Cardoso%';

SET SQL_SAFE_UPDATES = 1;

-- ------------------------------------------------------------------------------
-- ETAPA 3: CRIAÇÃO DA CAMADA DE CONSUMO / ANALYTICS (VIEW)
-- Tipagem dos dados (CASTs), criação de métricas calculadas e JOIN validado
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_analise_imoveis_bh AS
SELECT 
    -- Localização
    k.address,
    TRIM(k.neighborhood) AS bairro_imovel,
    p.bairro AS bairro_oficial_pbh,
    
    -- Tipagem Numérica (CAST)
    CAST(k.price AS DECIMAL(12,2)) AS preco,
    CAST(k.square_foot AS DECIMAL(10,2)) AS area_m2,
    CAST(k.adm_fees AS DECIMAL(10,2)) AS condominio,
    CAST(k.rooms AS UNSIGNED) AS quartos,
    CAST(k.garage_places AS UNSIGNED) AS vagas_garagem,
    
    -- Métrica Analítica: Preço por m²
    ROUND(
        CAST(k.price AS DECIMAL(12,2)) / NULLIF(CAST(k.square_foot AS DECIMAL(10,2)), 0), 
        2
    ) AS preco_m2,
    
    -- Coordenadas Geográficas
    CAST(k.latitude AS DECIMAL(10,8)) AS latitude,
    CAST(k.longitude AS DECIMAL(10,8)) AS longitude,
    
    -- Métricas Demográficas
    CAST(p.populacao AS UNSIGNED) AS populacao_bairro,
    CAST(p.domicilios AS UNSIGNED) AS domicilios_bairro

FROM imoveis_bh_kaggle k
INNER JOIN populacao_domicilio_bairro_2022 p 
    ON TRIM(k.neighborhood) COLLATE utf8mb4_0900_ai_ci = TRIM(p.bairro) COLLATE utf8mb4_0900_ai_ci;