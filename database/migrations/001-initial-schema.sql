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
