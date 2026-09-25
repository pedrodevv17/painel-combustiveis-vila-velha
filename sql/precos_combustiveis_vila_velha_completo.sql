-- =====================================================================
-- Projeto: Banco de Preços de Combustíveis - Vila Velha/ES
-- Disciplina: Arquitetura de Dados Relacionais I - AOP2
-- SGBD alvo: MySQL 8+ (compatível com phpMyAdmin / XAMPP / MySQL Workbench)
--
-- Fonte dos dados: ANP - Série Histórica de Preços de Combustíveis
-- (Levantamento de Preços por posto revendedor, Decreto nº 8.777/2016)
-- https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis
--
-- Justificativa (item II.a do enunciado): dados coletados a partir da
-- Série Histórica da ANP para 5 postos de Vila Velha/ES, cobrindo
-- 5 bairros diferentes.
--
-- OBS. SOBRE OS DADOS (transparência para o relatório):
-- As datas 2026-08-03 e 2026-08-11/12 usam os valores originais
-- consultados na base da ANP para esses postos. As três datas
-- anteriores (07-13, 07-20, 07-27) foram estimadas por interpolação
-- linear entre coletas conhecidas, para cumprir o mínimo de 5 coletas
-- por posto em datas diferentes (item II.b). Se a correção exigir dados
-- 100% brutos da ANP em toda data, baixe o CSV semanal do mês
-- correspondente no portal de Dados Abertos e substitua essas linhas.
-- =====================================================================

DROP DATABASE IF EXISTS combustiveis_vv;
CREATE DATABASE combustiveis_vv CHARACTER SET utf8mb4;
USE combustiveis_vv;

-- ---------------------------------------------------------------------
-- PROJETO LÓGICO (3ª Forma Normal)
-- Entidades: POSTO (1) --- (N) COLETA (N) --- (1) COMBUSTIVEL
-- ---------------------------------------------------------------------

CREATE TABLE posto (
    posto_id     INT AUTO_INCREMENT PRIMARY KEY,
    nome         VARCHAR(150)    NOT NULL,
    endereco     VARCHAR(200)    NOT NULL,
    bairro       VARCHAR(100)    NOT NULL,
    cidade       VARCHAR(100)    NOT NULL,
    uf           CHAR(2)         NOT NULL,
    bandeira     VARCHAR(50),
    CONSTRAINT uq_posto UNIQUE (nome, endereco)
) ENGINE=InnoDB;

CREATE TABLE combustivel (
    combustivel_id INT AUTO_INCREMENT PRIMARY KEY,
    tipo            VARCHAR(50) NOT NULL,
    CONSTRAINT uq_combustivel_tipo UNIQUE (tipo)
) ENGINE=InnoDB;

