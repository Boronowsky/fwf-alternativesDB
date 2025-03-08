#!/bin/bash
# setup_docker.sh - Erstellt Docker-Konfigurationsdateien für FreeWorldFirst Collector

set -e  # Skript beenden, wenn ein Befehl fehlschlägt

# Farbcodes für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Hilfsfunktionen
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Erstellt die Docker-Compose-Datei für die Entwicklungsumgebung
create_docker_compose_dev() {
    log_info "Erstelle docker-compose.dev.yml..."
    
    cat > docker-compose.dev.yml << EOL
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - REACT_APP_API_URL=http://localhost:8100/api
    depends_on:
      - backend
    networks:
      - fwf-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend:/app
      - /app/node_modules
    ports:
      - "8100:8100"
    environment:
      - NODE_ENV=development
    env_file:
      - .env.dev
    depends_on:
      - postgres
    networks:
      - fwf-network

  postgres:
    image: postgres:14-alpine
    volumes:
      - postgres-data-dev:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
    environment:
      - POSTGRES_DB=fwf_collector_dev
      - POSTGRES_USER=fwf_user
      - POSTGRES_PASSWORD=dev_password_change_me
    ports:
      - "5432:5432"
    networks:
      - fwf-network

  nginx:
    image: nginx:alpine
    ports:
      - "8100:80"
    volumes:
      - ./nginx/dev:/etc/nginx/conf.d
      - ./frontend/build:/usr/share/nginx/html
    depends_on:
      - frontend
      - backend
    networks:
      - fwf-network

networks:
  fwf-network:
    driver: bridge

volumes:
  postgres-data-dev:
EOL

    log_info "docker-compose.dev.yml wurde erstellt."
}

# Erstellt die Docker-Compose-Datei für die Produktionsumgebung
create_docker_compose_prod() {
    log_info "Erstelle docker-compose.prod.yml..."
    
    cat > docker-compose.prod.yml << EOL
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    restart: unless-stopped
    volumes:
      - frontend-build:/app/build
    depends_on:
      - backend
    networks:
      - fwf-network-prod

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    restart: unless-stopped
    env_file:
      - .env.prod
    depends_on:
      - postgres
    networks:
      - fwf-network-prod

  postgres:
    image: postgres:14-alpine
    restart: unless-stopped
    volumes:
      - postgres-data-prod:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=fwf_collector_prod
      - POSTGRES_USER=fwf_user
      - POSTGRES_PASSWORD=prod_password_change_me
    networks:
      - fwf-network-prod

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "8000:80"
    volumes:
      - ./nginx/prod:/etc/nginx/conf.d
      - frontend-build:/usr/share/nginx/html
    depends_on:
      - frontend
      - backend
    networks:
      - fwf-network-prod

networks:
  fwf-network-prod:
    driver: bridge

volumes:
  postgres-data-prod:
  frontend-build:
EOL

    log_info "docker-compose.prod.yml wurde erstellt."
}

# Erstellt Dockerfiles für das Frontend
create_frontend_dockerfiles() {
    log_info "Erstelle Frontend-Dockerfiles..."
    
    # Entwicklungsumgebung
    mkdir -p frontend
    cat > frontend/Dockerfile.dev << EOL
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOL

    # Produktionsumgebung
    cat > frontend/Dockerfile.prod << EOL
FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

RUN npm run build

# Produktions-Image
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOL

    log_info "Frontend-Dockerfiles wurden erstellt."
}

# Erstellt Dockerfiles für das Backend
create_backend_dockerfiles() {
    log_info "Erstelle Backend-Dockerfiles..."
    
    # Entwicklungsumgebung
    mkdir -p backend
    cat > backend/Dockerfile.dev << EOL
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8100

CMD ["npm", "run", "dev"]
EOL

    # Produktionsumgebung
    cat > backend/Dockerfile.prod << EOL
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

EXPOSE 8000

CMD ["npm", "start"]
EOL

    log_info "Backend-Dockerfiles wurden erstellt."
}

# Erstellt Nginx-Konfigurationen
create_nginx_configs() {
    log_info "Erstelle Nginx-Konfigurationen..."
    
    # Entwicklungsumgebung
    mkdir -p nginx/dev
    cat > nginx/dev/default.conf << EOL
server {
    listen 80;
    
    location /api {
        proxy_pass http://backend:8100;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location / {
        proxy_pass http://frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

    # Produktionsumgebung
    mkdir -p nginx/prod
    cat > nginx/prod/default.conf << EOL
server {
    listen 80;
    
    location /api {
        proxy_pass http://backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }
}
EOL

    log_info "Nginx-Konfigurationen wurden erstellt."
}

# Hauptprogramm
main() {
    log_info "Starte Erstellung der Docker-Konfigurationen..."
    create_docker_compose_dev
    create_docker_compose_prod
    create_frontend_dockerfiles
    create_backend_dockerfiles
    create_nginx_configs
    log_info "Docker-Konfigurationen wurden erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main
