const { Tag, User, Alternative } = require('../models');
const bcrypt = require('bcryptjs');
const logger = require('./logger');

async function seedTags() {
  try {
    const tagCount = await Tag.count();
    if (tagCount > 0) {
      logger.info('Tags bereits vorhanden, überspringe Seeding.');
      return;
    }

    const defaultTags = [
      { name: 'Open Source', slug: 'open-source', color: '#10B981' },
      { name: 'Privacy', slug: 'privacy', color: '#3B82F6' },
      { name: 'Kostenlos', slug: 'kostenlos', color: '#8B5CF6' },
      { name: 'Self-Hosted', slug: 'self-hosted', color: '#F59E0B' },
      { name: 'Verschlüsselt', slug: 'verschluesselt', color: '#EF4444' },
      { name: 'No Tracking', slug: 'no-tracking', color: '#6366F1' },
      { name: 'DSGVO-konform', slug: 'dsgvo-konform', color: '#14B8A6' },
      { name: 'Made in EU', slug: 'made-in-eu', color: '#F97316' },
    ];

    await Tag.bulkCreate(defaultTags);
    logger.info('Standard-Tags erfolgreich erstellt.');
    return defaultTags;
  } catch (error) {
    logger.error('Fehler beim Seeding der Tags:', error);
    return [];
  }
}

async function seedUsers() {
  try {
    // Admin User
    const adminExists = await User.findOne({ where: { email: 'admin@freeworldfirst.com' } });
    if (!adminExists) {
      await User.create({
        username: 'admin',
        email: 'admin@freeworldfirst.com',
        password: 'AdminPassword123!', // wird automatisch gehasht durch beforeCreate hook
        isAdmin: true
      });
      logger.info('✓ Admin erstellt: admin@freeworldfirst.com / AdminPassword123!');
    } else {
      logger.info('Admin bereits vorhanden.');
    }

    // Beispiel-User
    const demoUsers = [
      { username: 'alice', email: 'alice@example.com', password: 'Demo123456!' },
      { username: 'bob', email: 'bob@example.com', password: 'Demo123456!' },
      { username: 'charlie', email: 'charlie@example.com', password: 'Demo123456!' }
    ];

    for (const userData of demoUsers) {
      const exists = await User.findOne({ where: { email: userData.email } });
      if (!exists) {
        await User.create(userData);
        logger.info(`✓ Demo-User erstellt: ${userData.email} / Demo123456!`);
      }
    }

    return await User.findAll();
  } catch (error) {
    logger.error('Fehler beim Erstellen der Benutzer:', error);
    return [];
  }
}

