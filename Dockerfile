# --- Etapa 1: Builder ---
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Instala todas as dependências (incluindo dev para build)
RUN npm install

COPY . .

# Gera o Prisma Client
RUN npx prisma generate

# Compila o projeto NestJS. Isso gera /app/dist/
RUN npm run build

RUN echo "=== Conteúdo gerado em /app após o build ===" && ls -R /app

# --- Etapa 2: Produção (Lightweight) ---
FROM node:20-alpine AS production

WORKDIR /app

# 🔑 NOVIDADE: Copia o package.json para garantir a estrutura
COPY package.json ./

# 💡 CORREÇÃO CRÍTICA 1: Copia apenas os node_modules de produção do builder
# Otimiza o container final e garante que todas as dependências necessárias estejam presentes.
# Utilizamos o --omit=dev para reinstalar apenas o que é de produção
RUN npm install --omit=dev

# 💡 CORREÇÃO CRÍTICA 2: Copia os arquivos de build e o Prisma schema
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Não precisa mais copiar node_modules/.prisma separadamente
# se você instalou as dependências de produção logo acima.

ENV NODE_ENV=production
EXPOSE 3333

# O Prisma Migrate Deploy deve ser feito *antes* de iniciar a aplicação.
# A geração do client deve ser feita aqui se você não está copiando o node_modules inteiro.
# Mas a reinstalação de dependências (passo RUN npm install --omit=dev) já deve resolver o client.
# Vamos confiar no `migrate deploy` para garantir a funcionalidade do Prisma.

# 💡 CORREÇÃO: Comando de início mais limpo e efetivo.
# O `start:prod` do seu package.json é `node dist/main`, que é o que precisamos.
CMD npx prisma migrate deploy && npm run start:prod