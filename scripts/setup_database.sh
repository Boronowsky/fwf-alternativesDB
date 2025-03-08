#!/bin/bash
# setup_database.sh - Erstellt die Datenbank-Konfiguration für FreeWorldFirst Collector

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

# Erstellt SQL-Datei für die Initialisierung der Entwicklungsdatenbank
create_dev_init_sql() {
    log_info "Erstelle SQL-Datei für die Entwicklungsdatenbank..."
    
    cat > database/init/01-init-dev.sql << EOL
-- Initialisierungsskript für die Entwicklungsdatenbank

-- Erstellt die Datenbank (falls sie noch nicht existiert)
CREATE DATABASE fwf_collector_dev;

-- Verbindet mit der Datenbank
\\c fwf_collector_dev;

-- Erstellt einen Admin-Benutzer
INSERT INTO "Users" (
    id, 
    username, 
    email, 
    password, 
    "isAdmin", 
    "createdAt", 
    "updatedAt"
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'admin',
    'admin@example.com',
    '$2a$10$Sf/QzS9VEIWiL7nO042ak.WXcWQYJIabN3M9tPcxJFpCCDyG4X.W2', -- "password123"
    true,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Erstellt ein paar Beispiel-Kategorien
INSERT INTO "Categories" (id, name, "createdAt", "updatedAt") VALUES
    (uuid_generate_v4(), 'Suchmaschine', NOW(), NOW()),
    (uuid_generate_v4(), 'E-Mail', NOW(), NOW()),
    (uuid_generate_v4(), 'Cloud-Speicher', NOW(), NOW()),
    (uuid_generate_v4(), 'Betriebssystem', NOW(), NOW()),
    (uuid_generate_v4(), 'Browser', NOW(), NOW()),
    (uuid_generate_v4(), 'Messenger', NOW(), NOW()),
    (uuid_generate_v4(), 'Social Media', NOW(), NOW()),
    (uuid_generate_v4(), 'Office Suite', NOW(), NOW()),
    (uuid_generate_v4(), 'Videokonferenz', NOW(), NOW()),
    (uuid_generate_v4(), 'Streaming', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Erstellt ein paar Beispiel-Alternativen
INSERT INTO "Alternatives" (
    id,
    title,
    replaces,
    description,
    reasons,
    benefits,
    website,
    category,
    upvotes,
    approved,
    "submitterId",
    "createdAt",
    "updatedAt"
) VALUES
    (
        uuid_generate_v4(),
        'DuckDuckGo',
        'Google Search',
        'DuckDuckGo ist eine Suchmaschine, die Ihre Privatsphäre respektiert und keine personenbezogenen Daten sammelt.',
        'Google sammelt und speichert umfangreiche Daten über Ihre Suchanfragen und Online-Aktivitäten, um personalisierte Werbung zu schalten.',
        'DuckDuckGo verfolgt Sie nicht, speichert keine persönlichen Informationen und zeigt allen Benutzern die gleichen Suchergebnisse.',
        'https://duckduckgo.com',
        'Suchmaschine',
        15,
        true,
        '00000000-0000-0000-0000-000000000000',
        NOW(),
        NOW()
    ),
    (
        uuid_generate_v4(),
        'ProtonMail',
        'Gmail',
        'ProtonMail ist ein sicherer E-Mail-Dienst mit Ende-zu-Ende-Verschlüsselung, der in der Schweiz gehostet wird.',
        'Gmail analysiert Ihre E-Mails, um Ihnen zielgerichtete Werbung zu zeigen und sammelt Daten über Ihre Kommunikation.',
        'ProtonMail verschlüsselt Ihre E-Mails automatisch und kann Ihre E-Mails nicht lesen oder an Dritte weitergeben.',
        'https://protonmail.com',
        'E-Mail',
        12,
        true,
        '00000000-0000-0000-0000-000000000000',
        NOW(),
        NOW()
    ),
    (
        uuid_generate_v4(),
        'Nextcloud',
        'Google Drive',
        'Nextcloud ist eine selbst gehostete Cloud-Lösung, die Ihnen die volle Kontrolle über Ihre Daten gibt.',
        'Google Drive speichert Ihre Daten auf Google-Servern, was Fragen zum Datenschutz und zur Datenhoheit aufwirft.',
        'Mit Nextcloud behalten Sie die Kontrolle über Ihre Daten, können den Server selbst hosten oder einen vertrauenswürdigen Anbieter wählen.',
        'https://nextcloud.com',
        'Cloud-Speicher',
        8,
        true,
        '00000000-0000-0000-0000-000000000000',
        NOW(),
        NOW()
    ),
    (
        uuid_generate_v4(),
        'Signal',
        'WhatsApp',
        'Signal ist ein Messenger mit starker Verschlüsselung, der von einer gemeinnützigen Stiftung betrieben wird.',
        'WhatsApp gehört zu Meta (ehemals Facebook) und teilt Metadaten mit dem Mutterunternehmen, das für seine Datenschutzprobleme bekannt ist.',
        'Signal sammelt minimal Daten, hat den Quellcode offen gelegt und wird von Datenschutzexperten empfohlen.',
        'https://signal.org',
        'Messenger',
        20,
        true,
        '00000000-0000-0000-0000-000000000000',
        NOW(),
        NOW()
    ),
    (
        uuid_generate_v4(),
        'Firefox',
        'Google Chrome',
        'Firefox ist ein Open-Source-Browser, der von der gemeinnützigen Mozilla-Stiftung entwickelt wird.',
        'Chrome sammelt umfangreiche Daten über Ihr Surfverhalten und ist tief in das Google-Ökosystem integriert.',
        'Firefox hat starke Datenschutzfunktionen, blockiert standardmäßig Tracker und wird von einer Organisation entwickelt, die sich für ein offenes Internet einsetzt.',
        'https://firefox.com',
        'Browser',
        18,
        true,
        '00000000-0000-0000-0000-000000000000',
        NOW(),
        NOW()
    );
EOL

    log_info "SQL-Datei für die Entwicklungsdatenbank wurde erstellt."
}

# Erstellt SQL-Datei für die Initialisierung der Produktionsdatenbank
create_prod_init_sql() {
    log_info "Erstelle SQL-Datei für die Produktionsdatenbank..."
    
    cat > database/init/02-init-prod.sql << EOL
-- Initialisierungsskript für die Produktionsdatenbank

-- Erstellt die Datenbank (falls sie noch nicht existiert)
CREATE DATABASE fwf_collector_prod;

-- Verbindet mit der Datenbank
\\c fwf_collector_prod;

-- Erstellt einen Admin-Benutzer
INSERT INTO "Users" (
    id, 
    username, 
    email, 
    password, 
    "isAdmin", 
    "createdAt", 
    "updatedAt"
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'admin',
    'admin@freeworldfirst.com',
    '$2a$10$Sf/QzS9VEIWiL7nO042ak.WXcWQYJIabN3M9tPcxJFpCCDyG4X.W2', -- "password123"
    true,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Erstellt Kategorien
INSERT INTO "Categories" (id, name, "createdAt", "updatedAt") VALUES
    (uuid_generate_v4(), 'Suchmaschine', NOW(), NOW()),
    (uuid_generate_v4(), 'E-Mail', NOW(), NOW()),
    (uuid_generate_v4(), 'Cloud-Speicher', NOW(), NOW()),
    (uuid_generate_v4(), 'Betriebssystem', NOW(), NOW()),
    (uuid_generate_v4(), 'Browser', NOW(), NOW()),
    (uuid_generate_v4(), 'Messenger', NOW(), NOW()),
    (uuid_generate_v4(), 'Social Media', NOW(), NOW()),
    (uuid_generate_v4(), 'Office Suite', NOW(), NOW()),
    (uuid_generate_v4(), 'Videokonferenz', NOW(), NOW()),
    (uuid_generate_v4(), 'Streaming', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;
EOL

    log_info "SQL-Datei für die Produktionsdatenbank wurde erstellt."
}

# Erstellt Backup-Skript
create_backup_script() {
    log_info "Erstelle Backup-Skript..."
    
    cat > database/backup.sh << EOL
#!/bin/bash

# Backup-Skript für die FreeWorldFirst Collector Datenbank

# Konfiguration
DB_NAME=\${1:-"fwf_collector_prod"}  # Standardmäßig die Produktionsdatenbank
DB_USER=\${2:-"fwf_user"}
BACKUP_DIR="\$(dirname "\$0")/backups"
DATE=\$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="\$BACKUP_DIR/\$DB_NAME-\$DATE.sql"

# Stellen Sie sicher, dass das Backup-Verzeichnis existiert
mkdir -p \$BACKUP_DIR

# Backup erstellen
echo "Erstelle Backup der Datenbank \$DB_NAME..."
docker exec -i postgres pg_dump -U \$DB_USER \$DB_NAME > \$BACKUP_FILE

# Prüfen, ob das Backup erfolgreich war
if [ \$? -eq 0 ]; then
    echo "Backup wurde erfolgreich erstellt: \$BACKUP_FILE"
    
    # Komprimieren des Backups
    gzip \$BACKUP_FILE
    echo "Backup wurde komprimiert: \$BACKUP_FILE.gz"
    
    # Alte Backups löschen (älter als 30 Tage)
    find \$BACKUP_DIR -name "*.gz" -type f -mtime +30 -delete
    echo "Alte Backups wurden gelöscht."
else
    echo "Fehler beim Erstellen des Backups!"
    exit 1
fi
EOL

    # Skript ausführbar machen
    chmod +x database/backup.sh
    
    log_info "Backup-Skript wurde erstellt."
}

# Erstellt Restore-Skript
create_restore_script() {
    log_info "Erstelle Restore-Skript..."
    
    cat > database/restore.sh << EOL
#!/bin/bash

# Restore-Skript für die FreeWorldFirst Collector Datenbank

# Prüfen, ob ein Backup-Dateiname angegeben wurde
if [ -z "\$1" ]; then
    echo "Fehler: Kein Backup-Dateiname angegeben."
    echo "Verwendung: \$0 <backup-datei> [datenbankname] [benutzer]"
    exit 1
fi

# Konfiguration
BACKUP_FILE="\$1"
DB_NAME=\${2:-"fwf_collector_prod"}  # Standardmäßig die Produktionsdatenbank
DB_USER=\${3:-"fwf_user"}

# Prüfen, ob die Backup-Datei existiert
if [ ! -f "\$BACKUP_FILE" ]; then
    echo "Fehler: Backup-Datei nicht gefunden: \$BACKUP_FILE"
    exit 1
fi

# Wenn die Datei komprimiert ist, entpacken
if [[ "\$BACKUP_FILE" == *.gz ]]; then
    echo "Entpacke komprimierte Backup-Datei..."
    gunzip -k "\$BACKUP_FILE"  # -k behält die ursprüngliche Datei
    BACKUP_FILE=\${BACKUP_FILE%.gz}
fi

# Warnung anzeigen und Bestätigung einholen
echo "WARNUNG: Dies wird alle Daten in der Datenbank '\$DB_NAME' überschreiben!"
read -p "Sind Sie sicher, dass Sie fortfahren möchten? (j/N) " -n 1 -r
echo
if [[ ! \$REPLY =~ ^[Jj]$ ]]; then
    echo "Wiederherstellung abgebrochen."
    exit 1
fi

# Backup einspielen
echo "Stelle Backup in die Datenbank '\$DB_NAME' wieder her..."
docker exec -i postgres psql -U \$DB_USER -d \$DB_NAME < "\$BACKUP_FILE"

# Prüfen, ob die Wiederherstellung erfolgreich war
if [ \$? -eq 0 ]; then
    echo "Wiederherstellung wurde erfolgreich abgeschlossen."
else
    echo "Fehler bei der Wiederherstellung!"
    exit 1
fi

# Temporäre entpackte Datei löschen, wenn das Original komprimiert war
if [[ "\$1" == *.gz && "\$BACKUP_FILE" != "\$1" ]]; then
    rm "\$BACKUP_FILE"
fi
EOL

    # Skript ausführbar machen
    chmod +x database/restore.sh
    
    log_info "Restore-Skript wurde erstellt."
}

# Erstellt Migrations-Ordnerstruktur und ein Beispiel-Migrationsskript
create_migrations() {
    log_info "Erstelle Migrations-Struktur..."
    
    # Verzeichnis für Migrations-Skripte erstellen
    mkdir -p database/migrations
    
    # Beispiel-Migrations-Skript
    cat > database/migrations/001-initial-schema.sql << EOL
-- Migration: 001-initial-schema.sql
-- Beschreibung: Initiales Datenbankschema

-- Erstellt die Tabellen für die Anwendung, falls sie noch nicht existieren

-- Aktiviere UUID-Erweiterung
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Benutzer-Tabelle
CREATE TABLE IF NOT EXISTS "Users" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    "isAdmin" BOOLEAN DEFAULT FALSE,
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL
);

-- Kategorien-Tabelle
CREATE TABLE IF NOT EXISTS "Categories" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL
);

-- Alternativen-Tabelle
CREATE TABLE IF NOT EXISTS "Alternatives" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    replaces VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    reasons TEXT NOT NULL,
    benefits TEXT NOT NULL,
    website VARCHAR(255),
    category VARCHAR(50) NOT NULL,
    upvotes INTEGER DEFAULT 0,
    approved BOOLEAN DEFAULT FALSE,
    "submitterId" UUID REFERENCES "Users"(id),
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL
);

-- Kommentar-Tabelle
CREATE TABLE IF NOT EXISTS "Comments" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    "userId" UUID REFERENCES "Users"(id) ON DELETE CASCADE,
    "alternativeId" UUID REFERENCES "Alternatives"(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL
);

-- Abstimmungs-Tabelle
CREATE TABLE IF NOT EXISTS "Votes" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(10) NOT NULL CHECK (type IN ('upvote', 'downvote')),
    "userId" UUID REFERENCES "Users"(id) ON DELETE CASCADE,
    "alternativeId" UUID REFERENCES "Alternatives"(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL,
    UNIQUE("userId", "alternativeId")
);

-- Indizes für bessere Performance
CREATE INDEX IF NOT EXISTS "idx_alternatives_category" ON "Alternatives" (category);
CREATE INDEX IF NOT EXISTS "idx_alternatives_approved" ON "Alternatives" (approved);
CREATE INDEX IF NOT EXISTS "idx_comments_alternative_id" ON "Comments" ("alternativeId");
CREATE INDEX IF NOT EXISTS "idx_votes_alternative_id" ON "Votes" ("alternativeId");
EOL

    # Migrationsskript für Änderungen am Schema
    cat > database/migrations/002-add-tags.sql << EOL
-- Migration: 002-add-tags.sql
-- Beschreibung: Fügt Tags für Alternativen hinzu

-- Tags-Tabelle
CREATE TABLE IF NOT EXISTS "Tags" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(30) NOT NULL UNIQUE,
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL
);

-- Verknüpfungstabelle für Alternativen und Tags
CREATE TABLE IF NOT EXISTS "AlternativeTags" (
    "alternativeId" UUID REFERENCES "Alternatives"(id) ON DELETE CASCADE,
    "tagId" UUID REFERENCES "Tags"(id) ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP NOT NULL,
    PRIMARY KEY ("alternativeId", "tagId")
);

-- Index für bessere Performance
CREATE INDEX IF NOT EXISTS "idx_alternative_tags_tag_id" ON "AlternativeTags" ("tagId");
EOL

    log_info "Migrations-Struktur wurde erstellt."
}

