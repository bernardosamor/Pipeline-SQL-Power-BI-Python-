SELECT * FROM vw_analise_imoveis_bh;

CREATE OR REPLACE VIEW vw_analise_imoveis_bh_tratada AS
WITH base_categorizada AS (
    SELECT 
        k.address,
        TRIM(k.neighborhood) AS bairro_imovel,
        p.bairro AS bairro_oficial_pbh,
        
        CAST(k.price AS DECIMAL(12,2)) AS preco,
        CAST(k.square_foot AS DECIMAL(10,2)) AS area_m2,
        CAST(k.adm_fees AS DECIMAL(10,2)) AS condominio,
        CAST(k.rooms AS UNSIGNED) AS quartos,
        
        ROUND(CAST(k.price AS DECIMAL(12,2)) / NULLIF(CAST(k.square_foot AS DECIMAL(10,2)), 0), 2) AS preco_m2,
        
        CASE 
            WHEN CAST(k.price AS DECIMAL(12,2)) < 15000 THEN 'Aluguel'
            WHEN CAST(k.price AS DECIMAL(12,2)) >= 50000 THEN 'Venda'
            ELSE 'Outlier / Indefinido'
        END AS tipo_negocio,
        
        CASE 
            WHEN CAST(k.adm_fees AS DECIMAL(10,2)) > 0 THEN 'Apartamento / Prédio'
            ELSE 'Casa / Outros'
        END AS tipo_imovel,
        
        CAST(p.populacao AS UNSIGNED) AS populacao_bairro
    FROM imoveis_bh_kaggle k
    INNER JOIN populacao_domicilio_bairro_2022 p 
        ON TRIM(k.neighborhood) COLLATE utf8mb4_0900_ai_ci = TRIM(p.bairro) COLLATE utf8mb4_0900_ai_ci
)
SELECT * 
FROM base_categorizada
WHERE tipo_negocio IN ('Venda', 'Aluguel') -- Agora inclui ambos!
  AND area_m2 >= 15;

WITH imoveis_ranqueados AS (
    SELECT 
        bairro_imovel,
        tipo_imovel,
        tipo_negocio,
        preco,
        area_m2,
        preco_m2,
        
        -- Estatísticas agregadas segregadas por Bairro, Tipo de Imóvel e Tipo de Negócio
        AVG(preco) OVER (PARTITION BY bairro_imovel, tipo_imovel, tipo_negocio) AS preco_medio_bairro_tipo,
        MAX(preco) OVER (PARTITION BY bairro_imovel, tipo_imovel, tipo_negocio) AS preco_maximo_bairro_tipo,
        AVG(preco_m2) OVER (PARTITION BY bairro_imovel, tipo_imovel, tipo_negocio) AS preco_m2_medio_bairro_tipo,
        AVG(area_m2) OVER (PARTITION BY bairro_imovel, tipo_imovel, tipo_negocio) AS area_media_bairro_tipo,
        COUNT(*) OVER (PARTITION BY bairro_imovel, tipo_imovel, tipo_negocio) AS total_imoveis_tipo,
        
        -- Ranking do mais barato (1) ao mais caro por Bairro, Tipo e Negócio
        ROW_NUMBER() OVER (
            PARTITION BY bairro_imovel, tipo_imovel, tipo_negocio 
            ORDER BY preco ASC
        ) AS rank_preco
    FROM vw_analise_imoveis_bh_tratada
)
SELECT 
    bairro_imovel AS Bairro,
    tipo_negocio,
    tipo_imovel,
    total_imoveis_tipo AS ofertas_disponiveis,
    preco AS menor_preco_imovel,
    area_m2 AS area_menor_preco,
    ROUND(preco_m2_medio_bairro_tipo, 2) AS valor_m2_medio,
    ROUND(preco_medio_bairro_tipo, 2) AS preco_medio_bairro,
    ROUND(preco_maximo_bairro_tipo, 2) AS preco_maximo_bairro,
    ROUND(area_media_bairro_tipo, 2) AS area_media_bairro
FROM imoveis_ranqueados
WHERE rank_preco = 1
ORDER BY ofertas_disponiveis DESC;

