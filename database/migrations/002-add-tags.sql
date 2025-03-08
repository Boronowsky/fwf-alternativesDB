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
