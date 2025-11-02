# --- Etapa 1: Builder ---
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Instala todas as dependências (dev e prod)
RUN npm install

COPY . .

# Gera o Prisma Client
RUN npx prisma generate

# Compila o projeto NestJS (gera /app/dist)
RUN npm run build

# --- Etapa 2: Produção ---
FROM node:20-alpine AS production

WORKDIR /app

COPY package*.json ./

# Instala apenas dependências de produção
RUN npm install --omit=dev

# Copia os artefatos necessários da etapa de build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Copia migrations (caso precise)
COPY --from=builder /app/prisma/migrations ./prisma/migrations

# Garante que o Prisma Client esteja gerado
RUN npx prisma generate

ENV NODE_ENV=production
EXPOSE 3333

# Roda migrações e depois inicia
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]
