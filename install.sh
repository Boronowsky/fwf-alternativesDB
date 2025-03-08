#!/bin/bash
# install.sh - Hauptinstallationsskript für FreeWorldFirst Collector

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

# Überprüfe, ob Docker und Docker Compose installiert sind
check_docker() {
    log_info "Überprüfe Docker-Installation..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker ist nicht installiert. Bitte installieren Sie Docker und versuchen Sie es erneut."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose ist nicht installiert. Bitte installieren Sie Docker Compose und versuchen Sie es erneut."
        exit 1
    fi
    
    log_info "Docker und Docker Compose sind installiert."
}

# Hauptprogramm
main() {
    log_info "Starte Installation von FreeWorldFirst Collector..."
    
    # Überprüfe Voraussetzungen
    check_docker
    
    # Führe die einzelnen Setup-Skripte aus
    bash ./scripts/setup_directories.sh
    bash ./scripts/setup_docker.sh
    bash ./scripts/setup_frontend.sh
    bash ./scripts/setup_backend.sh
    bash ./scripts/setup_database.sh
    bash ./scripts/setup_nginx.sh
    bash ./scripts/setup_git.sh
    
    log_info "Installation abgeschlossen!"
    log_info "Entwicklungsumgebung: http://localhost:8100"
    log_info "Produktionsumgebung: http://freeworldfirst.com:8000"
    log_info "Um die Entwicklungsumgebung zu starten, führen Sie aus: docker-compose -f docker-compose.dev.yml up"
    log_info "Um in die Produktion zu deployen, führen Sie aus: bash ./scripts/deployToProd.sh"
}

# Führe das Hauptprogramm aus
main
