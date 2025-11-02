# Estágio 1: Build (Construção)
# Use uma imagem Node LTS (Long Term Support) com Alpine para um tamanho menor
FROM node:20-alpine AS builder

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Copia os arquivos de configuração de dependências
# O wildcard (*) garante que tanto package.json quanto package-lock.json sejam copiados
COPY package*.json ./

# Copia o diretório prisma para gerar o cliente
COPY prisma ./prisma/

# Instala todas as dependências (incluindo as de desenvolvimento necessárias para o build e o Prisma)
RUN npm install

# Copia o restante dos arquivos do projeto (o .dockerignore é importante aqui para excluir node_modules local, etc.)
COPY . .

# Gera o Prisma Client e faz o build da aplicação NestJS
# O 'npm run build' irá criar a pasta 'dist'
RUN npx prisma generate && npm run build

# ---

# Estágio 2: Produção (Execução)
# Use uma imagem Node Alpine limpa para o ambiente de execução
FROM node:20-alpine AS production

# Define o diretório de trabalho
WORKDIR /usr/src/app

# Adiciona o pacote 'openssl' (necessário para o Prisma na imagem Alpine)
RUN apk add --no-cache openssl

# Copia apenas os arquivos necessários para a execução
COPY package*.json ./
COPY prisma ./prisma/

# Instala APENAS as dependências de produção
RUN npm install --omit=dev

# Copia o resultado do build do estágio anterior (a pasta 'dist')
COPY --from=builder /usr/src/app/dist ./dist

# Garante que os arquivos binários do Prisma sejam copiados corretamente, especialmente para Alpine
# O caminho exato pode variar. Se encontrar problemas, pode ser necessário ajustar esta linha ou usar 'npx prisma generate' no estágio de produção.
# A forma mais robusta é re-gerar no estágio de produção ou usar uma solução como a sugerida abaixo.

# Comando para gerar o cliente Prisma na produção (necessário para garantir que o binário correto seja baixado/linkado para Alpine)
# É fundamental que o 'schema.prisma' esteja disponível neste estágio.
# Se o EasyPanel não executar a migração (como é comum), você precisará garantir que ela ocorra.
RUN npx prisma generate --schema=./prisma/schema.prisma

# O seu 'start:prod' é 'node dist/main', que é o que usaremos.
# Certifique-se de que a variável de ambiente DATABASE_URL esteja configurada no EasyPanel.
# O EasyPanel deve expor a porta 3000 por padrão, mas é bom documentar:
EXPOSE 3000

# O comando para iniciar a aplicação
# Você pode considerar usar 'npm run start:prod' se ele for robusto, mas 'node dist/main' é mais direto.
CMD [ "node", "dist/main" ]