# Erstellt ein Migrations-Runner-Skript
create_migration_runner() {
    log_info "Erstelle Migrations-Runner-Skript..."
    
    cat > database/run-migrations.sh << EOL
#!/bin/bash

# Migrations-Runner für FreeWorldFirst Collector

# Konfiguration
DB_NAME=\${1:-"fwf_collector_prod"}  # Standardmäßig die Produktionsdatenbank
DB_USER=\${2:-"fwf_user"}
MIGRATIONS_DIR="\$(dirname "\$0")/migrations"
MIGRATIONS_TABLE="_migrations"

# Funktion zum Erstellen der Migrations-Tabelle, falls sie nicht existiert
create_migrations_table() {
    echo "Erstelle Migrations-Tabelle, falls sie nicht existiert..."
    docker exec -i postgres psql -U \$DB_USER -d \$DB_NAME << EOF
    CREATE TABLE IF NOT EXISTS \$MIGRATIONS_TABLE (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
EOF
}

# Funktion zum Abrufen bereits angewendeter Migrationen
get_applied_migrations() {
    docker exec -i postgres psql -U \$DB_USER -d \$DB_NAME -t -c "SELECT name FROM \$MIGRATIONS_TABLE ORDER BY id;"
}

# Funktion zum Anwenden einer Migration
apply_migration() {
    local migration_file="\$1"
    local migration_name="\$(basename "\$migration_file")"
    
    echo "Wende Migration an: \$migration_name"
    
    # Führe die Migration aus
    docker exec -i postgres psql -U \$DB_USER -d \$DB_NAME < "\$migration_file"
    
    # Bei Erfolg, füge sie zur Migrations-Tabelle hinzu
    if [ \$? -eq 0 ]; then
        docker exec -i postgres psql -U \$DB_USER -d \$DB_NAME -c "INSERT INTO \$MIGRATIONS_TABLE (name) VALUES ('\$migration_name');"
        echo "Migration erfolgreich angewendet: \$migration_name"
    else
        echo "Fehler beim Anwenden der Migration: \$migration_name"
        exit 1
    fi
}

# Hauptprogramm
main() {
    echo "Starte Migration für Datenbank: \$DB_NAME"
    
    # Erstelle die Migrations-Tabelle
    create_migrations_table
    
    # Hole bereits angewendete Migrationen
    applied_migrations=\$(get_applied_migrations)
    
    # Finde alle Migrations-Dateien und sortiere sie alphabetisch
    migration_files=(\$(find "\$MIGRATIONS_DIR" -name "*.sql" | sort))
    
    # Zähle angewendete und verfügbare Migrationen
    applied_count=\$(echo "\$applied_migrations" | wc -l)
    available_count=\${#migration_files[@]}
    
    echo "Gefundene Migrations-Dateien: \$available_count"
    echo "Bereits angewendete Migrationen: \$applied_count"
    
    # Wende fehlende Migrationen an
    for migration_file in "\${migration_files[@]}"; do
        migration_name=\$(basename "\$migration_file")
        
        # Überprüfe, ob die Migration bereits angewendet wurde
        if ! echo "\$applied_migrations" | grep -q "\$migration_name"; then
            apply_migration "\$migration_file"
        else
            echo "Migration bereits angewendet: \$migration_name"
        fi
    done
    
    echo "Migration abgeschlossen."
}

# Führe das Hauptprogramm aus
main
EOL

    # Skript ausführbar machen
    chmod +x database/run-migrations.sh
    
    log_info "Migrations-Runner-Skript wurde erstellt."
}

# Hauptprogramm
main() {
    log_info "Starte Erstellung der Datenbank-Konfiguration..."
    create_dev_init_sql
    create_prod_init_sql
    create_backup_script
    create_restore_script
    create_migrations
    create_migration_runner
    log_info "Datenbank-Konfiguration wurde erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main
