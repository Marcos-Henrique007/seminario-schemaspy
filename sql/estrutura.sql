--Cria tabela de cursos:
CREATE TABLE cursos(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    duracao_curso INTEGER NOT NULL
);

--Cria tabela de alunos:
CREATE TABLE alunos(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

--Cria tabela de matriculas:
CREATE TABLE matriculas(
    id SERIAL PRIMARY KEY,
    alunos_id INTEGER NOT NULL, 
    cursos_id INTEGER NOT NULL, 
    data_matricula DATE NOT NULL DEFAULT CURRENT_DATE, 

    CONSTRAINT fk_aluno
        FOREIGN KEY (alunos_id) REFERENCES alunos(id),

    CONSTRAINT fk_curso
        FOREIGN KEY (cursos_id) REFERENCES cursos(id),

    CONSTRAINT uq_aluno_curso
        UNIQUE (alunos_id, cursos_id)
        
);

--Insere valores na tabela curso:
INSERT INTO cursos (nome, duracao_curso) VALUES
('Analise e Desenvolvimento de Sistemas', 3),
('Ciencia da Computacao', 5),
('Engenharia de Software', 5);

--Insere valores na tabela alunos:
INSERT INTO alunos (nome, email) VALUES
('Marcos Henrique', 'marcos@email.com'),
('Paolla Silva', 'paolla@email.com'),
('Kamilly Santos', 'kamilly@email.com'),
('Joao Pedro', 'joao@email.com');

--Insere valores na tabela matriculas:
INSERT INTO matriculas (alunos_id, cursos_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(1, 2);