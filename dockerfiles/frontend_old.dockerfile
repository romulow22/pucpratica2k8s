# Use a imagem oficial do Node.js como imagem base
FROM node:20-alpine AS build

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia package.json e package-lock.json para o diretório de trabalho
COPY ./apps/frontend/package*.json ./

# Instala as dependências
RUN npm ci --only=production

# Copia todo o código da aplicação para o contêiner
COPY ./apps/frontend/ .

RUN npm install -g corepack && corepack enable

EXPOSE 4000/tcp

CMD ["yarn", "start"]
