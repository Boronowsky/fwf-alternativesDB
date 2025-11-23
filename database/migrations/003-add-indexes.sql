-- Indizes für bessere Query-Performance

-- Alternative-Indizes
CREATE INDEX IF NOT EXISTS idx_alternatives_category ON "Alternatives"(category);
CREATE INDEX IF NOT EXISTS idx_alternatives_approved ON "Alternatives"(approved);
CREATE INDEX IF NOT EXISTS idx_alternatives_upvotes ON "Alternatives"(upvotes DESC);
CREATE INDEX IF NOT EXISTS idx_alternatives_created_at ON "Alternatives"("createdAt" DESC);
CREATE INDEX IF NOT EXISTS idx_alternatives_submitter ON "Alternatives"("submitterId");

-- Volltext-Suche Indizes für PostgreSQL
CREATE INDEX IF NOT EXISTS idx_alternatives_title_search ON "Alternatives" USING gin(to_tsvector('german', title));
CREATE INDEX IF NOT EXISTS idx_alternatives_replaces_search ON "Alternatives" USING gin(to_tsvector('german', replaces));
CREATE INDEX IF NOT EXISTS idx_alternatives_description_search ON "Alternatives" USING gin(to_tsvector('german', description));

-- Vote-Indizes
CREATE INDEX IF NOT EXISTS idx_votes_user ON "Votes"("UserId");
CREATE INDEX IF NOT EXISTS idx_votes_alternative ON "Votes"("AlternativeId");
CREATE INDEX IF NOT EXISTS idx_votes_user_alternative ON "Votes"("UserId", "AlternativeId");

-- Comment-Indizes
CREATE INDEX IF NOT EXISTS idx_comments_alternative ON "Comments"("AlternativeId");
CREATE INDEX IF NOT EXISTS idx_comments_user ON "Comments"("UserId");
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON "Comments"("createdAt" DESC);

-- Tag-Indizes
CREATE INDEX IF NOT EXISTS idx_tags_slug ON "Tags"(slug);
CREATE INDEX IF NOT EXISTS idx_tags_name ON "Tags"(name);

-- AlternativeTag-Indizes
CREATE INDEX IF NOT EXISTS idx_alternative_tags_alternative ON "AlternativeTags"("AlternativeId");
CREATE INDEX IF NOT EXISTS idx_alternative_tags_tag ON "AlternativeTags"("TagId");

-- Bookmark-Indizes
CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON "Bookmarks"("UserId");
CREATE INDEX IF NOT EXISTS idx_bookmarks_alternative ON "Bookmarks"("AlternativeId");

-- User-Indizes
CREATE INDEX IF NOT EXISTS idx_users_email ON "Users"(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON "Users"(username);
