# Use a imagem oficial do Node.js como imagem base
FROM node:20-alpine AS build

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia package.json e package-lock.json para o diretório de trabalho
COPY ./apps/frontend/package*.json ./

# Instala as dependências
RUN npm ci --only=production

# Atualiza o browserlist-db
RUN npx update-browserslist-db@latest

# Copia todo o código da aplicação para o contêiner
COPY ./apps/frontend/ .

# Define a variável de ambiente para a URL do backend
ARG REACT_APP_BACKEND_URL
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL:-http://localhost} 

# Compila o aplicativo React para produção
RUN npm run build

# Usa o Nginx como servidor de produção
FROM nginx:1.27-alpine

# Copia o aplicativo React compilado para o diretório do servidor web do Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copia o arquivo nginx.conf e substitui o conteúdo de /etc/nginx/nginx.conf
COPY ./apps/frontend/nginx.conf /etc/nginx/nginx.conf

# Expõe a porta 80 para o servidor Nginx
EXPOSE 80/tcp

# Inicia o Nginx quando o contêiner for executado
CMD ["nginx", "-g", "daemon off;"]
