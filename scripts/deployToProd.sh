#!/bin/bash
# deployToProd.sh - Deployment-Skript für FreeWorldFirst Collector

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

# Voraussetzungen überprüfen
check_prerequisites() {
    log_info "Überprüfe Voraussetzungen..."
    
    # Überprüfe, ob Git installiert ist
    if ! command -v git &> /dev/null; then
        log_error "Git ist nicht installiert. Bitte installieren Sie Git und versuchen Sie es erneut."
        exit 1
    fi
    
    # Überprüfe, ob Docker und Docker Compose installiert sind
    if ! command -v docker &> /dev/null; then
        log_error "Docker ist nicht installiert. Bitte installieren Sie Docker und versuchen Sie es erneut."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose ist nicht installiert. Bitte installieren Sie Docker Compose und versuchen Sie es erneut."
        exit 1
    fi
    
    log_info "Alle Voraussetzungen sind erfüllt."
}

# Git-Status überprüfen und Änderungen commiten
check_git_status() {
    log_info "Überprüfe Git-Status..."
    
    # Überprüfe, ob es ungespeicherte Änderungen gibt
    if ! git diff --quiet || ! git diff --staged --quiet; then
        log_warn "Es gibt ungespeicherte Änderungen."
        
        # Frage den Benutzer, ob die Änderungen committet werden sollen
        read -p "Möchten Sie alle Änderungen commiten? (j/N) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Jj]$ ]]; then
            # Commit-Nachricht vom Benutzer abfragen
            read -p "Commit-Nachricht: " commit_message
            
            # Änderungen commiten
            git add .
            git commit -m "$commit_message"
            
            log_info "Änderungen wurden committet."
        else
            log_error "Deployment abgebrochen. Bitte speichern Sie Ihre Änderungen vor dem Deployment."
            exit 1
        fi
    else
        log_info "Keine ungespeicherten Änderungen gefunden."
    fi
}

# Backup der Produktionsdatenbank erstellen
backup_database() {
    log_info "Erstelle Backup der Produktionsdatenbank..."
    
    # Überprüfe, ob der Produktionscontainer läuft
    if docker ps | grep -q "postgres"; then
        # Führe das Backup-Skript aus
        bash database/backup.sh fwf_collector_prod fwf_user
        
        log_info "Backup der Produktionsdatenbank wurde erstellt."
    else
        log_warn "Produktionsdatenbank-Container ist nicht aktiv. Kein Backup erstellt."
    fi
}

# Frontend für Produktion bauen
build_frontend() {
    log_info "Baue Frontend für Produktion..."
    
    # Entwicklungsumgebung stoppen, falls sie läuft
    if docker ps | grep -q "fwf_frontend"; then
        log_info "Stoppe laufende Entwicklungsumgebung..."
        docker-compose -f docker-compose.dev.yml down
    fi
    
    # Starte nur den Frontend-Container im Entwicklungsmodus
    docker-compose -f docker-compose.dev.yml up -d frontend
    
    # Warte kurz, bis der Container gestartet ist
    sleep 5
    
    # Führe den Build-Befehl im Container aus
    docker exec -i fwf_frontend npm run build
    
    # Stoppe den Frontend-Container wieder
    docker-compose -f docker-compose.dev.yml stop frontend
    
    log_info "Frontend für Produktion wurde gebaut."
}

# Produktionsumgebung starten oder neustarten
deploy_to_production() {
    log_info "Deploye in die Produktionsumgebung..."
    
    # Überprüfe, ob die Produktionsumgebung bereits läuft
    if docker ps | grep -q "fwf_prod"; then
        # Stoppe bestehende Container
        log_info "Stoppe laufende Produktionsumgebung..."
        docker-compose -f docker-compose.prod.yml down
    fi
    
    # Starte die Produktionsumgebung
    log_info "Starte Produktionsumgebung..."
    docker-compose -f docker-compose.prod.yml up -d
    
    log_info "Deployment in die Produktionsumgebung abgeschlossen."
}

# Grundlegende Tests durchführen
run_basic_tests() {
    log_info "Führe grundlegende Tests durch..."
    
    # Warte ein paar Sekunden, bis alle Container gestartet sind
    sleep 10
    
    # Überprüfe, ob die API erreichbar ist
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api | grep -q "200"; then
        log_info "API ist erreichbar."
    else
        log_warn "API ist nicht erreichbar."
    fi
    
    # Überprüfe, ob die Webseite geladen werden kann
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 | grep -q "200"; then
        log_info "Webseite ist erreichbar."
    else
        log_warn "Webseite ist nicht erreichbar."
    fi
    
    log_info "Grundlegende Tests abgeschlossen."
}

# Hauptprogramm
main() {
    log_info "Starte Deployment-Prozess für FreeWorldFirst Collector..."
    
    check_prerequisites
    check_git_status
    backup_database
    build_frontend
    deploy_to_production
    run_basic_tests
    
    log_info "Deployment-Prozess abgeschlossen."
    log_info "FreeWorldFirst Collector ist nun unter http://freeworldfirst.com:8000 verfügbar."
}

# Führe das Hauptprogramm aus
main
