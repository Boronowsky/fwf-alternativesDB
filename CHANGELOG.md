# Changelog

## [2.0.0] - 2025-01-23

### Sicherheits-Verbesserungen 🔒
- **KRITISCH**: Entfernt hardcoded Admin-Bypass in authController
- Implementiert korrekte CORS-Konfiguration (kein `origin: '*'` mehr)
- Hinzugefügt Rate Limiting für alle API-Routen
- Hinzugefügt strikte Rate Limiting für Auth-Endpunkte (5 Versuche pro 15 Min)
- Implementiert Transactions für Voting-System (behebt Race Conditions)

### Neue Features ✨

#### Tags-System
- Neue Modelle: `Tag`, `AlternativeTag`
- Many-to-Many Beziehung zwischen Alternativen und Tags
- CRUD-Operationen für Tags (Admin only)
- Tags können zu Alternativen hinzugefügt werden
- 8 Default-Tags beim ersten Start
- API-Endpunkte:
  - `GET /api/tags` - Alle Tags abrufen
  - `POST /api/tags` - Tag erstellen (Admin)
  - `PUT /api/tags/:id` - Tag aktualisieren (Admin)
  - `DELETE /api/tags/:id` - Tag löschen (Admin)
  - `POST /api/tags/alternatives/:id/tags` - Tags zu Alternative hinzufügen

#### Erweiterte Suchfunktion
- Filter nach Tags (comma-separated IDs)
- Sortierung nach: `createdAt`, `upvotes`, `title`
- Sortierreihenfolge: `ASC` oder `DESC`
- Erweiterte Volltextsuche in Titel, Beschreibung und ersetztem Produkt
- Query-Parameter:
  - `?tags=uuid1,uuid2` - Filter nach Tags
  - `?sortBy=upvotes&sortOrder=DESC` - Sortierung
  - `?search=keyword` - Erweiterte Suche

#### Favoriten/Bookmarks-System
- Neues Model: `Bookmark`
- Benutzer können Alternativen bookmarken
- API-Endpunkte:
  - `GET /api/bookmarks` - Eigene Bookmarks abrufen
  - `POST /api/bookmarks` - Bookmark hinzufügen
  - `DELETE /api/bookmarks/:alternativeId` - Bookmark entfernen
  - `GET /api/bookmarks/check/:alternativeId` - Bookmark-Status prüfen

#### Protected Routes im Frontend
- Neue Komponente: `ProtectedRoute`
- Route-Guards für authentifizierte Benutzer
- Admin-only Routes für Admin-Bereich
- Automatische Weiterleitung zu Login-Page
- Loading-States während Auth-Prüfung

### Performance-Optimierungen ⚡
- Database-Indizes für häufige Queries:
  - Alternative: category, approved, upvotes, createdAt, submitterId
  - Volltext-Suche Indizes (PostgreSQL GIN)
  - Vote, Comment, Tag, Bookmark Indizes
  - User: email, username
- Migration-Datei: `003-add-indexes.sql`

### Entwickler-Verbesserungen 👨‍💻
- Jest Test-Setup konfiguriert
- Unit-Tests für Alternative-Controller
- Unit-Tests für Vote-System
- Data-Seeding beim Server-Start:
  - 8 Standard-Tags
  - Admin-User (admin@freeworldfirst.com / AdminPassword123!)
- Export von `useAuth` Hook in AuthContext
- Bessere Code-Struktur und Fehlerbehandlung

### API-Änderungen
- Alle Alternative-Endpunkte geben jetzt Tags mit zurück
- CORS benötigt jetzt korrekte Origin-Header
- Rate Limiting aktiv (kann zu 429 Errors führen bei zu vielen Requests)

### Breaking Changes ⚠️
- Hardcoded Admin-Login entfernt (nutze Admin-User aus Seeding)
- CORS-Policy geändert (Frontend muss korrekte Origin setzen)
- Alternative-Responses enthalten jetzt Tags-Array

### Migration
Um die neuen Features zu nutzen:

1. Backend-Dependencies aktualisieren:
   ```bash
   cd backend && npm install
   ```

2. Server neu starten (führt automatisch Seeding aus):
   ```bash
   npm run dev
   ```

3. Optional: Indizes manuell anlegen:
   ```bash
   psql -d fwf_collector_dev -f database/migrations/003-add-indexes.sql
   ```

### Nächste Schritte
- [ ] Frontend-Komponenten für Tags-System
- [ ] Frontend-UI für Bookmarks
- [ ] Erweiterte Such-UI mit Filtern
- [ ] Test-Coverage erhöhen
- [ ] API-Dokumentation (Swagger/OpenAPI)
- [ ] E2E-Tests
