# 🚀 Start-Anleitung - FWF Collector v2.0.0

## Schnellstart (Lokal ohne Docker)

### 1. Backend starten

```bash
cd /home/user/fwf-alternativesDB/backend

# Dependencies wurden bereits installiert
# Falls nötig: npm install

# Server starten (mit Auto-Reload)
npm run dev

# Oder ohne Auto-Reload:
# npm start
```

Der Server läuft dann auf **http://localhost:8100**

**Beim ersten Start werden automatisch:**
- Datenbank-Modelle synchronisiert
- 8 Standard-Tags erstellt
- Admin-User angelegt

### 2. Frontend starten (optional)

In einem neuen Terminal:

```bash
cd /home/user/fwf-alternativesDB/frontend

# Dependencies installieren (falls noch nicht geschehen)
npm install

# Development-Server starten
npm start
```

Frontend läuft dann auf **http://localhost:3000**

---

## 🔐 Login-Daten

**Admin-Account:**
- Email: `admin@freeworldfirst.com`
- Passwort: `AdminPassword123!`

---

## 🗄️ Datenbank-Setup

### PostgreSQL-Verbindung prüfen

```bash
psql -h localhost -U fwf_user -d fwf_collector_dev
# Passwort: dev_password
```

### Indizes manuell anlegen (optional, für bessere Performance)

```bash
psql -h localhost -U fwf_user -d fwf_collector_dev -f /home/user/fwf-alternativesDB/database/migrations/003-add-indexes.sql
```

---

## 🧪 Tests ausführen

```bash
cd /home/user/fwf-alternativesDB/backend

# Alle Tests ausführen
npm test

# Tests mit Coverage
npm test -- --coverage

# Einzelne Test-Suite
npm test -- alternativeController.test.js
```

---

## 📡 Neue API-Endpunkte testen

### Tags

```bash
# Alle Tags abrufen
curl http://localhost:8100/api/tags

# Tag erstellen (benötigt Admin-Token)
curl -X POST http://localhost:8100/api/tags \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Mein Tag", "color": "#FF5733"}'
```

### Bookmarks

```bash
# Eigene Bookmarks abrufen (benötigt Login)
curl http://localhost:8100/api/bookmarks \
  -H "Authorization: Bearer YOUR_TOKEN"

# Bookmark hinzufügen
curl -X POST http://localhost:8100/api/bookmarks \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"alternativeId": "UUID_HIER"}'
```

### Erweiterte Suche

```bash
# Nach Tags filtern
curl "http://localhost:8100/api/alternatives?tags=uuid1,uuid2"

# Nach Upvotes sortieren
curl "http://localhost:8100/api/alternatives?sortBy=upvotes&sortOrder=DESC"

# Volltext-Suche
curl "http://localhost:8100/api/alternatives?search=privacy"

# Kombiniert
curl "http://localhost:8100/api/alternatives?search=signal&sortBy=upvotes&tags=uuid1"
```

---

## 🐛 Troubleshooting

### Backend startet nicht

**Fehler: "Datenbankverbindung konnte nicht hergestellt werden"**

Lösung:
```bash
# PostgreSQL-Service starten
sudo service postgresql start

# Oder mit systemd:
sudo systemctl start postgresql

# Datenbank erstellen (falls nicht vorhanden)
sudo -u postgres psql -c "CREATE DATABASE fwf_collector_dev;"
sudo -u postgres psql -c "CREATE USER fwf_user WITH PASSWORD 'dev_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fwf_collector_dev TO fwf_user;"
```

**Fehler: "CORS Error" im Frontend**

Die CORS-Konfiguration ist jetzt strikt. Stelle sicher, dass:
- Backend auf Port 8100 läuft
- Frontend auf Port 3000 läuft
- Oder setze in `.env.dev`: `CORS_ORIGIN=http://localhost:3000`

### Tests schlagen fehl

```bash
# Node modules neu installieren
cd backend
rm -rf node_modules package-lock.json
npm install

# Cache löschen
npm test -- --clearCache
```

---

## 📊 Was wurde verbessert?

✅ **Sicherheit:**
- Admin-Bypass entfernt
- CORS richtig konfiguriert
- Rate Limiting aktiv
- Transactions für Voting

✅ **Features:**
- Tags-System
- Bookmarks
- Erweiterte Suche
- Protected Routes

✅ **Performance:**
- Database-Indizes
- Optimierte Queries

✅ **Code-Qualität:**
- Unit-Tests
- Data-Seeding
- Bessere Struktur

---

## 🔄 Mit Docker starten (falls Docker verfügbar)

```bash
# Development-Umgebung
docker-compose -f docker-compose.dev.yml up --build

# Oder im Hintergrund
docker-compose -f docker-compose.dev.yml up -d --build

# Logs anschauen
docker-compose -f docker-compose.dev.yml logs -f backend

# Stoppen
docker-compose -f docker-compose.dev.yml down
```

Nach Docker-Start ist die App erreichbar unter:
- **Frontend**: http://localhost:8181
- **Backend API**: http://localhost:8100
- **PostgreSQL**: localhost:5432

---

## 📝 Nächste Schritte

1. **Server starten**: `cd backend && npm run dev`
2. **Mit Admin einloggen** und Daten hinzufügen
3. **Tags erstellen** im Admin-Bereich
4. **Tests ausführen**: `npm test`
5. **Frontend-UI für neue Features entwickeln**

Viel Erfolg! 🎉
