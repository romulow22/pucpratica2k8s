# Use a imagem alpine do Python 3.9
FROM python:3.9-alpine

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copiar apenas o requirements.txt primeiro para aproveitar o cache de camadas
COPY ./apps/backend/requirements.txt .

# Instala as dependências do projeto
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o restante do código do backend
COPY ./apps/backend/ .

# Variável de ambiente para não bufferizar a saída do Python
ENV PYTHONUNBUFFERED=1

# Instalando pacotes complementares
RUN apk update &&  \
    apk upgrade && \
    apk add --no-cache curl wget \
    rm -rf /var/cache/apk/*

# Expõe a porta 5000 para acesso à API
EXPOSE 5000

# Inicia o servidor flask
CMD ["sh", "./start-backend.sh"]
