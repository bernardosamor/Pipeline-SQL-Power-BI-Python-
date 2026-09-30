from urllib.parse import quote_plus
import pandas as pd
import streamlit as st

# Importando as funçãoes
from agente_backend import (
    carregar_modelo,
    executar_consulta,
    extrair_schema,
    gerar_consulta_sql,
)

# Configuração da página do Streamlit
st.set_page_config(
    page_title="Inteligência ImobilIAria - BH",
    page_icon="🏢",
    layout="wide",
)

# 1. Conexão ao Banco de Dados MySQL
senha = quote_plus("BSamor@161199")
db_url = f"mysql+pymysql://root:{senha}@localhost:3306/imobiliario_db"

# --- INTERFACE GRÁFICA ---
st.title("🏢 Agente de IA - Inteligência Imobiliária BH")
st.caption(
    "Faça perguntas em português sobre a base de imóveis e obtenha consultas e dados em tempo real."
)

# Carrega o modelo e o schema
modelo = carregar_modelo()

try:
    schema_atual = extrair_schema(db_url)
    st.sidebar.success("Conectado ao MySQL (`imobiliario_db`)")
except Exception as e:
    st.sidebar.error(f"Erro ao conectar ao banco: {e}")
    st.stop()

# Caixa de entrada para a Pergunta
pergunta_usuario = st.text_input(
    "Digite sua dúvida comercial/imobiliária:",
    placeholder="Ex: Qual o preço médio por m² em Lourdes?",
)

if st.button("Consultar Banco de Dados", type="primary"):
    if pergunta_usuario.strip() != "":
        with st.spinner("O agente está gerando a consulta SQL e buscando os dados..."):
            # 1. Gera o SQL via DeepSeek
            sql_gerado = gerar_consulta_sql(
                pergunta_usuario, schema_atual, modelo
            )

            # Exibe a Query
            st.markdown("### 🛠️ Query SQL Gerada")
            st.code(sql_gerado, language="sql")

            # 2. Executa no MySQL e exibe a Tabela
            try:
                tabela_resultado = executar_consulta(sql_gerado, db_url)
                st.markdown("### 📊 Resultado")

                if not tabela_resultado.empty:
                    st.dataframe(
                        tabela_resultado, use_container_width=True
                    )
                else:
                    st.warning(
                        "A consulta foi executada, mas não retornou nenhum registro."
                    )

            except Exception as e:
                st.error(f"Erro ao executar a consulta no MySQL: {e}")
    else:
        st.warning("Por favor, digite uma pergunta antes de consultar.")
