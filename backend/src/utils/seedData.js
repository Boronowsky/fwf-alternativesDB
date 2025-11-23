const { Tag, User } = require('../models');
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
  } catch (error) {
    logger.error('Fehler beim Seeding der Tags:', error);
  }
}

async function seedAdmin() {
  try {
    const adminExists = await User.findOne({ where: { email: 'admin@freeworldfirst.com' } });
    if (adminExists) {
      logger.info('Admin-Benutzer bereits vorhanden.');
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('AdminPassword123!', salt);

    await User.create({
      username: 'admin',
      email: 'admin@freeworldfirst.com',
      password: hashedPassword,
      isAdmin: true
    });

    logger.info('Admin-Benutzer erfolgreich erstellt (admin@freeworldfirst.com / AdminPassword123!)');
  } catch (error) {
    logger.error('Fehler beim Erstellen des Admin-Benutzers:', error);
  }
}

module.exports = {
  seedTags,
  seedAdmin
};
