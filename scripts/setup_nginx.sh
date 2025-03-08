#!/bin/bash
# setup_nginx.sh - Erstellt die Nginx-Konfiguration für FreeWorldFirst Collector

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

# Erstellt Nginx-Konfiguration für die Entwicklungsumgebung
create_dev_config() {
    log_info "Erstelle Nginx-Konfiguration für die Entwicklungsumgebung..."
    
    cat > nginx/dev/default.conf << EOL
server {
    listen 80;
    server_name localhost;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # API-Anfragen zum Backend weiterleiten
    location /api {
        proxy_pass http://backend:8100;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Frontend-Anfragen zum React-Dev-Server weiterleiten
    location / {
        proxy_pass http://frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

    log_info "Nginx-Konfiguration für die Entwicklungsumgebung wurde erstellt."
}

# Erstellt Nginx-Konfiguration für die Produktionsumgebung
create_prod_config() {
    log_info "Erstelle Nginx-Konfiguration für die Produktionsumgebung..."
    
    cat > nginx/prod/default.conf << EOL
server {
    listen 80;
    server_name freeworldfirst.com;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip-Kompression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # API-Anfragen zum Backend weiterleiten
    location /api {
        proxy_pass http://backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Statische Dateien mit Caching ausliefern
    location /static {
        alias /usr/share/nginx/html/static;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }

    # Frontend-Anfragen zur React-Anwendung weiterleiten
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files \$uri \$uri/ /index.html;

        # Caching für die HTML-Datei deaktivieren
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }
}
EOL

    log_info "Nginx-Konfiguration für die Produktionsumgebung wurde erstellt."
}

# Erstellt eine .htaccess-Datei für Apache-Server
create_htaccess() {
    log_info "Erstelle .htaccess-Datei für Apache-Server..."
    
    cat > nginx/htaccess.txt << EOL
# .htaccess-Datei für Apache-Server (falls benötigt)

# Aktiviere Rewrite-Engine
RewriteEngine On

# Wenn die Anfrage keine echte Datei oder Verzeichnis ist, leite zur index.html weiter
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ /index.html [L,QSA]

# Verhindere Zugriff auf .htaccess und andere versteckte Dateien
<FilesMatch "^\.">
    Order allow,deny
    Deny from all
</FilesMatch>

# Verhindere Zugriff auf JSON-Dateien außer manifest.json
<FilesMatch "\.json$">
    Order allow,deny
    Deny from all
</FilesMatch>
<FilesMatch "manifest\.json$">
    Order allow,deny
    Allow from all
</FilesMatch>

# Setze Header für Sicherheit
Header always set X-Content-Type-Options "nosniff"
Header always set X-XSS-Protection "1; mode=block"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set Referrer-Policy "strict-origin-when-cross-origin"

# Kompression aktivieren
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css application/javascript application/json
</IfModule>

# Browser-Caching für statische Dateien
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType application/pdf "access plus 1 month"
    ExpiresByType text/x-javascript "access plus 1 month"
    ExpiresByType application/x-shockwave-flash "access plus 1 month"
    ExpiresByType image/x-icon "access plus 1 year"
    ExpiresDefault "access plus 2 days"
</IfModule>
EOL

    log_info ".htaccess-Datei für Apache-Server wurde erstellt."
}

# Hauptprogramm
main() {
    log_info "Starte Erstellung der Nginx-Konfiguration..."
    create_dev_config
    create_prod_config
    create_htaccess
    log_info "Nginx-Konfiguration wurde erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main
