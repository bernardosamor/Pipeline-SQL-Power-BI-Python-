# Pipeline-SQL-Power-BI-Python-
Projeto criado para avaliar a construção de complexos imobiliários na cidade de Belo Horizonte, avaliando bairro a bairro para a escolha estratégica de custo e retorno financeiro rápido. Foram utilizados SQL para o tratamento bruto dos dados, Power BI para apresentação dos dados e Python para navegação inteligente pela base de dados (Text to SQL). Foi realizado um cálculo de tempo de Payback como driver de decisão para filtrar os 5 melhores bairros e o Bairro escolhido foi o Funcionários, com um payback mediano de 8,56 anos.

# 🏢 Análise de Atratividade Imobiliária & Inteligência de Mercado — Belo Horizonte (PBH & Kaggle)

![Power BI](https://img.shields.io/badge/Power_BI-F2C94C?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)

---

## 📌 Visão Geral do Projeto

Este projeto tem como objetivo avaliar **atratividade e viabilidade de investimentos imobiliários na cidade de Belo Horizonte/MG**, definindo um Bairro com relação custo/retorno equilibrado. Para tal, integrei dados públicos da Prefeitura de Belo Horizonte (PBH) com dados consolidados do mercado imobiliário (Kaggle).

A solução combina um **pipeline rigoroso de limpeza e harmonização em SQL**, um **dashboard executivo moderno no Power BI** (com suporte a matrizes de risco/retorno e análise de payback) e um **módulo interativo em Python utilizando Text-to-SQL**, que permite realizar consultas em linguagem natural no banco de dados imobiliário. 

---

## 🎯 Objetivos & Problemas de Negócio

Meu objetivo foi selecionar um bairro. Para seleção ideal, precisei adaptar a amostra para se encaixar no intervalor de maior apelo comercial:
* **Range ideal de custo mediano do m2**: Optei por um intervalo entre R$ 1.000 a 50.0000, pensando em imóveis de alto padrão e eliminando aluguéis, outliers extremos. 
* **Range de área(m2):** Limitei as consultas em SQL entre 20 a 360 m2, criando uma view. Este range foi definido ao segregar a base em intervalos de valores e pegando os espectros que concentram maiores ofertas.
* **Amostra mínima:** Considerei apenas bairros com ao menos 20 anúncios e 10 endereços distintos.
* **Definir critério para cálculo de Payback:** Consultando o Sinduscon-MG, optei por usar um CUB de R$ 3.137,48 para residências de alto nível. Valor atualizado em Setembro de 2026.

## 💎 Resultados do tratamento

Aplicando os critérios, a base passou por uma redução no volume de anúncios:

* **Volume Bruto Inicial:** 5.509 anúncios coletados originalmente.
* **Remoção de Duplicadas:** Queda para **5.262 anúncios** únicos.
* **Filtrando quanto a custo do m2 e area:** 
   * **Resultado:** **4.712 imóveis válidos** no total da base *(métrica apresentada nos indicadores globais do dashboard)*.

### 🛠️ Critério de Elegibilidade para o Ranking de Oportunidades
Para que um bairro seja considerado na análise comparativa de *payback* e oportunidades, ele precisa cumprir as seguintes condições:

* **Regra de Amostragem Mínima:** Apenas bairros com no mínimo 20 anúncios distribuídos em pelo menos 10 endereços distintos.
* **Volume qualificado para o Ranking:** 3.967 anúncios distribuídos em 44 bairros.

---

## 🗄️ Tratamento de Dados & Engenharia em SQL

A etapa de tratamento em SQL resolveu desafios críticos de consistência de dados:

* **Resolução de Problemas de Encoding:** Trata discrepâncias de codificação (e.g., `UTF-8` vs `ISO-8859-1`/`LATIN-1`) no import e cruzamento de tabelas, eliminando caracteres corrompidos (*mojibake*) nos nomes dos bairros.
* **Padronização e Normalização de Bairros:** Aplicação de funções de substituição de acentos e caracteres especiais (`TRANSLATE`, `LOWER`, remoção de pontuação) para criar uma chave única de associação entre a base do Kaggle e a base oficial da PBH.
* **Eliminação de Ambiguidades e Poluição:** Criação de *views* tratadas, onde houve exclusão de dados nulos, alinhamento de valores decimais para garantir que dados sem preenchimento ou irrelevantes para a decisão imobiliária sejam devidamente categorizados ou filtrados no nível analítico.

---

## 📐 Modelagem de Dados & Métricas no Power BI

O modelo de dados adota a arquitetura de **Star Schema** (Esquema Estrela), garantindo performance e escalabilidade.

### Destaques de DAX e Regras de Negócio:
* **Payback Mediano:** Cálculo de tempo de retorno de investimento com tratamento de outliers e garantia de valores estritamente positivos (`Payback > 0`), eliminando distorções de divisões por zero ou nulos.
* **Rankings Dinâmicos Robustos:** Uso de tabelas calculadas em variáveis DAX (`FILTER` + `TOPN` + `CONCATENATEX`) para identificar visualmente o **#1 Bairro em Oportunidade** e **#1 Bairro em Oferta**, prevenindo empates incorretos provocados por dados residuais.
* **UI/UX Sleek-Dark Executivo:** Dashboard de 2 páginas (*Overview Macro* e *Análise por Bairro*) desenvolvido com foco em legibilidade, mapas de calor, matrizes de atratividade (Preço/m² vs Payback) e seletores rápidos.

---

## 🏗️ Engenharia & Modelagem de Dados (Data Architecture)

Para garantir performance, escalabilidade e manutenibilidade do projeto, o modelo de dados passou por um processo completo de **refatoração arquitetural**, evoluindo de esquemas legados com ambiguidades para um **Star Schema (Esquema em Estrela)** otimizado.

---

### 🎯 Principais Desafios

1. **Centralização de Regras de Negócio e Otimização DAX:**
   * ** Critério para escolha de localização ideal.
      * Estipular limites de custo mediano de m2 para análise.
      * Definir range de area_m2 para avaliação (optei por 20-360 m2)
      * Entender o apelo de localização estratégica dos bairros filtrados por Payback para entender a escolha ideal.
      * Balancear Oferta de imóveis por 10.000 habitantes com o custo mediano de m2.
   * Criação do repositório dedicado `_Medidas` para isolar toda a camada de cálculo.
   * **Faxina & Refatoração:** Remoção de código morto, unificação de medidas redundantes de m² e uso de funções seguras (`DIVIDE` com tratamento de divisão por zero) para otimização do consumo de memória. Além decimais lidos 100× maiores no Power BI, tive que substituir ponto por vírgula antes de converter para decimal (Ex: 439000.00 apareceu como 43.900.000). 

2. **Padronização e Tratamento em Pipeline (Power Query / SQL):**
   * Padronização de nomes de bairros utilizando *Capitalize Each Word* para alinhamento entre as bases do IBGE/PBH e dados extraídos via Web Scraping/Kaggle.

3. **Migração para Star Schema ($1 : N$):**
   * **Desafio:** Existência de tabelas relacionais intermediárias e granularidades inconsistentes que geravam ambiguidades nos relacionamentos e duplicidades de registros.
   * **Solução:** Consolidação das informação na tabela dimensão mestre `dBairro` (Lado $1$) conectada diretamente à tabela de anúncios `fato_Kaggle` (Lado $N$).

4. **Garantia de Granularidade e Deduplicação:**
   * **Ajuste Fino:** Remoção de atributos de oferta (`tipo_imovel` e `tipo_negocio`) da dimensão geográfica para garantir a estrita relação $1:N$ sem quebra de cardinalidade por bairros duplicados.

### 🎯 Conclusões alcançadas


---

## 🤖 Módulo Python: Text-to-SQL

Para otimizar a experiência do usuário final e facilitar explorações, foi desenvolvido um agente em Python que converte perguntas em linguagem natural diretamente para instruções SQL:

* **Interface Amigável:** Permite perguntas como *"Quais são os 5 bairros com menor preço por m²?"* ou *"Qual a oferta de imóveis de 3 quartos no Centro?"*.
* **Geração Automática de Queries:** Mapeia a intenção da pergunta para o schema do banco de dados, retornando os resultados estruturados instantaneamente.
* **Agilidade no Mapeamento:** Reduz a dependência da equipe de BI para responder a dúvidas operacionais pontuais do time de negócios, fazendo com que consultas sejam realizadas apenas com prompts.

---

## 📊 Estrutura do Dashboard (Power BI)

* **Página 1 — Overview Macro:** 
  * KPIs principais (`Total de Imóveis`, `Preço Médio m²`, `Payback Mediano Cidade`, `#1 Bairro em Oferta`, `#1 Bairro em Oportunidades`).
  * Matriz de Atratividade (*Preço do m² x Payback*).
  * Oferta de Imóveis x Qtd. Quartos
  * Ranking dos Top 5 Bairros com menor tempo de payback (Oportunidades) vs maior tempo (Riscos).
* **Página 2 — Análise de Valor por Bairro:**
  * Filtro lateral dinâmico por Bairro.
  * KPIs principais (`Qtd. Imóveis x Densidade populacional per 10k habitantes`, `Área mediana dos imóveis  m²`, `Preço médio m²`, `Tempo mediano de Payback`).
  * Distribuição por tipologia de quartos (1, 2, 3 e 4+ quartos).
  * Custo do m² por quantidade de quartos.
  * Proporção de imóveis por range de m²
  * Análise de faixa de preço e densidade de vagas de garagem por imóvel.

---

## 📸 Prints do Projeto.

* ** SQL: Tratamento de Mojibakes:**

<img width="913" height="466" alt="Tratamento de erros de encoding" src="https://github.com/user-attachments/assets/eb0fe15d-a8df-4e7a-9ae2-6d6e5bb7b090" />

---

* ** SQL: Tratamento de Mojibakes:**

<img width="1036" height="444" alt="Normalização de nomes de bairro em cruzamento de tabelas (Kaggle x PBH)" src="https://github.com/user-attachments/assets/6e464a55-0877-439a-9ca4-589af89cbbf5" />

---

* ** Power BI: Apresentação dos relacionamentos (Star Schema):**

<img width="1583" height="866" alt="Star Schema PBH" src="https://github.com/user-attachments/assets/243ef430-8820-480a-9841-fe5d5f49badd" />

---

* ** Power BI: Segregação das tabelas e Medidas:**

<img width="320" height="373" alt="Segregação de tabelas e apresentação de medidas utilizadas" src="https://github.com/user-attachments/assets/e3bcadc6-5a41-4713-94dc-da326c8094f1" />

---

* ** Dashboard Power BI: Overview Macro:**

<img width="1301" height="728" alt="Overview Macro PBH" src="https://github.com/user-attachments/assets/f67ee734-0c28-455c-898d-921fbeca88fa" />

---

* ** Dashboard Power BI: Overview Bairro:**

<img width="1304" height="722" alt="Overview Bairro PBH" src="https://github.com/user-attachments/assets/0cbda082-1769-42bd-9c29-bb5cddfb0766" />

---

* ** Python: Agente Imobiliário com UI Streamlit:**

<img width="1486" height="658" alt="print agente de ia streamlit" src="https://github.com/user-attachments/assets/6c9f8f28-4360-4d3f-86db-bf0917138d62" />

---

## 🚀 Como Executar o Projeto

1. **SQL / Banco de Dados:**
   * Execute os scripts da pasta `/sql` para criar a estrutura do banco e processar o tratamento de encoding e normalização das chaves de bairros.
2. **Power BI:**
   * Abra o arquivo `.pbix` localizado em `/powerbi` e atualize a conexão com o banco SQL local/servidor.
3. **Módulo Text-to-SQL (Python):**
   * Instale as dependências com `pip install -r requirements.txt`.
   * Configure suas credenciais de acesso no arquivo `.env`.
   * Execute `python app.py` para abrir a interface interativa de consulta.

---

## ✉️ Contato

Projeto desenvolvido por **Bernardo Samôr**  
🔗 [LinkedIn](https://www.linkedin.com/in/bernardosamor/) | 🐙 [GitHub](https://github.com/bernardosamor)
