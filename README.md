[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/7NMOLXjY)

# API RESTful To-Do List com Scotty e SQLite

## Requisitos

- [GHC](https://www.haskell.org/ghc/) (>= 8.0)
- [Cabal](https://www.haskell.org/cabal/) (>= 2.0)
- SQLite3 instalado no sistema

## Instalação das dependências

Abra o terminal na pasta do projeto e execute:

```sh
cabal update
cabal build
```

Se for rodar testes, instale também:

```sh
cabal install --lib hspec
```

## Como executar o servidor

```sh
cabal run
```

O servidor ficará disponível em [http://localhost:3000](http://localhost:3000).

## Como executar os testes

```sh
cabal test
```

Ou, para rodar manualmente:

```sh
runhaskell Test.hs
```

## Exemplos de uso

- **GET** `/tasks`  
  Lista todas as tarefas.

- **GET** `/tasks/:id`  
  Busca uma tarefa pelo id.

- **POST** `/tasks`  
  Cria uma nova tarefa.  
  Exemplo de corpo JSON:
  ```json
  {
    "title": "BRUNA",
    "description": "sei lá",
    "done": false,
    "status": "not started"
  }
  ```

- **PUT** `/tasks/:id`  
  Atualiza uma tarefa existente.

- **DELETE** `/tasks/:id`  
  Remove uma tarefa.

## Observações

- O banco de dados é criado automaticamente no arquivo `tasks.db`.
- O campo `taskId` é gerado automaticamente pelo backend.

---
