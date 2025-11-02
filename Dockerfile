# Estágio 1: Build (Construção)
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copia e instala dependências de desenvolvimento e produção
COPY package*.json ./
COPY prisma ./prisma/
RUN npm install
COPY . .

# Gera o Prisma Client e faz o build da aplicação NestJS
RUN npx prisma generate && npm run build

# ---

# Estágio 2: Produção (Execução)
FROM node:20-alpine AS production

WORKDIR /usr/src/app

# Instala openssl (necessário para o Prisma Client em Alpine)
RUN apk add --no-cache openssl

# Copia os arquivos necessários para execução
COPY package*.json ./
COPY prisma ./prisma/

# Instala APENAS as dependências de produção
RUN npm install --omit=dev

# Copia o build da aplicação (pasta 'dist')
COPY --from=builder /usr/src/app/dist ./dist

# Gera o Prisma Client (garantindo o binário correto para o Alpine)
# É importante que o schema.prisma esteja copiado acima.
RUN npx prisma generate

# EXPÕE A PORTA (padrão do Nest é 3000)
EXPOSE 3000

# COMANDO DE EXECUÇÃO FINAL: Roda as migrações do Prisma e depois inicia a aplicação.
# O novo script 'start:migrate:prod' garante que a aplicação só suba com o banco migrado.
CMD [ "npm", "run", "start:migrate:prod" ]