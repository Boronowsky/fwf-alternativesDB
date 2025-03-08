#!/bin/bash
# setup_directories.sh - Erstellt die Verzeichnisstruktur für FreeWorldFirst Collector

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

# Erstelle die Hauptverzeichnisstruktur
create_directories() {
    log_info "Erstelle Verzeichnisstruktur..."
    
    # Hauptverzeichnisse
    mkdir -p frontend
    mkdir -p backend
    mkdir -p database/migrations
    mkdir -p database/backups
    mkdir -p database/init
    mkdir -p nginx/dev
    mkdir -p nginx/prod
    mkdir -p scripts
    mkdir -p .github/workflows
    mkdir -p config/dev
    mkdir -p config/prod
    
    log_info "Verzeichnisstruktur wurde erstellt."
}

# # Kopiere alle Skripte in das Scripts-Verzeichnis
# copy_scripts() {
#     log_info "Kopiere Skripte in das Scripts-Verzeichnis..."
    
#     # Alle Skripte in das Scripts-Verzeichnis kopieren
#     cp install.sh scripts/
#     cp scripts/setup_directories.sh scripts/
#     cp scripts/setup_docker.sh scripts/
#     cp scripts/setup_frontend.sh scripts/
#     cp scripts/setup_backend.sh scripts/
#     cp scripts/setup_database.sh scripts/
#     cp scripts/setup_nginx.sh scripts/
#     cp scripts/setup_git.sh scripts/
#     cp scripts/deployToProd.sh scripts/
    
#     # Skripte ausführbar machen
#     chmod +x scripts/*.sh
    
#     log_info "Skripte wurden kopiert."
# }

# Erstellt eine .env.example-Datei als Vorlage
create_env_example() {
    log_info "Erstelle .env.example-Datei..."
    
    cat > .env.example << EOL
# Beispiel-Umgebungsvariablen für FreeWorldFirst Collector

# Allgemein
NODE_ENV=development
APP_NAME=FreeWorldFirst Collector
APP_PORT=8100  # Für Entwicklung, 8000 für Produktion

# Datenbank
DB_HOST=postgres
DB_PORT=5432
DB_NAME=fwf_collector_dev  # Für Entwicklung, fwf_collector_prod für Produktion
DB_USER=fwf_user
DB_PASSWORD=change_me_in_production

# JWT
JWT_SECRET=change_me_in_production
JWT_EXPIRY=24h

# API URLs
API_URL=http://localhost:8100/api  # Für Entwicklung, http://freeworldfirst.com:8000/api für Produktion
FRONTEND_URL=http://localhost:3000  # Für Entwicklung, http://freeworldfirst.com:8000 für Produktion
EOL

    log_info ".env.example-Datei wurde erstellt."
}

# Hauptprogramm
main() {
    log_info "Starte Erstellung der Verzeichnisstruktur..."
    create_directories
  #  copy_scripts
    create_env_example
    log_info "Verzeichnisstruktur wurde erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main