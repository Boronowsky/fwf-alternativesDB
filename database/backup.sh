#!/bin/bash

# Backup-Skript für die FreeWorldFirst Collector Datenbank

# Konfiguration
DB_NAME=${1:-"fwf_collector_prod"}  # Standardmäßig die Produktionsdatenbank
DB_USER=${2:-"fwf_user"}
BACKUP_DIR="$(dirname "$0")/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$DATE.sql"

# Stellen Sie sicher, dass das Backup-Verzeichnis existiert
mkdir -p $BACKUP_DIR

# Backup erstellen
echo "Erstelle Backup der Datenbank $DB_NAME..."
docker exec -i postgres pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE

# Prüfen, ob das Backup erfolgreich war
if [ $? -eq 0 ]; then
    echo "Backup wurde erfolgreich erstellt: $BACKUP_FILE"
    
    # Komprimieren des Backups
    gzip $BACKUP_FILE
    echo "Backup wurde komprimiert: $BACKUP_FILE.gz"
    
    # Alte Backups löschen (älter als 30 Tage)
    find $BACKUP_DIR -name "*.gz" -type f -mtime +30 -delete
    echo "Alte Backups wurden gelöscht."
else
    echo "Fehler beim Erstellen des Backups!"
    exit 1
fi