async function seedAlternatives() {
  try {
    const alternativeCount = await Alternative.count();
    if (alternativeCount > 0) {
      logger.info('Alternativen bereits vorhanden, überspringe Seeding.');
      return;
    }

    const users = await User.findAll();
    if (users.length === 0) {
      logger.warn('Keine User vorhanden, überspringe Alternative-Seeding.');
      return;
    }

    const tags = await Tag.findAll();
    const submitter = users[0]; // Nutze den ersten User (Admin) als Ersteller

    const exampleAlternatives = [
      {
        title: 'Signal',
        replaces: 'WhatsApp',
        description: 'Signal ist ein kostenloser, quelloffener Messenger mit Ende-zu-Ende-Verschlüsselung. Entwickelt von der gemeinnützigen Signal Foundation, bietet er maximale Privatsphäre ohne Datensammlung.',
        reasons: 'WhatsApp gehört zu Meta und sammelt umfangreiche Metadaten. Signal hingegen speichert praktisch keine Nutzerdaten und ist vollständig Open Source.',
        benefits: 'Vollständige Ende-zu-Ende-Verschlüsselung, Open Source, keine Datenweitergabe, kostenlos, verschwindende Nachrichten, Sprach- und Videoanrufe',
        website: 'https://signal.org',
        category: 'Messaging',
        approved: true,
        submitterId: submitter.id,
        tags: ['Privacy', 'Open Source', 'Verschlüsselt', 'Kostenlos']
      },
      {
        title: 'Nextcloud',
        replaces: 'Google Drive / Dropbox',
        description: 'Nextcloud ist eine selbst-gehostete Cloud-Speicher-Lösung. Sie bietet Dateisynchronisation, Kalender, Kontakte, Notizen und vieles mehr - alles auf deinem eigenen Server.',
        reasons: 'Bei Google Drive und Dropbox liegen deine Daten auf fremden Servern. Mit Nextcloud behältst du die volle Kontrolle über deine Daten.',
        benefits: 'Selbst-gehostet, volle Datenkontrolle, erweiterbar durch Apps, DSGVO-konform, Open Source, kostenlos',
        website: 'https://nextcloud.com',
        category: 'Cloud Storage',
        approved: true,
        submitterId: submitter.id,
        tags: ['Open Source', 'Self-Hosted', 'Privacy', 'DSGVO-konform']
      },
      {
        title: 'Firefox',
        replaces: 'Google Chrome',
        description: 'Firefox ist ein freier Webbrowser der gemeinnützigen Mozilla Foundation. Er setzt auf Datenschutz, Transparenz und Nutzerrechte.',
        reasons: 'Chrome sammelt umfangreiche Daten für Google. Firefox respektiert deine Privatsphäre und blockiert Tracker standardmäßig.',
        benefits: 'Open Source, integrierter Tracking-Schutz, keine Datensammlung, erweiterbar, plattformübergreifend',
        website: 'https://firefox.com',
        category: 'Browser',
        approved: true,
        submitterId: submitter.id,
        tags: ['Open Source', 'Privacy', 'No Tracking', 'Kostenlos']
      },
      {
        title: 'DuckDuckGo',
        replaces: 'Google Search',
        description: 'DuckDuckGo ist eine Suchmaschine, die keine persönlichen Informationen sammelt oder trackt. Alle Nutzer sehen die gleichen Suchergebnisse.',
        reasons: 'Google erstellt detaillierte Profile basierend auf deinen Suchanfragen. DuckDuckGo trackt dich nicht und verkauft keine Daten.',
        benefits: 'Keine Tracking, keine Personalisierung, keine Filterblasen, Open-Source-Komponenten, kostenlos',
        website: 'https://duckduckgo.com',
        category: 'Suchmaschine',
        approved: true,
        submitterId: submitter.id,
        tags: ['Privacy', 'No Tracking', 'Kostenlos']
      },
      {
        title: 'Mastodon',
        replaces: 'Twitter / X',
        description: 'Mastodon ist ein dezentrales soziales Netzwerk. Es besteht aus unabhängigen Servern, die miteinander kommunizieren können.',
        reasons: 'Twitter/X wird zentral von einem Unternehmen kontrolliert. Mastodon ist dezentral und Open Source - keine Firma kann dich zensieren oder sperren.',
        benefits: 'Dezentral, Open Source, keine Werbung, keine Algorithmen, eigener Server möglich, kostenlos',
        website: 'https://joinmastodon.org',
        category: 'Social Media',
        approved: true,
        submitterId: submitter.id,
        tags: ['Open Source', 'Self-Hosted', 'Privacy', 'Kostenlos']
      },
      {
        title: 'Bitwarden',
        replaces: 'LastPass',
        description: 'Bitwarden ist ein Open-Source Passwort-Manager mit starker Verschlüsselung. Verfügbar als Cloud-Service oder selbst-gehostet.',
        reasons: 'LastPass hatte mehrere Sicherheitsvorfälle. Bitwarden ist Open Source, transparent und bietet starke Sicherheit.',
        benefits: 'Open Source, Ende-zu-Ende-Verschlüsselung, selbst-hostbar, plattformübergreifend, kostenlose Version verfügbar',
        website: 'https://bitwarden.com',
        category: 'Passwort-Manager',
        approved: true,
        submitterId: submitter.id,
        tags: ['Open Source', 'Verschlüsselt', 'Self-Hosted', 'Privacy']
      }
    ];

    for (const altData of exampleAlternatives) {
      const tagNames = altData.tags;
      delete altData.tags;

      const alternative = await Alternative.create(altData);

      // Tags hinzufügen
      const alternativeTags = tags.filter(tag => tagNames.includes(tag.name));
      if (alternativeTags.length > 0) {
        await alternative.setTags(alternativeTags);
      }

      logger.info(`✓ Alternative erstellt: ${alternative.title}`);
    }

    logger.info(`Insgesamt ${exampleAlternatives.length} Beispiel-Alternativen erstellt.`);
  } catch (error) {
    logger.error('Fehler beim Erstellen der Alternativen:', error);
  }
}

async function seedAll() {
  logger.info('🌱 Starte Daten-Seeding...');

  await seedTags();
  await seedUsers();
  await seedAlternatives();

  logger.info('✅ Seeding abgeschlossen!');
}

// Legacy-Export für Kompatibilität
async function seedAdmin() {
  await seedUsers();
}

module.exports = {
  seedTags,
  seedAdmin, // Legacy
  seedUsers,
  seedAlternatives,
  seedAll
};
