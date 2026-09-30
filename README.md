# Pipeline-SQL-Power-BI-Python-
Projeto criado para avaliar a construção de complexos imobiliários na cidade de Belo Horizonte, avaliando bairro a bairro para a escolha estratégica de custo e retorno financeiro rápido. Foram utilizados SQL para o tratamento bruto dos dados, Power BI para apresentação dos dados e Python para navegação inteligente pela base de dados (Text to SQL)

# 🏢 Análise de Atratividade Imobiliária & Inteligência de Mercado — Belo Horizonte (PBH & Kaggle)

![Power BI](https://img.shields.io/badge/Power_BI-F2C94C?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)

---

## 📌 Visão Geral do Projeto

Este projeto tem como objetivo avaliar a **atratividade e viabilidade de investimentos imobiliários na cidade de Belo Horizonte/MG**, integrando dados públicos da Prefeitura de Belo Horizonte (PBH) com dados consolidados do mercado imobiliário (Kaggle). 

A solução combina um **pipeline rigoroso de limpeza e harmonização em SQL**, um **dashboard executivo moderno no Power BI** (com suporte a matrizes de risco/retorno e análise de payback) e um **módulo interativo em Python utilizando Text-to-SQL**, que permite realizar consultas em linguagem natural no banco de dados imobiliário.

---

## 🎯 Problema de Negócio & Objetivos

Mediante a densidade de imóveis e gama de opções de locais aos quais podem ser atribuídos a escolha de se construir um complexos imobiliário na cidade de Belo Horizonte, criei uma ferramenta para ter acesso a base de dados públicos da prefeitura de Belo Horizonte para se entender o apelo que se tem de cada perfil de imóvel, desde custo, tamanho, localidade e ligando isso a demanda que cada aspecto tem pelo público.
---
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
