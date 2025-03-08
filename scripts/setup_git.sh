#!/bin/bash
# setup_git.sh - Erstellt die Git-Konfiguration für FreeWorldFirst Collector

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

# Erstellt .gitignore-Datei
create_gitignore() {
    log_info "Erstelle .gitignore-Datei..."
    
    cat > .gitignore << EOL
# Umgebungsvariablen und Konfiguration
.env
.env.*
!.env.example
config/*.json
config/.env.*

# Abhängigkeiten
node_modules
.npm
.yarn

# Build-Verzeichnisse
/build
/dist
/frontend/build
/frontend/dist
/backend/dist

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Datenbank-Backups und -Daten
database/backups
*.sql.gz
*.dump

# Betriebssystem-Dateien
.DS_Store
Thumbs.db
.directory

# IDE und Editor-Dateien
.idea
.vscode
*.swp
*.swo
*.sublime-*
.project
.classpath
.settings

# Testdateien
/coverage
.nyc_output

# Temporäre Dateien
tmp
temp
.tmp
.temp

# Caches
.cache
.parcel-cache
.eslintcache
.stylelintcache

# Lokale Dateien
*.local
EOL

    log_info ".gitignore-Datei wurde erstellt."
}

# Erstellt .github-Workflows für GitHub Actions
create_github_workflows() {
    log_info "Erstelle GitHub-Workflows..."
    
    mkdir -p .github/workflows
    
    # CI-Workflow
    cat > .github/workflows/ci.yml << EOL
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install Backend Dependencies
      run: |
        cd backend
        npm ci
    
    - name: Run Backend Tests
      run: |
        cd backend
        npm test
    
    - name: Install Frontend Dependencies
      run: |
        cd frontend
        npm ci
    
    - name: Run Frontend Tests
      run: |
        cd frontend
        npm test -- --watchAll=false
    
    - name: Build Frontend
      run: |
        cd frontend
        npm run build
EOL

    # CD-Workflow (nur als Beispiel)
    cat > .github/workflows/cd.yml << EOL
name: CD

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install Dependencies
      run: |
        cd frontend
        npm ci
    
    - name: Build Frontend
      run: |
        cd frontend
        npm run build
    
    # Hier würden die Schritte für das Deployment folgen
    # Dies ist nur ein Platzhalter, da das tatsächliche Deployment 
    # von Ihrer spezifischen Hosting-Umgebung abhängt
    
    # - name: Deploy to Production
    #   run: |
    #     # Deployment-Schritte hier
EOL

    log_info "GitHub-Workflows wurden erstellt."
}

# Erstellt eine README.md-Datei
create_readme() {
    log_info "Erstelle README.md-Datei..."
    
    cat > README.md << EOL
# FreeWorldFirst Collector

Eine Community-basierte Web-Anwendung, die ethische Alternativen zu BigTech-Produkten sammelt und bewertet.

## Über das Projekt

FreeWorldFirst Collector ermöglicht es Benutzern, ethische Alternativen zu gängigen BigTech-Produkten und -Diensten vorzuschlagen und zu diskutieren. Ziel ist es, die digitale Souveränität zu stärken und durch freie Entscheidungen einer engagierten Community unethisches Verhalten einiger Konzerne zu begrenzen.

## Funktionen

- Strukturierte Erfassung von ethischen Alternativen zu BigTech-Produkten
- Community-basierte Bewertung und Diskussion
- Benutzer können Vorschläge einreichen und bewerten
- Admin-Backend zur Moderation von Einträgen
- Benutzerkonten mit Authentifizierung

## Technologie-Stack

- **Frontend**: React mit Tailwind CSS
- **Backend**: Node.js mit Express
- **Datenbank**: PostgreSQL
- **Containerisierung**: Docker und Docker Compose

## Entwicklung

### Voraussetzungen

- Docker und Docker Compose
- Git

### Installation und Einrichtung

1. Repository klonen:
   \`\`\`
   git clone https://github.com/Boronowsky/fwf-alternativesDB.git
   cd fwf-alternativesDB
   \`\`\`

2. Installation ausführen:
   \`\`\`
   bash install.sh
   \`\`\`

3. Entwicklungsumgebung starten:
   \`\`\`
   docker-compose -f docker-compose.dev.yml up
   \`\`\`

4. Die Anwendung ist nun unter [http://localhost:8100](http://localhost:8100) verfügbar.

### Verzeichnisstruktur

\`\`\`
fwf-alternativesDB/
├── frontend/              # React-Frontend
├── backend/               # Node.js-Backend
├── database/              # Datenbank-Konfiguration und Skripte
├── nginx/                 # Nginx-Konfiguration
├── scripts/               # Hilfsskripte
├── docker-compose.dev.yml # Docker-Compose für Entwicklung
├── docker-compose.prod.yml # Docker
├── docker-compose.prod.yml # Docker-Compose für Produktion
└── .env.dev/.env.prod      # Umgebungsvariablen
\`\`\`

## Deployment

Um die Anwendung in die Produktionsumgebung zu deployen:

\`\`\`
bash scripts/deployToProd.sh
\`\`\`

Die Produktionsversion ist dann unter [http://freeworldfirst.com:8000](http://freeworldfirst.com:8000) erreichbar.

## Mitwirken

Beiträge sind willkommen! Bitte erstellen Sie einen Fork des Repositories und reichen Sie einen Pull Request ein.

## Lizenz

[MIT](LICENSE)
EOL

    log_info "README.md-Datei wurde erstellt."
}

# Erstellt eine einfache Lizenz-Datei
create_license() {
    log_info "Erstelle LICENSE-Datei..."
    
    cat > LICENSE << EOL
MIT License

Copyright (c) 2025 FreeWorldFirst

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOL

    log_info "LICENSE-Datei wurde erstellt."
}

# Initialisiert das Git-Repository
init_git_repo() {
    log_info "Initialisiere Git-Repository..."
    
    # Überprüfe, ob Git installiert ist
    if ! command -v git &> /dev/null; then
        log_error "Git ist nicht installiert. Bitte installieren Sie Git und versuchen Sie es erneut."
        return 1
    fi
    
    # Überprüfe, ob das Verzeichnis bereits ein Git-Repository ist
    if [ -d ".git" ]; then
        log_warn "Das Verzeichnis ist bereits ein Git-Repository."
    else
        git init
        log_info "Git-Repository wurde initialisiert."
    fi
    
    # Füge alle Dateien zum Staging-Bereich hinzu
    git add .
    
    # Erstelle einen ersten Commit
    git commit -m "Initial commit: FreeWorldFirst Collector Setup"
    
    # Erstelle den develop-Branch
    git checkout -b develop
    
    log_info "Git-Repository wurde erfolgreich eingerichtet."
}

# Hauptprogramm
main() {
    log_info "Starte Erstellung der Git-Konfiguration..."
    create_gitignore
    create_github_workflows
    create_readme
    create_license
    init_git_repo
    log_info "Git-Konfiguration wurde erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main
