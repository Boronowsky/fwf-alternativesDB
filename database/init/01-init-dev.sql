-- Initialisierungsskript für die Entwicklungsdatenbank

-- Erstellt die Datenbank (falls sie noch nicht existiert)
CREATE DATABASE fwf_collector_dev;

-- Verbindet mit der Datenbank
\c fwf_collector_dev;

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
    'a0/QzS9VEIWiL7nO042ak.WXcWQYJIabN3M9tPcxJFpCCDyG4X.W2', -- "password123"
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
