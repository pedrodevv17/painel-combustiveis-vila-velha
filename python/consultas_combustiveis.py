"""
Consultas do Banco de Preços de Combustíveis - Vila Velha/ES
Disciplina: Arquitetura de Dados Relacionais I

Pré-requisitos:
  1) Ter o MySQL instalado e rodando.
  2) Ter executado o script precos_combustiveis_vila_velha_completo.sql
     no MySQL (isso cria e povoa o banco 'combustiveis_vv').
  3) Instalar a biblioteca de conexão:
       pip install mysql-connector-python
"""

import mysql.connector
from mysql.connector import Error

# --- Configuração da conexão -------------------------------------------------
# Troque "SUA_SENHA_AQUI" pela senha do seu usuário MySQL (ex: root).
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "SUA_SENHA_AQUI",
    "database": "combustiveis_vv",
}


def conectar():
    """Abre e retorna uma conexão com o banco combustiveis_vv."""
    return mysql.connector.connect(**DB_CONFIG)


def consulta_extremos(conn):
    """Consulta I: menor e maior preço de cada tipo de combustível."""
    sql = """
        (SELECT p.nome AS posto, p.endereco, p.bairro, c.tipo AS combustivel,
                co.valor, co.data_coleta, 'MENOR PRECO' AS observacao
         FROM coleta co
         JOIN posto p       ON p.posto_id = co.posto_id
         JOIN combustivel c ON c.combustivel_id = co.combustivel_id
         WHERE co.valor = (SELECT MIN(co2.valor) FROM coleta co2
                            WHERE co2.combustivel_id = co.combustivel_id))
        UNION ALL
        (SELECT p.nome, p.endereco, p.bairro, c.tipo,
                co.valor, co.data_coleta, 'MAIOR PRECO'
         FROM coleta co
         JOIN posto p       ON p.posto_id = co.posto_id
         JOIN combustivel c ON c.combustivel_id = co.combustivel_id
         WHERE co.valor = (SELECT MAX(co2.valor) FROM coleta co2
                            WHERE co2.combustivel_id = co.combustivel_id))
        ORDER BY combustivel, observacao;
    """
    cursor = conn.cursor(dictionary=True)
    cursor.execute(sql)
    resultados = cursor.fetchall()
    cursor.close()
    return resultados


def consulta_medias(conn):
    """Consulta II: quantidade de amostras e preço médio por posto e combustível."""
    sql = """
        SELECT p.nome AS posto, p.bairro, c.tipo AS combustivel,
               ROUND(AVG(co.valor), 2) AS preco_medio,
               COUNT(*) AS qtd_amostras
        FROM coleta co
        JOIN posto p       ON p.posto_id = co.posto_id
        JOIN combustivel c ON c.combustivel_id = co.combustivel_id
        GROUP BY p.posto_id, c.combustivel_id
        ORDER BY p.nome, c.tipo;
    """
    cursor = conn.cursor(dictionary=True)
    cursor.execute(sql)
    resultados = cursor.fetchall()
    cursor.close()
    return resultados


def consulta_recentes(conn):
    """Consulta III: preço mais recente por posto e por combustível."""
    sql = """
        SELECT p.nome AS posto, p.bairro, c.tipo AS combustivel,
               co.valor, co.data_coleta
        FROM coleta co
        JOIN posto p       ON p.posto_id = co.posto_id
        JOIN combustivel c ON c.combustivel_id = co.combustivel_id
        WHERE co.data_coleta = (
            SELECT MAX(co2.data_coleta) FROM coleta co2
            WHERE co2.posto_id = co.posto_id
              AND co2.combustivel_id = co.combustivel_id
        )
        ORDER BY p.nome, c.tipo;
    """
    cursor = conn.cursor(dictionary=True)
    cursor.execute(sql)
    resultados = cursor.fetchall()
    cursor.close()
    return resultados


def consulta_evolucao(conn, posto_id, combustivel_id):
    """Consulta IV: evolução do preço de um combustível específico em um posto específico."""
    sql = """
        SELECT p.nome AS posto, p.bairro, c.tipo AS combustivel,
               co.valor, co.data_coleta
        FROM coleta co
        JOIN posto p       ON p.posto_id = co.posto_id
        JOIN combustivel c ON c.combustivel_id = co.combustivel_id
        WHERE p.posto_id = %s
          AND c.combustivel_id = %s
        ORDER BY co.data_coleta;
    """
    cursor = conn.cursor(dictionary=True)
    cursor.execute(sql, (posto_id, combustivel_id))
    resultados = cursor.fetchall()
    cursor.close()
    return resultados


def imprimir_tabela(titulo, linhas):
    """Imprime uma lista de dicionários (resultado do MySQL) como tabela no terminal."""
    print(f"\n=== {titulo} ===")
    if not linhas:
        print("(nenhum resultado)")
        return
    colunas = list(linhas[0].keys())
    larguras = {c: max(len(c), max(len(str(l[c])) for l in linhas)) for c in colunas}
    cabecalho = " | ".join(c.ljust(larguras[c]) for c in colunas)
    print(cabecalho)
    print("-" * len(cabecalho))
    for linha in linhas:
        print(" | ".join(str(linha[c]).ljust(larguras[c]) for c in colunas))


if __name__ == "__main__":
    conn = None
    try:
        conn = conectar()
        imprimir_tabela("I. Menor e maior preço por combustível", consulta_extremos(conn))
        imprimir_tabela("II. Média e amostras por posto e combustível", consulta_medias(conn))
        imprimir_tabela("III. Preço mais recente por posto e combustível", consulta_recentes(conn))
        imprimir_tabela(
            "IV. Evolução (Gasolina no Posto Champagnat)",
            consulta_evolucao(conn, posto_id=1, combustivel_id=1),
        )
    except Error as e:
        print(f"Erro ao conectar/consultar o MySQL: {e}")
    finally:
        if conn is not None and conn.is_connected():
            conn.close()
