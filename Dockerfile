# --- Etapa 1: Builder ---
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Instala dependências (todas, incluindo dev)
RUN npm install

COPY . .

# Gera o Prisma Client
RUN npx prisma generate

# Compila o projeto NestJS
RUN npm run build

# Debug opcional: mostra se dist foi gerado
RUN echo "=== Conteúdo da pasta dist ===" && ls -la dist

# --- Etapa 2: Produção ---
FROM node:20-alpine AS production

WORKDIR /app

COPY package*.json ./

# Instala apenas dependências de produção
RUN npm install --omit=dev

# Copia artefatos necessários da etapa de build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

ENV NODE_ENV=production
EXPOSE 3333

# Garante que o Prisma Client esteja funcional
RUN npx prisma generate

# Debug: lista o dist antes de iniciar
CMD ["sh", "-c", "echo '=== Conteúdo do dist no container final ===' && ls -la dist && npx prisma migrate deploy && node dist/main.js"]
