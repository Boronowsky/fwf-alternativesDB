-- Initialisierungsskript für die Produktionsdatenbank

-- Erstellt die Datenbank (falls sie noch nicht existiert)
CREATE DATABASE fwf_collector_prod;

-- Verbindet mit der Datenbank
\c fwf_collector_prod;

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
    'a0/QzS9VEIWiL7nO042ak.WXcWQYJIabN3M9tPcxJFpCCDyG4X.W2', -- "password123"
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
