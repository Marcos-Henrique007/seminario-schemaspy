CREATE TABLE cursos(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    duracao_curso INTEGER NOT NULL
);

CREATE TABLE alunos(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

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