import json
import re
from urllib.parse import quote_plus
from langchain_community.utilities import SQLDatabase
from langchain_core.prompts import PromptTemplate
from langchain_ollama.llms import OllamaLLM
import pandas as pd
from sqlalchemy import create_engine, inspect
import streamlit as st

# Template do Prompt
template = """
Você é um consultor de dados imobiliários referente à cidade de Belo Horizonte.
Seu trabalho é receber perguntas em português e convertê-las em consultas SQL válidas para o MySQL.

Regras de Negócio Importantes:
1. A tabela/view principal a ser consultada é 'vw_analise_imoveis_bh'.
2. As colunas como 'preco', 'condominio' e 'preco_m2' representam CUSTOS em REAIS (R$).
3. Ao filtrar por bairros, utilize sempre a coluna 'bairro_oficial_pbh' (pois já está tratada e normalizada).
4. Retorne APENAS a sintaxe SQL pura. Não inclua explicações, textos de apresentação nem marcas de markdown.

Estrutura do banco de dados (Schema):
{schema}

Pergunta do usuário:
{query}

Query SQL:
"""


@st.cache_resource
def carregar_modelo():
    return OllamaLLM(model="deepseek-r1:8b")


@st.cache_data
def extrair_schema(url_banco: str) -> str:
    engine = create_engine(url_banco)
    inspector = inspect(engine)
    schema = {}

    for tabela in inspector.get_table_names():
        colunas = inspector.get_columns(tabela)
        schema[tabela] = [coluna["name"] for coluna in colunas]

    return json.dumps(schema, ensure_ascii=False)


def limpar_texto(texto: str) -> str:
    texto_limpo = re.sub(r"<think>.*?</think>", "", texto, flags=re.DOTALL)
    texto_limpo = re.sub(r"```sql|```", "", texto_limpo)
    return texto_limpo.strip()


def gerar_consulta_sql(
    pergunta: str, schema_banco: str, modelo
) -> str:
    prompt = PromptTemplate(
        template=template, input_variables=["schema", "query"]
    )
    cadeia = prompt | modelo
    resposta_bruta = cadeia.invoke(
        {"query": pergunta, "schema": schema_banco}
    )
    return limpar_texto(resposta_bruta)


def executar_consulta(sql: str, url_banco: str) -> pd.DataFrame:
    engine = create_engine(url_banco)
    with engine.connect() as conexao:
        df = pd.read_sql(sql, conexao)
    return df