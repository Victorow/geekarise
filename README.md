GeekArise - E-commerce de Colecionáveis
GeekArise é um protótipo de aplicativo de e-commerce completo, desenvolvido em Flutter, focado no universo geek e na cultura pop. A plataforma foi criada para ser uma loja virtual de action figures, réplicas de personagens, mangás e outros itens colecionáveis do mundo de animes e mangakás.

O projeto demonstra a construção de uma experiência de compra mobile fluida, desde a navegação no catálogo de produtos até a finalização do pedido, com uma interface limpa, moderna e performática.


Exportar para as Planilhas
✨ Funcionalidades
O aplicativo foi projetado para incluir todas as funcionalidades essenciais de um e-commerce moderno:

🛍️ Catálogo de Produtos:
Tela inicial com produtos em destaque e categorias.
Listagem de produtos com rolagem infinita.
Tela de detalhes do produto com galeria de imagens, descrição, preço e avaliações.
🔍 Busca e Filtragem:
Barra de busca para encontrar produtos por nome.
Filtros por categoria, preço e popularidade.
🛒 Carrinho de Compras:
Adicionar, remover e atualizar a quantidade de itens.
Cálculo automático do subtotal e total.
💳 Processo de Checkout:
Fluxo de checkout simulado com etapas para seleção de endereço e método de pagamento.
👤 Autenticação e Perfil de Usuário:
Login e cadastro de novos usuários (com validação de formulários).
Área de perfil para o usuário visualizar seu histórico de pedidos.
Gerenciamento de informações pessoais e endereços de entrega.
❤️ Lista de Favoritos (Wishlist):
Funcionalidade para salvar produtos em uma lista de desejos para compra futura.
⭐ Avaliações e Comentários:
Sistema para que usuários possam avaliar e comentar nos produtos que compraram.
🛠️ Tecnologias e Arquitetura
O projeto foi desenvolvido utilizando o ecossistema Flutter e pode ser integrado com backends como o Firebase.

Linguagem: Dart
Framework: Flutter
Gerenciamento de Estado: Provider / BLoC / Riverpod 
Navegação: Navigator 2.0 (GoRouter / AutoRoute) 
Backend (Sugestão de integração):
Firebase: Para Autenticação, Firestore (banco de dados NoSQL) e Storage (armazenamento de imagens).
Supabase: Alternativa ao Firebase com banco de dados PostgreSQL.
Dependências Principais:
http / dio para requisições de API.
provider ou flutter_bloc para gerenciamento de estado.
shared_preferences para armazenamento local simples.
🚀 Como Executar o Projeto
Siga os passos abaixo para configurar e rodar o ambiente de desenvolvimento localmente.

Pré-requisitos
Flutter SDK (versão 3.x ou superior)
Um emulador Android, simulador iOS ou um navegador (Chrome) para rodar o app.
Um projeto de backend configurado (ex: Firebase).
1. Clonar o Repositório
Bash

git clone https://github.com/Victorow/geekarise.git
cd geekarise
2. Configurar o Backend
Este projeto requer um backend para gerenciar produtos, usuários e pedidos. As instruções abaixo são um guia para configuração com Firebase:

Crie um novo projeto no console do Firebase.
Adicione um aplicativo Flutter ao seu projeto Firebase seguindo as instruções do FlutterFire: flutterfire configure.
Ative os serviços necessários:
Authentication: Habilite o método de "E-mail/Senha".
Firestore Database: Crie um banco de dados NoSQL para armazenar produtos, pedidos, etc.
Storage: Habilite para armazenar as imagens dos produtos.
Popule o Firestore com algumas coleções e documentos de exemplo para produtos e categorias.
3. Configurar o Frontend (Flutter)
Após configurar o Firebase com o flutterfire, o arquivo de configuração firebase_options.dart será gerado automaticamente.
Instale todas as dependências do projeto:


flutter pub get
Execute o aplicativo:


flutter run
O Flutter irá compilar e instalar o aplicativo no dispositivo/emulador selecionado.
