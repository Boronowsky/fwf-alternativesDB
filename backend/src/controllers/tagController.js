const { Tag, Alternative } = require('../models');
const logger = require('../utils/logger');

// Alle Tags abrufen
exports.getAllTags = async (req, res) => {
  try {
    const tags = await Tag.findAll({
      order: [['name', 'ASC']]
    });

    res.json(tags);
  } catch (error) {
    logger.error('Fehler beim Abrufen der Tags:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Tags.' });
  }
};

// Tag erstellen (nur Admin)
exports.createTag = async (req, res) => {
  const { name, color } = req.body;

  try {
    // Slug aus Name erstellen
    const slug = name.toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]/g, '');

    const tag = await Tag.create({
      name,
      slug,
      color
    });

    res.status(201).json(tag);
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ message: 'Tag existiert bereits.' });
    }
    logger.error('Fehler beim Erstellen des Tags:', error);
    res.status(500).json({ message: 'Serverfehler beim Erstellen des Tags.' });
  }
};

// Tag aktualisieren (nur Admin)
exports.updateTag = async (req, res) => {
  const { name, color } = req.body;

  try {
    const tag = await Tag.findByPk(req.params.id);

    if (!tag) {
      return res.status(404).json({ message: 'Tag nicht gefunden.' });
    }

    if (name) {
      tag.name = name;
      tag.slug = name.toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]/g, '');
    }
    if (color) tag.color = color;

    await tag.save();

    res.json(tag);
  } catch (error) {
    logger.error('Fehler beim Aktualisieren des Tags:', error);
    res.status(500).json({ message: 'Serverfehler beim Aktualisieren des Tags.' });
  }
};

// Tag löschen (nur Admin)
exports.deleteTag = async (req, res) => {
  try {
    const tag = await Tag.findByPk(req.params.id);

    if (!tag) {
      return res.status(404).json({ message: 'Tag nicht gefunden.' });
    }

    await tag.destroy();

    res.json({ message: 'Tag erfolgreich gelöscht.' });
  } catch (error) {
    logger.error('Fehler beim Löschen des Tags:', error);
    res.status(500).json({ message: 'Serverfehler beim Löschen des Tags.' });
  }
};

// Tags zu Alternative hinzufügen
exports.addTagsToAlternative = async (req, res) => {
  const { tagIds } = req.body;
  const { id } = req.params;

  try {
    const alternative = await Alternative.findByPk(id);

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    // Überprüfen ob Benutzer der Ersteller oder Admin ist
    if (alternative.submitterId !== req.user.id && !req.user.isAdmin) {
      return res.status(403).json({ message: 'Keine Berechtigung.' });
    }

    await alternative.setTags(tagIds);

    const updatedAlternative = await Alternative.findByPk(id, {
      include: [Tag]
    });

    res.json(updatedAlternative);
  } catch (error) {
    logger.error('Fehler beim Hinzufügen der Tags:', error);
    res.status(500).json({ message: 'Serverfehler beim Hinzufügen der Tags.' });
  }
};
