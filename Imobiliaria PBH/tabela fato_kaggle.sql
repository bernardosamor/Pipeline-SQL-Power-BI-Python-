
SELECT 
	COUNT(*) AS Qtd_imoveis,
	AVG (preco) AS preco_medio,
    AVG (preco/area_m2) AS preco_m2_medio_amostra 
FROM vw_analise_imoveis_bh
WHERE bairro_oficial_pbh = 'Lourdes'
	AND (area_m2) BETWEEN 90 AND 130;

