# Full Stack com Dart - API de Periféricos

Projeto desenvolvido para a disciplina de Tópicos Especiais — Prof. Matheus Barquette.

Tema: gerenciamento de **Marcas e Produtos de Periféricos de Informática**.

## Arquitetura

Duas entidades com relacionamento 1:N:
- **Marca (Pai):** ID e Nome (ex: Logitech, Corsair)
- **Produto (Filho):** ID, Nome, Categoria, Preço e chave estrangeira `marcaId`

```
Flutter App → API Dart/Shelf → PostgreSQL (NeonDB)
```

## Estrutura do repositório

```
api_perifericos/
├── backend/     → API REST em Dart/Shelf
├── frontend/    → App Flutter com CRUD completo
├── postman/     → Coleção exportada do Postman
└── docs/        → Diagramas de arquitetura e navegação
```

## Como executar

### 1. Backend

Dentro da pasta `backend/`, crie um arquivo `.env`:

```env
DATABASE_URL="postgresql://usuario:senha@host/banco?sslmode=require"
JWT_SECRET="sua_chave_secreta"
```

Instale as dependências e rode o servidor:

```bash
dart pub get
dart run bin/server.dart
```

O servidor sobe em `http://localhost:8080`.

### 2. Frontend

Dentro da pasta `frontend/`:

```bash
flutter pub get
flutter run
```

Na tela de login, use as credenciais: `admin` / `1234`.

## Populando o banco (opcional)

```sql
INSERT INTO marcas (nome) VALUES ('Logitech'), ('Razer'), ('Redragon'), ('Corsair'), ('HyperX');

<<<<<<< HEAD
INSERT INTO produtos (nome, categoria, preco, marcaId) VALUES
=======
INSERT INTO produtos (nome, categoria, preco, marcaId) VALUES 
>>>>>>> 66106e4ad7a3833ba01c303ff2b6b843e35fdda4
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

<<<<<<< HEAD
## Telas do app

| Tela | Descrição |
|------|-----------|
| Login | Autenticação com JWT |
| Listagem | Lista produtos com busca por nome e filtros por categoria, marca e faixa de preço |
| Detalhe | Exibe todos os atributos do produto com opções de editar e excluir |
| Formulário | Criação e edição de produto em tela única com validação |

## Aviso de segurança

Projeto de caráter acadêmico. Credenciais hardcoded (`admin` / `1234`) apenas para demonstração.
=======
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


## Aviso sobre Segurança

Só pra disclaimer, esse projeto tem caráter **acadêmico**. Por simplicidade, as credenciais 
de autenticação ficaram hardcoded (`admin` / `1234`) 
e não há persistência de usuários no banco de dados, é apenas um demonstrativo simples
e adicional ao escopo original que o professor passou.

Em um ambiente de produção, obviamente, isso não ocorreria.
>>>>>>> 66106e4ad7a3833ba01c303ff2b6b843e35fdda4
