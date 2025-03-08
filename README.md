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
   ```
   git clone https://github.com/Boronowsky/fwf-alternativesDB.git
   cd fwf-alternativesDB
   ```

2. Installation ausführen:
   ```
   die scripte sind outdated
   ```

3. Entwicklungsumgebung starten:
   ```
   docker-compose -f docker-compose.dev.yml up
   ```

4. Die Anwendung ist nun unter [http://localhost:8181](http://localhost:8181) verfügbar.

### Verzeichnisstruktur

```
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
```

## Deployment

Um die Anwendung in die Produktionsumgebung zu deployen:

```
bash scripts/deployToProd.sh
```

Die Produktionsversion ist dann unter [http://freeworldfirst.com:8000](http://freeworldfirst.com:8000) erreichbar.

## Mitwirken

Beiträge sind willkommen! Bitte erstellen Sie einen Fork des Repositories und reichen Sie einen Pull Request ein.

## Lizenz

[MIT](LICENSE)
