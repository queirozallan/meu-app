🚀 Projeto Multi-Container: CI/CD Automatizado (VM OCI)

Este repositório hospeda uma aplicação multi-container (assumindo uma API + um serviço opcional como DB) e demonstra um pipeline de Integração Contínua (CI) e Entrega Contínua (CD) completo, utilizando GitHub Actions para automatizar o deploy em um servidor de produção na Oracle Cloud Infrastructure (OCI).

🟢 Status do Pipeline CI/CD

O status abaixo reflete a saúde atual do repositório. O badge deve estar passing (verde), garantindo que o código foi testado, construído e deployado com sucesso na VM de produção.

[![CI/CD Pipeline](https://github.com/queirozallan/meu-app/actions/workflows/cicd.yml/badge.svg)](https://github.com/queirozallan/meu-app/actions/workflows/cicd.yml)

🏗️ 1. Arquitetura do Pipeline (.github/workflows/cicd.yml)

O arquivo de workflow define três etapas principais que são executadas automaticamente a cada git push na branch main:

1.1 Job: test (Integração Contínua)

Objetivo: Garantir a qualidade do código antes da construção.

Ações: Instala as dependências e executa o script npm test (ou equivalente).

Requisito: Esta etapa deve ser concluída com sucesso para que o processo avance.

1.2 Job: build_and_push (Construção e Publicação)

Objetivo: Criar a imagem Docker da API e publicá-la no Docker Hub.

Ações: Faz login no Docker Hub usando o Token de Acesso, constrói a nova imagem a partir do Dockerfile e a envia para o Docker Hub com duas tags: o SHA do commit (para rastreamento) e :latest.

1.3 Job: deploy (Entrega Contínua)

Objetivo: Conectar-se ao servidor de produção (VM OCI) e atualizar a aplicação para a versão recém-publicada.

Ações:

Conecta-se à VM via SSH usando a Chave Privada do GitHub Secret.

Executa o comando git pull para buscar a versão mais recente do docker-compose.prod.yml e do código no servidor.

Pára e remove o container antigo (meu-app-prod).

Executa o comando sudo docker run (usado como solução robusta em vez de docker-compose) para puxar a nova imagem e iniciar o serviço, mantendo as portas mapeadas (-p 3000:3000) e usando o arquivo .env de produção do servidor.

🔒 2. Configuração de Credenciais (Secrets)

Todas as credenciais sensíveis são protegidas usando os Secrets de Repositório do GitHub. Estes valores não devem ser expostos no código-fonte.

Secret

Descrição

Valor (Exemplo)

DOCKER_USERNAME
queirozallan

DOCKER_PASSWORD
dckr_pat_JSRqlVOdaJT9S8l3Tu_QeQvtx9A

IMAGE_NAME
queirozallan/meu-app

SSH_HOST
163.176.178.32

SSH_USER
ubuntu

SSH_PRIVATE_KEY

Conteúdo COMPLETO da chave privada SSH (.pem ou .key).

-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAs+QEiriPUW4qf+WhxKOI5qpafUGWIUZIbtDZzoapi4tITJr4
6Zb6zwb5ySClz4o3d0Atf/OvrHAajUwrUk4lZ2ZKEqnip7OzcR6UYumuJTQzvhpw
QArmHr0E4oVlnL4SeRyCPhRUIqnFkh1VilQ45w9RJ40BTd6e+y2U/h5CCCF+J0yg
CgWmRD77xHlJuasWOU4SdKSAdX6POTDiVVUsbrfw7+F+xaTF99qipLJm/V4ifPHG
W7SpztErT/fPo1oeDyLiDDnu0PM6G+R5RRID+ZHro+Oju/EJl8uR6yEt/zRpN6Lu
QJxijsIlE3wSxd0fZsBMxc3z3/iEd0Yv1j5vcwIDAQABAoIBADycCc+3aUpVZOpc
s0lulBSrtvtW2r9xT7xOj+QeyQckMYLmABGr9etE/Wn/nv4zIocCT5I5x6nAx6Ft
1XbQr5eMBk8NgDliuYXWeMZu12bflMNrYwCg63HV28x6h4btH4pAyb0i2koni1K0
oXqO7/Eh3wUFZDgZVtVoQTfxd+wG1A+3kn4o6Z/abml6+UvgIg6V6erBCYw7y5S9
Wpf4iEj6x92wnr5pKl4LmLfvG9byT8wtxD49Q6EU9XebEkumT61P1ZLVj0BO6TDe
CMQlG/yk7P3QCJ3TD6TORXccT8nMsaYOWAOgYSpBK0q+l0mXVwLamfAKpX29Ro43
R3zOCDECgYEA4c28AMmr7nUWxGfJgeyyqcDHMBcZXZ3gcIUz928xFwQ2stbEj33L
KIR7x/ZnklT0ukzVQJMnVUZOY7BHKhN5SosEnZcvhcUyNYrjRq2PrMkpz6vqZJmP
0YJBp4sd8RZOa7epeYK4TXJbp6VHZw+nibhpYpc+EAGcy5QhTygRcTkCgYEAy/J6
avGc88ZApBydkcOn3CrlXexO/wa4AsGQnf6OR14Eh/qpkpPHMfyGLsZ0ne9f+QKu
S+5OilXi07iWRbJ3e3dqz2lIe12OnUTykhY9t1CsQthkY/IkZ6GgScZmJQ9uIS0y
Fx+HQRoCGA5uhdg9t2qXLlJzBvs6sDuSKcEdIgsCgYEAxt4CAROcx+P5jDr4HuRP
KfAtva3qWifsfkziSr50FphQcEt0TAf3ABVGSwM5jogiDV4Txs6TKqhD68pZsrX5
8evjwcNgSEk3gi5zIlFDo2J733nCcp1IK7WzixKb6TPDF11m9ixpk1PvYwPOkfcY
j9OJhRo8v64b4LPybhuU2QkCgYEAxyFA/+xa9/YppVM/UlR8ME891p/lXcI8poxC
XNFwMCSPPgmzyic6BgdvKHqi4JYZ2fMRJZhP3WgQafK/3ttrKAUoJ82/dJybo9jv
E05eAf/lwfqwwplpjDnWXFI355WSTRho4QTqtdjkFIL6zPqe/9g2NodQQo/H9Myl
YNlqTZMCgYADlMJuvmiQgA74Yez2buYAkctk7vSf+Nr50rdITJN4qVOFJYHyGOXz
OoJW3Bf9QxHHdunMt8XmWDsn2lRr1tzBpR8HtPIqStYZd9SNB4U46wCO79f5PugW
+Ejk5GSbuPdOFUTHbySghlLTvqUInE30cXjdgYk+NM0ilSF6Bmjf4w==
-----END RSA PRIVATE KEY-----


SERVER_APP_PATH

Caminho do projeto no servidor.

/home/ubuntu/meu-app

⚙️ 3. Passos Manuais de Preparação do Servidor (VPS)

A VM de produção na OCI foi configurada uma única vez antes do primeiro deploy.

Infraestrutura OCI: VCN, Internet Gateway, Subnet Pública e Regras de Segurança (Security List) nas portas 22, 80, 443 e 3000 foram configuradas.

Software na VM: Docker Engine, Docker Compose plugin e Git foram instalados.

Ambiente Inicial: Conexão SSH realizada para:

Fazer git clone do repositório no diretório SERVER_APP_PATH.

Criar o arquivo .env com variáveis de ambiente de produção (senhas do DB, etc.). Este arquivo é ignorado pelo Git, garantindo a segurança das credenciais.

🧪 4. Como Testar e Verificar o Deploy

Você pode verificar o status do deploy de duas maneiras: via web e via SSH.

4.1. Verificação de Acesso (Web)

A aplicação está rodando na porta 3000. Use o seu navegador para acessar:

[http://163.176.178.32:3000](http://163.176.178.32:3000)


Resultado Esperado: A interface ou endpoint da sua API deve carregar, confirmando que o tráfego da Internet está chegando na VM, passando pelo Security List e sendo roteado para o container Docker.

4.2. Verificação do Container (SSH)

Para verificar o status da aplicação e logs após um deploy:

Conecte-se via SSH:

ssh -i /caminho/chave.pem ubuntu@163.176.178.32


Verifique se o container está ativo:

sudo docker ps


Esperado: O container chamado meu-app-prod deve estar listado com o status Up.

Verifique os Logs da Aplicação:

sudo docker logs meu-app-prod


Esperado: Você deve ver os logs da API, confirmando que ela iniciou sem erros de banco de dados ou ambiente.
