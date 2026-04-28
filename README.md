# Full Stack com Dart - API de Periféricos

Projeto desenvolvido para a disciplina de Tópicos Especiais orientado pelo professor Matheus Barquette. Consiste em uma API simples em Dart consumida por um frontend Flutter para listagem dos itens. 

Tema escolhido foi o gerenciamento de **Marcas e Produtos de Periféricos de Informática**.

## Arquitetura e Entidades
Duas entidades com relacionamento 1:N:
* **Marca (Pai):** Possui um ID e um Nome (Ex: Logitech, Corsair).
* **Produto (Filho):** Possui ID, Nome, Categoria, Preço e uma chave estrangeira (`marcaId`) que vincula a uma Marca.

O projeto é dividido em:
1.  **Backend (Dart + Shelf):** API RESTful que gerencia o CRUD das entidades, persistência no banco de dados PostgreSQL e autenticação via JWT.
2.  **Frontend (Flutter):** Aplicação que consome a API para listar os produtos.

---

## Como executar o projeto

### 1. Configurando o Banco de Dados (Backend)
O projeto utiliza um banco PostgreSQL. As tabelas são geradas automaticamente na primeira execução, mas você precisa fornecer a string de conexão.

1. Criar um arquivo `.env` na raiz da pasta `backend`.
2. Configure suas variáveis de ambiente com uma conexão local (o código detecta conexões `localhost` e desativa o SSL automaticamente) e um segredo para o token:

```env
DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/NOME_DO_BANCO"
JWT_SECRET="qualquer_chave_secreta"
```

### 2. Populando o Banco pra Teste (Opcional)
Como o código apenas cria as tabelas, segue um script com alguns dados pra popular elas:

```sql
INSERT INTO marcas (nome) VALUES ('Logitech'), ('Razer'), ('Redragon'), ('Corsair'), ('HyperX');

INSERT INTO produtos (nome, categoria, preco, marcaId) VALUES 
('Mouse G Pro X Superlight', 'Mouse', 899.90, 1),
('Teclado Mecânico G915', 'Teclado', 1299.00, 1),
('Mouse DeathAdder V3', 'Mouse', 450.00, 2),
('Headset BlackShark V2', 'Headset', 650.00, 2),
('Teclado Kumara K552', 'Teclado', 220.00, 3),
('Mouse Cobra M711', 'Mouse', 130.00, 3),
('Headset HS80 RGB', 'Headset', 750.00, 4),
('Microfone QuadCast S', 'Microfone', 999.00, 5),
('Headset Cloud II', 'Headset', 550.00, 5);
```

### 3. Rodando o Servidor (Backend)
1. Dentro da pasta `backend` baixe as dependências: `dart pub get`
2. Inicie o servidor: `dart run bin/server.dart`
3. Mantenha o terminal aberto.

### 4. Rodando o App (Frontend)
1. Em um novo terminal, dentro da pasta `frontend`, também baixe as dependências `flutter pub get`
2. Inicie a aplicação no navegador: `flutter run -d chrome`

---

## Testes da API (Postman)
Na raiz do projeto, na pasta `postman/`, temos o arquivo .json com a collection do Postman. 

Importe este arquivo no seu Postman e siga as instruções dele.
