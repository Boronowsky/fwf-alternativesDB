#!/bin/bash

# Migrations-Runner für FreeWorldFirst Collector

# Konfiguration
DB_NAME=${1:-"fwf_collector_prod"}  # Standardmäßig die Produktionsdatenbank
DB_USER=${2:-"fwf_user"}
MIGRATIONS_DIR="$(dirname "$0")/migrations"
MIGRATIONS_TABLE="_migrations"

# Funktion zum Erstellen der Migrations-Tabelle, falls sie nicht existiert
create_migrations_table() {
    echo "Erstelle Migrations-Tabelle, falls sie nicht existiert..."
    docker exec -i postgres psql -U $DB_USER -d $DB_NAME << EOF
    CREATE TABLE IF NOT EXISTS $MIGRATIONS_TABLE (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
EOF
}

# Funktion zum Abrufen bereits angewendeter Migrationen
get_applied_migrations() {
    docker exec -i postgres psql -U $DB_USER -d $DB_NAME -t -c "SELECT name FROM $MIGRATIONS_TABLE ORDER BY id;"
}

# Funktion zum Anwenden einer Migration
apply_migration() {
    local migration_file="$1"
    local migration_name="$(basename "$migration_file")"
    
    echo "Wende Migration an: $migration_name"
    
    # Führe die Migration aus
    docker exec -i postgres psql -U $DB_USER -d $DB_NAME < "$migration_file"
    
    # Bei Erfolg, füge sie zur Migrations-Tabelle hinzu
    if [ $? -eq 0 ]; then
        docker exec -i postgres psql -U $DB_USER -d $DB_NAME -c "INSERT INTO $MIGRATIONS_TABLE (name) VALUES ('$migration_name');"
        echo "Migration erfolgreich angewendet: $migration_name"
    else
        echo "Fehler beim Anwenden der Migration: $migration_name"
        exit 1
    fi
}

# Hauptprogramm
main() {
    echo "Starte Migration für Datenbank: $DB_NAME"
    
    # Erstelle die Migrations-Tabelle
    create_migrations_table
    
    # Hole bereits angewendete Migrationen
    applied_migrations=$(get_applied_migrations)
    
    # Finde alle Migrations-Dateien und sortiere sie alphabetisch
    migration_files=($(find "$MIGRATIONS_DIR" -name "*.sql" | sort))
    
    # Zähle angewendete und verfügbare Migrationen
    applied_count=$(echo "$applied_migrations" | wc -l)
    available_count=${#migration_files[@]}
    
    echo "Gefundene Migrations-Dateien: $available_count"
    echo "Bereits angewendete Migrationen: $applied_count"
    
    # Wende fehlende Migrationen an
    for migration_file in "${migration_files[@]}"; do
        migration_name=$(basename "$migration_file")
        
        # Überprüfe, ob die Migration bereits angewendet wurde
        if ! echo "$applied_migrations" | grep -q "$migration_name"; then
            apply_migration "$migration_file"
        else
            echo "Migration bereits angewendet: $migration_name"
        fi
    done
    
    echo "Migration abgeschlossen."
}

# Führe das Hauptprogramm aus
main
