-- 1. Apaga a tabela antiga
DROP TABLE IF EXISTS populacao_domicilio_bairro_2022;

-- 2. Cria a tabela com as 7 colunas do arquivo
CREATE TABLE populacao_domicilio_bairro_2022 (
    id_pop_domic_bairro_2022 TEXT,
    num_bairro TEXT,
    bairro TEXT,
    area_km TEXT,
    populacao TEXT,
    domicilios TEXT,
    densidade_demografica TEXT
);

-- 1. Apaga a tabela antiga
DROP TABLE IF EXISTS imoveis_bh_kaggle;

-- 2. Recria a tabela
CREATE TABLE imoveis_bh_kaggle (
    address TEXT,
    adm_fees TEXT,
    garage_places TEXT,
    price TEXT,
    rooms TEXT,
    square_foot TEXT,
    neighborhood TEXT,
    city TEXT,
    latitude TEXT,
    longitude TEXT
);

-- 3. Ingestão ajustando a quebra de linha para '\n'
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/imoveis_bh_kaggle.csv'
INTO TABLE imoveis_bh_kaggle
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. Importa usando o ponto e vírgula como delimitador
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/20250801_populacao_domicilio_bairro_2022.csv'
INTO TABLE populacao_domicilio_bairro_2022
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-------------------------------------------------------------------------------------------------------------------
-- Pegar linhas incosistentes 
SELECT * 
FROM populacao_domicilio_bairro_2022 
WHERE bairro IS NULL 
   OR bairro = '' 
   OR id_pop_domic_bairro_2022 IS NULL 
   OR id_pop_domic_bairro_2022 = '';

-- Limpando linhas inconsistentes
	-- 1. Desativa a trava do Safe Mode para esta sessão
SET SQL_SAFE_UPDATES = 0;

	-- 2. Deleta as 12 linhas fantasmas
DELETE FROM populacao_domicilio_bairro_2022 
WHERE bairro IS NULL 
   OR bairro = '' 
   OR id_pop_domic_bairro_2022 IS NULL 
   OR id_pop_domic_bairro_2022 = '';

	-- 3. Reativa a trava de segurança por boa prática
SET SQL_SAFE_UPDATES = 1;

-- 1. Desativa Safe Mode para alterar estrutura/dados
SET SQL_SAFE_UPDATES = 0;

-- 2. Converte campos de texto para números no MySQL
ALTER TABLE imoveis_bh_kaggle 
    MODIFY COLUMN price DECIMAL(12,2),
    MODIFY COLUMN adm_fees DECIMAL(10,2),
    MODIFY COLUMN garage_places INT,
    MODIFY COLUMN rooms INT,
    MODIFY COLUMN square_foot DECIMAL(10,2),
    MODIFY COLUMN latitude DECIMAL(10,8),
    MODIFY COLUMN longitude DECIMAL(10,8);

-- 3. Limpeza de Anomalias / Outliers (Ex: imóveis sem preço ou sem área definida)
DELETE FROM imoveis_bh_kaggle 
WHERE price IS NULL 
   OR price <= 0 
   OR square_foot IS NULL 
   OR square_foot <= 0;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) FROM populacao_domicilio_bairro_2022;
SELECT COUNT(*) FROM imoveis_bh_kaggle;