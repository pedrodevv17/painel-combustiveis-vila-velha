# Painel de Preços de Combustíveis — Vila Velha/ES

Projeto de extensão da disciplina **Arquitetura de Dados Relacionais I**: um banco de dados relacional (3ª Forma Normal) para armazenar coletas de preço de combustível, com um site de divulgação para a comunidade e um script Python para rodar as mesmas consultas direto no MySQL.

🔗 **Site publicado:** _(cole aqui o link do GitHub Pages depois do passo "Ative o GitHub Pages" — algo como `https://seuusuario.github.io/painel-combustiveis-vila-velha/`)_

## Estrutura do repositório

```
painel-combustiveis-vila-velha/
├── index.html            → o site (abre sozinho em qualquer navegador)
├── README.md             → este arquivo
├── sql/
│   └── precos_combustiveis_vila_velha_completo.sql   → cria e povoa o banco no MySQL
└── python/
    ├── consultas_combustiveis.py   → roda as 4 consultas direto no MySQL, via terminal
    └── requirements.txt            → dependência (mysql-connector-python)
```

## Sobre o projeto

- **Dados:** 5 postos, 4 tipos de combustível (Gasolina, Gasolina Aditivada, Etanol, Diesel S10), 5 bairros de Vila Velha/ES, a partir da Série Histórica de Preços de Combustíveis da ANP.
- **Modelagem:** tabelas `posto`, `combustivel` e `coleta`, ligadas por chaves estrangeiras (1:N), na 3ª Forma Normal.
- **SGBD:** MySQL 8+.

## 1. O site (`index.html`)

Arquivo único em HTML, CSS e JavaScript puro (com [Chart.js](https://www.chartjs.org/) para os gráficos). Os dados de coleta estão embutidos na própria página, então ele funciona sozinho, sem servidor nem banco rodando por trás — basta abrir o arquivo no navegador ou hospedar em qualquer serviço de páginas estáticas.

O que ele mostra:

| Seção | O que faz |
|---|---|
| Painel inicial | Preço médio mais recente de cada combustível entre os 5 postos |
| Menor & maior preço | Onde e quando foi registrado o menor e o maior valor de cada combustível |
| Média por posto | Preço médio e número de coletas de cada combustível, por posto |
| Preço mais recente | Última coleta registrada de cada combinação posto + combustível |
| Evolução no tempo | Gráfico e tabela da variação de preço, com posto e combustível à escolha do usuário |
| Gráficos gerais | Evolução do preço médio por combustível e comparação entre postos |

### Publicar no GitHub Pages

1. Crie um repositório novo no GitHub e suba todo o conteúdo desta pasta.
2. Vá em **Settings → Pages**, escolha a branch `main` e a pasta raiz (`/`), e salve.
3. Depois de 1–2 minutos, o GitHub mostra o link definitivo (`seuusuario.github.io/nome-do-repo`) — atualize esse link no topo deste README.

## 2. O banco de dados (`sql/`)

Rode `sql/precos_combustiveis_vila_velha_completo.sql` num cliente MySQL (Workbench, linha de comando ou phpMyAdmin) para criar o banco `combustiveis_vv`, suas tabelas e os dados de coleta.

## 3. O script Python (`python/`)

Roda as mesmas 4 consultas exigidas direto no MySQL, pelo terminal — útil para demonstrar o funcionamento do banco fora do site.

```bash
cd python
pip install -r requirements.txt
python consultas_combustiveis.py
```

Antes de rodar, edite a senha de acesso ao MySQL em `DB_CONFIG`, dentro de `consultas_combustiveis.py`.

## Fonte dos dados

ANP — Série Histórica de Preços de Combustíveis (Levantamento de Preços por Posto Revendedor, Decreto nº 8.777/2016).
https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis

## Autoria

Pedro Costa Barroso — Arquitetura de Dados Relacionais I.
Projeto acadêmico, sem fins comerciais.
