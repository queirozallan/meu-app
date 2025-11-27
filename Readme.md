Projeto Multi-Container - CI/CD Automatizado

Este repositório contém uma aplicação multi-container (API + Banco de Dados) com um pipeline de Integração Contínua e Entrega Contínua (CI/CD) totalmente automatizado usando GitHub Actions.

A cada push na branch main, o código é testado, a nova imagem Docker é construída, publicada no Docker Hub e, finalmente, o deploy é realizado automaticamente em uma VM de Produção (VPS).

🟢 CI/CD Status

<!-- Você encontrará o código do Badge de Status em: GitHub > Actions > seu-workflow > ... > Create status badge -->

🚀 Pipeline de Deploy (GitHub Actions)

O pipeline cicd.yml é dividido em três fases principais:

Testes (CI): Roda os testes unitários do projeto para garantir a integridade do código.

Build & Push (CI): Se os testes passarem, constrói a imagem Docker da API e a publica no Docker Hub com a tag do SHA do commit e a tag :latest.

Deploy to Server (CD): Conecta-se via SSH ao servidor de produção (VM OCI), faz o git pull dos arquivos de configuração mais recentes, e usa o docker-compose.prod.yml para fazer o pull da nova imagem do Docker Hub e recriar o container da aplicação (app) sem tempo de inatividade.

🔒 Secrets de Produção

Para que o deploy funcione, os seguintes Secrets DEVERAM ser configurados no GitHub:

Secret

Descrição

DOCKER_USERNAME

Nome de usuário no Docker Hub.

DOCKER_PASSWORD

Token de Acesso (Access Token) do Docker Hub com permissão de escrita.

IMAGE_NAME

Nome do repositório no Docker Hub (ex: queirozallan/meu-app).

SSH_HOST

IP Público da VM de Produção na OCI.

SSH_USER

Usuário de login (Ex: ubuntu).

SSH_PRIVATE_KEY

Conteúdo COMPLETO da chave privada SSH (.pem).

SERVER_APP_PATH

Caminho do projeto no servidor (Ex: /home/ubuntu/meu-app).

⚙️ Configuração Manual no Servidor (VPS)

Antes do primeiro deploy automatizado, os seguintes passos foram executados uma única vez na VM:

Instalação do Docker, Docker Compose e Git.

Clonagem inicial do repositório no diretório SERVER_APP_PATH.

Criação manual do arquivo .env com as variáveis de ambiente de produção (senhas do DB, etc.).