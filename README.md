# Seminário: Modelagem e documentação de bancos de dados com SchemaSpy

Projeto de demonstração do seminário **T8 — Modelagem com SchemaSpy (G5)**.

O objetivo é apresentar o SchemaSpy, explicar como ele analisa a estrutura de um banco de dados e demonstrar a geração automática de documentação HTML e diagramas a partir de um banco PostgreSQL.

## 1. O que é o SchemaSpy?

O [SchemaSpy](https://schemaspy.org/) é uma ferramenta de linha de comando que analisa os metadados de um banco de dados e gera documentação navegável em HTML. O relatório pode apresentar tabelas, colunas, tipos de dados, chaves, índices e relacionamentos identificados no banco.

**Importante:** o SchemaSpy não é um sistema gerenciador de banco de dados e não substitui o PostgreSQL. Ele consulta a estrutura de um banco que já existe e produz documentação para facilitar seu entendimento e manutenção.

## 2. Tecnologias utilizadas

- **PostgreSQL 17:** banco relacional usado na prova de conceito.
- **SchemaSpy 7.0.2:** ferramenta que analisa e documenta o esquema.
- **Docker e Docker Compose (opcional):** permitem executar os serviços em containers.
- **Java 17 ou superior:** necessário para executar o SchemaSpy diretamente no computador, sem Docker.
- **Driver JDBC do PostgreSQL:** permite que o SchemaSpy se conecte ao PostgreSQL na execução sem Docker.

## 3. Estrutura do projeto

```text
seminario-schemaspy/
├── docker-compose.yml
├── README.md
├── sql/
│   └── estrutura.sql
└── output/
    └── (documentação HTML gerada pelo SchemaSpy)
```

A pasta `output` recebe os arquivos gerados e pode estar vazia antes da primeira execução.

## 4. Banco utilizado na PoC

A demonstração usa um pequeno sistema acadêmico com três tabelas:

| Tabela | Finalidade |
|---|---|
| `alunos` | Armazena os alunos. |
| `cursos` | Armazena os cursos. |
| `matriculas` | Relaciona alunos e cursos. |

A tabela `matriculas` possui chaves estrangeiras para `alunos` e `cursos`. Assim, o SchemaSpy consegue identificar os relacionamentos a partir das constraints existentes no PostgreSQL.

## 5. Executar com Docker (recomendado)

Nesta opção, o PostgreSQL e o SchemaSpy são executados em containers. Não é necessário instalar PostgreSQL, Java, driver JDBC ou pgAdmin no Windows. É necessário ter Docker Desktop com Docker Compose disponível.

### 5.1. Clonar o repositório

No PowerShell:

```powershell
git clone https://github.com/Marcos-Henrique007/seminario-schemaspy.git
cd seminario-schemaspy
```

### 5.2. Iniciar o PostgreSQL

```powershell
docker compose up -d postgres
```

O serviço disponibiliza o PostgreSQL na porta **5433 do computador** e na porta **5432 dentro da rede Docker**.

Configuração da demonstração:

| Parâmetro | Valor |
|---|---|
| Banco | `faculdade` |
| Usuário | `schemaspy` |
| Senha | `schemaspy123` |
| Host para outros containers | `postgres` |
| Porta interna | `5432` |
| Porta no Windows | `5433` |

> Essas credenciais são apenas para demonstração local. Não utilize essa senha em ambientes de produção.

### 5.3. Criar as tabelas e inserir os dados

O arquivo `sql/estrutura.sql` é montado no container em `/scripts/estrutura.sql`. Execute:

```powershell
docker compose exec postgres psql -U schemaspy -d faculdade -f /scripts/estrutura.sql
```

O script cria as tabelas e insere registros de exemplo. Ele foi feito para uma primeira execução em um banco vazio. Se já tiver sido executado, não o execute novamente sem antes remover as tabelas existentes, pois poderão ocorrer erros de tabelas duplicadas ou registros repetidos.

Para conferir as tabelas:

```powershell
docker compose exec postgres psql -U schemaspy -d faculdade -c "\dt"
```

Para abrir o terminal SQL interativo:

```powershell
docker compose exec postgres psql -U schemaspy -d faculdade
```

Dentro do PostgreSQL, use `\q` para sair.

### 5.4. Gerar a documentação com SchemaSpy

```powershell
docker compose run --rm schemaspy
```

O serviço SchemaSpy aguarda o PostgreSQL ficar saudável, conecta-se ao serviço pelo nome `postgres`, analisa o schema `public` e grava os arquivos na pasta local `output`.

A imagem Docker do SchemaSpy define `/output` como diretório de saída e inclui drivers para bancos comuns, incluindo PostgreSQL. A imagem pode fornecer esse diretório por configuração padrão; por isso, não acrescente outro `-o` ao comando sem verificar a configuração da imagem. A repetição dessa opção pode causar o erro **"Can only specify option -o once"**.

### 5.5. Abrir o relatório

Depois que a execução terminar:

```powershell
explorer .\output
```

Abra o arquivo `index.html` no navegador.

O relatório permite navegar pelas tabelas, visualizar colunas e constraints e consultar os diagramas gerados.

### 5.6. Parar o ambiente

```powershell
docker compose down
```

Esse comando remove os containers e a rede, mas mantém o volume de dados. Para apagar também o banco de demonstração e seus dados:

```powershell
docker compose down -v
```

**Atenção:** `down -v` apaga o volume persistente do PostgreSQL. Use somente se realmente quiser reiniciar a demonstração do zero.

## 6. Executar sem Docker (Windows)

Nesta opção, o PostgreSQL e o SchemaSpy são executados diretamente no Windows. Você pode instalar um PostgreSQL local ou utilizar um servidor PostgreSQL já disponível. Não é necessário instalar pgAdmin: o banco pode ser administrado pelo terminal com `psql`.

### 6.1. Instalar os pré-requisitos

1. **PostgreSQL:** baixe o instalador para Windows em [postgresql.org/download/windows](https://www.postgresql.org/download/windows/). Durante a instalação, anote a senha definida para o usuário do banco e a porta configurada (normalmente `5432`). O pgAdmin é opcional.
2. **Java 17 ou superior:** instale um JDK/JRE compatível, por exemplo pelo [Eclipse Adoptium](https://adoptium.net/). Depois, abra um novo PowerShell e confira:

   ```powershell
   java -version
   ```

3. **SchemaSpy:** abra [as versões do SchemaSpy no GitHub](https://github.com/schemaspy/schemaspy/releases) e baixe o JAR executável da versão desejada. Para reproduzir esta PoC, utilize a versão **7.0.2** e prefira o artefato `app` (JAR com dependências da aplicação). Salve-o, por exemplo, em `D:\seminario-schemaspy\tools\schemaspy-7.0.2-app.jar`.
4. **Driver JDBC do PostgreSQL:** baixe o arquivo JAR em [jdbc.postgresql.org/download](https://jdbc.postgresql.org/download/). Salve-o, por exemplo, em `D:\seminario-schemaspy\tools\postgresql.jar`. O nome real do arquivo baixado pode conter a versão; use esse nome nos comandos.

> A distribuição JAR do SchemaSpy não inclui os drivers JDBC. Por isso, na execução sem Docker, é necessário baixar o driver do PostgreSQL separadamente.

### 6.2. Criar o banco no PostgreSQL local

Abra o SQL Shell (`psql`) instalado com o PostgreSQL ou use o PowerShell se o executável `psql` estiver no PATH.

Exemplo usando o PowerShell, conectando ao servidor local:

```powershell
psql -h localhost -p 5432 -U postgres -d postgres
```

No prompt do PostgreSQL, crie o usuário e o banco de demonstração:

```sql
CREATE USER schemaspy WITH PASSWORD 'schemaspy123';
CREATE DATABASE faculdade OWNER schemaspy;
\q
```

Se o usuário ou banco já existirem, não repita os comandos de criação. Conecte-se ao banco `faculdade` e execute o script SQL a partir da pasta raiz do repositório:

```powershell
psql -h localhost -p 5432 -U schemaspy -d faculdade -f .\sql\estrutura.sql
```

Se o PostgreSQL estiver em outra máquina, substitua `localhost` pelo endereço correto do servidor.

### 6.3. Executar o SchemaSpy localmente

A partir da pasta raiz do projeto, ajuste os caminhos dos arquivos JAR para os locais em que foram salvos. Exemplo no PowerShell:

```powershell
java -jar .\tools\schemaspy-7.0.2-app.jar `
  -t pgsql `
  -dp .\tools\postgresql.jar `
  -host localhost `
  -port 5432 `
  -db faculdade `
  -u schemaspy `
  -p schemaspy123 `
  -s public `
  -o .\output `
  -vizjs
```

Explicação dos principais parâmetros:

| Parâmetro | Significado |
|---|---|
| `-t pgsql` | Tipo de banco de dados: PostgreSQL. |
| `-dp` | Caminho do driver JDBC. |
| `-host` | Endereço do servidor PostgreSQL. |
| `-port` | Porta do PostgreSQL. |
| `-db` | Nome do banco de dados. |
| `-u` e `-p` | Usuário e senha do banco. |
| `-s public` | Schema que será analisado. |
| `-o` | Pasta de saída da documentação. |
| `-vizjs` | Utiliza o Viz.js incluído no SchemaSpy para gerar diagramas, sem exigir instalação separada do Graphviz. |

Ao executar localmente, o SchemaSpy roda no Windows. Portanto, se o PostgreSQL estiver no Docker com o mapeamento deste projeto, utilize `localhost` e a porta externa `5433`, e não `postgres:5432`.

### 6.4. Visualizar o relatório

```powershell
explorer .\output
```

Abra `index.html` no navegador.

## 7. Docker x execução local

| Aspecto | Docker | Sem Docker |
|---|---|---|
| PostgreSQL | Container | Instalação local ou servidor existente |
| SchemaSpy | Container | Java + arquivo JAR |
| Driver JDBC | Já incluído na imagem usada | Download separado |
| Java no Windows | Não é necessário | Necessário |
| Configuração inicial | Docker Compose | Instalação e configuração manual |
| pgAdmin | Não é necessário | Não é necessário |

Para reproduzir a PoC deste repositório, a execução com Docker é a opção mais simples e padronizada. A execução local ajuda a entender os componentes necessários para o funcionamento da ferramenta.

## 8. Conceitos demonstrados

- **Schema:** conjunto lógico de objetos do banco, como tabelas e views. Nesta PoC, analisamos o schema `public`.
- **Tabela:** estrutura que organiza registros em linhas e colunas.
- **Chave primária (PK):** identifica exclusivamente cada registro.
- **Chave estrangeira (FK):** estabelece uma referência entre tabelas.
- **Relacionamento:** associação entre entidades/tabelas. As FKs de `matriculas` apontam para `alunos` e `cursos`.
- **JDBC:** API Java utilizada para a comunicação com bancos de dados relacionais por meio de drivers.
- **Documentação automática:** geração de páginas e diagramas a partir dos metadados existentes no banco.

## 9. Problemas comuns

### Container PostgreSQL não inicia

Confira os containers e logs:

```powershell
docker compose ps
docker compose logs postgres
```

### Porta 5433 já está em uso

Altere o lado esquerdo do mapeamento no `docker-compose.yml`, por exemplo de `5433:5432` para `5434:5432`. A porta interna continua sendo `5432`. Para conectar pelo Windows, use a nova porta externa.

### SchemaSpy não consegue conectar ao PostgreSQL no Docker

Quando SchemaSpy também está em container na rede do Compose, use o host `postgres` e a porta interna `5432`. Não use `localhost` nesse caso.

Quando SchemaSpy roda diretamente no Windows e PostgreSQL está no Docker, use `localhost` e a porta publicada no Windows, neste projeto `5433`.

### Erro de autenticação

Confira banco, usuário e senha. No Docker, as variáveis `POSTGRES_USER`, `POSTGRES_PASSWORD` e `POSTGRES_DB` são aplicadas na inicialização do volume. Alterar essas variáveis depois que o volume já foi criado não altera automaticamente a senha do usuário existente.

### Erro de tabela já existente ou chave duplicada ao executar o SQL

O script de demonstração é destinado à primeira execução em um banco vazio. Se quiser reiniciar a PoC Docker do zero, pare o ambiente e remova o volume com:

```powershell
docker compose down -v
docker compose up -d postgres
docker compose exec postgres psql -U schemaspy -d faculdade -f /scripts/estrutura.sql
```

Isso apaga os dados do banco de demonstração.

### Erro "Can only specify option -o once"

A imagem Docker utilizada pode definir o diretório `/output` por padrão. Use o comando Docker documentado para o projeto, sem adicionar outro `-o` até confirmar a configuração da imagem.

## 10. Referências oficiais

- [Site oficial do SchemaSpy](https://schemaspy.org/)
- [Repositório oficial e versões](https://github.com/schemaspy/schemaspy)
- [Documentação de instalação](https://schemaspy.readthedocs.io/en/latest/installation.html)
- [Parâmetros de linha de comando](https://schemaspy.readthedocs.io/en/latest/configuration/commandline.html)
- [Imagem oficial no Docker Hub](https://hub.docker.com/r/schemaspy/schemaspy)
- [Download do PostgreSQL](https://www.postgresql.org/download/)
- [Download do Java (Eclipse Adoptium)](https://adoptium.net/)
- [Driver JDBC do PostgreSQL](https://jdbc.postgresql.org/download/)

---

**Seminário T8 — Modelagem com SchemaSpy | Grupo G5**