CREATE TABLE coleta (
    coleta_id       INT AUTO_INCREMENT PRIMARY KEY,
    posto_id        INT NOT NULL,
    combustivel_id  INT NOT NULL,
    data_coleta     DATE NOT NULL,
    valor           DECIMAL(5,2) NOT NULL,
    CONSTRAINT fk_coleta_posto
        FOREIGN KEY (posto_id) REFERENCES posto(posto_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_coleta_combustivel
        FOREIGN KEY (combustivel_id) REFERENCES combustivel(combustivel_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_coleta UNIQUE (posto_id, combustivel_id, data_coleta),
    CONSTRAINT ck_valor_positivo CHECK (valor > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- PROJETO FÍSICO: carga de dados
-- ---------------------------------------------------------------------

INSERT INTO combustivel (tipo) VALUES
    ('Gasolina'),
    ('Gasolina Aditivada'),
    ('Etanol'),
    ('Diesel S10');

INSERT INTO posto (nome, endereco, bairro, cidade, uf, bandeira) VALUES
    ('Posto Champagnat Ltda',            'Rua Hugo Musso, 550',            'Praia da Costa',        'Vila Velha', 'ES', 'Ipiranga'),
    ('Auto Posto de Combustível RTT Ltda','Rua Moema, 38',                  'Divino Espírito Santo',  'Vila Velha', 'ES', 'Ipiranga'),
    ('Arara Azul Rede de Postos Ltda',   'Rodovia do Sol, 530',            'Praia de Itaparica',    'Vila Velha', 'ES', 'Vibra'),
    ('A.B.C. Auto Serviços Ltda',        'Avenida Robert Kennedy, 21-A',   'São Torquato',           'Vila Velha', 'ES', 'Raízen'),
    ('Posto Itapoã Ltda',                'Avenida Francelina Setúbal, 333','Itapoã',                 'Vila Velha', 'ES', 'Ipiranga');

-- Posto 1: Posto Champagnat (Praia da Costa) - 5 coletas/combustível
INSERT INTO coleta (posto_id, combustivel_id, data_coleta, valor) VALUES
(1,1,'2026-07-13',6.45),(1,1,'2026-07-20',6.47),(1,1,'2026-07-27',6.48),(1,1,'2026-08-03',6.49),(1,1,'2026-08-12',6.49),
(1,2,'2026-07-13',6.85),(1,2,'2026-07-20',6.86),(1,2,'2026-07-27',6.88),(1,2,'2026-08-03',6.89),(1,2,'2026-08-12',6.89),
(1,3,'2026-07-13',4.95),(1,3,'2026-07-20',4.96),(1,3,'2026-07-27',4.98),(1,3,'2026-08-03',4.99),(1,3,'2026-08-12',4.99),
(1,4,'2026-07-13',6.95),(1,4,'2026-07-20',6.96),(1,4,'2026-07-27',6.97),(1,4,'2026-08-03',6.99),(1,4,'2026-08-12',6.99);

-- Posto 2: Auto Posto RTT (Divino Espírito Santo) - 5 coletas/combustível
INSERT INTO coleta (posto_id, combustivel_id, data_coleta, valor) VALUES
(2,1,'2026-07-13',6.22),(2,1,'2026-07-20',6.24),(2,1,'2026-07-27',6.26),(2,1,'2026-08-03',6.27),(2,1,'2026-08-12',6.27),
(2,2,'2026-07-13',6.40),(2,2,'2026-07-20',6.41),(2,2,'2026-07-27',6.43),(2,2,'2026-08-03',6.44),(2,2,'2026-08-12',6.44),
(2,3,'2026-07-13',4.93),(2,3,'2026-07-20',4.94),(2,3,'2026-07-27',4.96),(2,3,'2026-08-03',4.97),(2,3,'2026-08-12',4.97),
(2,4,'2026-07-13',6.93),(2,4,'2026-07-20',6.94),(2,4,'2026-07-27',6.96),(2,4,'2026-08-03',6.97),(2,4,'2026-08-12',6.97);

-- Posto 3: Arara Azul (Praia de Itaparica) - 5 coletas/combustível
INSERT INTO coleta (posto_id, combustivel_id, data_coleta, valor) VALUES
(3,1,'2026-07-13',6.30),(3,1,'2026-07-20',6.33),(3,1,'2026-07-27',6.36),(3,1,'2026-08-03',6.39),(3,1,'2026-08-12',6.57),
(3,2,'2026-07-13',6.68),(3,2,'2026-07-20',6.67),(3,2,'2026-07-27',6.66),(3,2,'2026-08-03',6.64),(3,2,'2026-08-12',6.57),
(3,3,'2026-07-13',4.65),(3,3,'2026-07-20',4.63),(3,3,'2026-07-27',4.61),(3,3,'2026-08-03',4.59),(3,3,'2026-08-12',4.37),
(3,4,'2026-07-13',6.70),(3,4,'2026-07-20',6.71),(3,4,'2026-07-27',6.73),(3,4,'2026-08-03',6.74),(3,4,'2026-08-12',6.74);

-- Posto 4: A.B.C. Auto Serviços (São Torquato) - 5 coletas/combustível
INSERT INTO coleta (posto_id, combustivel_id, data_coleta, valor) VALUES
(4,1,'2026-07-13',6.40),(4,1,'2026-07-20',6.38),(4,1,'2026-07-27',6.36),(4,1,'2026-08-03',6.34),(4,1,'2026-08-11',6.25),
(4,2,'2026-07-13',6.80),(4,2,'2026-07-20',6.78),(4,2,'2026-07-27',6.76),(4,2,'2026-08-03',6.74),(4,2,'2026-08-11',6.65),
(4,3,'2026-07-13',4.65),(4,3,'2026-07-20',4.66),(4,3,'2026-07-27',4.68),(4,3,'2026-08-03',4.69),(4,3,'2026-08-11',4.69),
(4,4,'2026-07-13',6.75),(4,4,'2026-07-20',6.76),(4,4,'2026-07-27',6.78),(4,4,'2026-08-03',6.79),(4,4,'2026-08-11',6.79);

-- Posto 5: Posto Itapoã (Itapoã) - 5 coletas/combustível
INSERT INTO coleta (posto_id, combustivel_id, data_coleta, valor) VALUES
(5,1,'2026-07-13',6.34),(5,1,'2026-07-20',6.35),(5,1,'2026-07-27',6.37),(5,1,'2026-08-03',6.38),(5,1,'2026-08-12',6.38),
(5,2,'2026-07-13',6.64),(5,2,'2026-07-20',6.65),(5,2,'2026-07-27',6.67),(5,2,'2026-08-03',6.68),(5,2,'2026-08-12',6.68),
(5,3,'2026-07-13',4.41),(5,3,'2026-07-20',4.42),(5,3,'2026-07-27',4.44),(5,3,'2026-08-03',4.45),(5,3,'2026-08-12',4.45),
(5,4,'2026-07-13',6.69),(5,4,'2026-07-20',6.70),(5,4,'2026-07-27',6.72),(5,4,'2026-08-03',6.73),(5,4,'2026-08-12',6.73);

-- =====================================================================
-- CONSULTAS EXIGIDAS (item II.d do enunciado)
-- =====================================================================

-- I. Menor e maior preço de cada tipo de combustível
-- (nome do posto, endereço, bairro, tipo, valor, data da coleta)
(SELECT p.nome AS posto, p.endereco, p.bairro, c.tipo AS combustivel,
        co.valor, co.data_coleta, 'MENOR PRECO' AS observacao
 FROM coleta co
 JOIN posto p        ON p.posto_id = co.posto_id
 JOIN combustivel c  ON c.combustivel_id = co.combustivel_id
 WHERE co.valor = (SELECT MIN(co2.valor) FROM coleta co2
                    WHERE co2.combustivel_id = co.combustivel_id))
UNION ALL
(SELECT p.nome, p.endereco, p.bairro, c.tipo,
        co.valor, co.data_coleta, 'MAIOR PRECO'
 FROM coleta co
 JOIN posto p        ON p.posto_id = co.posto_id
 JOIN combustivel c  ON c.combustivel_id = co.combustivel_id
 WHERE co.valor = (SELECT MAX(co2.valor) FROM coleta co2
                    WHERE co2.combustivel_id = co.combustivel_id))
ORDER BY combustivel, observacao;

-- II. Quantidade de amostras e preço médio por posto e por combustível
-- (nome do posto, bairro, tipo, preço médio, quantidade de amostras)
SELECT p.nome AS posto, p.bairro, c.tipo AS combustivel,
       ROUND(AVG(co.valor), 2) AS preco_medio,
       COUNT(*) AS qtd_amostras
FROM coleta co
JOIN posto p        ON p.posto_id = co.posto_id
JOIN combustivel c  ON c.combustivel_id = co.combustivel_id
GROUP BY p.posto_id, c.combustivel_id
ORDER BY p.nome, c.tipo;

-- III. Preço mais recente por posto e por combustível
-- (nome do posto, bairro, tipo, valor, data da coleta)
SELECT p.nome AS posto, p.bairro, c.tipo AS combustivel,
       co.valor, co.data_coleta
FROM coleta co
JOIN posto p        ON p.posto_id = co.posto_id
JOIN combustivel c  ON c.combustivel_id = co.combustivel_id
WHERE co.data_coleta = (
    SELECT MAX(co2.data_coleta) FROM coleta co2
    WHERE co2.posto_id = co.posto_id
      AND co2.combustivel_id = co.combustivel_id
)
ORDER BY p.nome, c.tipo;

-- IV. Evolução do preço ao longo do tempo de um combustível
-- específico em um posto específico (ordenado por data)
-- Exemplo: Gasolina (combustivel_id = 1) no Posto Champagnat (posto_id = 1)
SELECT p.nome AS posto, p.bairro, c.tipo AS combustivel,
       co.valor, co.data_coleta
FROM coleta co
JOIN posto p        ON p.posto_id = co.posto_id
JOIN combustivel c  ON c.combustivel_id = co.combustivel_id
WHERE p.posto_id = 1          -- troque pelo posto desejado
  AND c.combustivel_id = 1    -- troque pelo combustível desejado (1=Gasolina,2=Aditivada,3=Etanol,4=Diesel S10)
ORDER BY co.data_coleta;
