#!/bin/bash

# Restore-Skript für die FreeWorldFirst Collector Datenbank

# Prüfen, ob ein Backup-Dateiname angegeben wurde
if [ -z "$1" ]; then
    echo "Fehler: Kein Backup-Dateiname angegeben."
    echo "Verwendung: $0 <backup-datei> [datenbankname] [benutzer]"
    exit 1
fi

# Konfiguration
BACKUP_FILE="$1"
DB_NAME=${2:-"fwf_collector_prod"}  # Standardmäßig die Produktionsdatenbank
DB_USER=${3:-"fwf_user"}

# Prüfen, ob die Backup-Datei existiert
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Fehler: Backup-Datei nicht gefunden: $BACKUP_FILE"
    exit 1
fi

# Wenn die Datei komprimiert ist, entpacken
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "Entpacke komprimierte Backup-Datei..."
    gunzip -k "$BACKUP_FILE"  # -k behält die ursprüngliche Datei
    BACKUP_FILE=${BACKUP_FILE%.gz}
fi

# Warnung anzeigen und Bestätigung einholen
echo "WARNUNG: Dies wird alle Daten in der Datenbank '$DB_NAME' überschreiben!"
read -p "Sind Sie sicher, dass Sie fortfahren möchten? (j/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Jj]$ ]]; then
    echo "Wiederherstellung abgebrochen."
    exit 1
fi

# Backup einspielen
echo "Stelle Backup in die Datenbank '$DB_NAME' wieder her..."
docker exec -i postgres psql -U $DB_USER -d $DB_NAME < "$BACKUP_FILE"

# Prüfen, ob die Wiederherstellung erfolgreich war
if [ $? -eq 0 ]; then
    echo "Wiederherstellung wurde erfolgreich abgeschlossen."
else
    echo "Fehler bei der Wiederherstellung!"
    exit 1
fi

# Temporäre entpackte Datei löschen, wenn das Original komprimiert war
if [[ "$1" == *.gz && "$BACKUP_FILE" != "$1" ]]; then
    rm "$BACKUP_FILE"
fi
