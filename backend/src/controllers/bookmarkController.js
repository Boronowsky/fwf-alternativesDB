const { Bookmark, Alternative, User, Tag } = require('../models');
const logger = require('../utils/logger');

// Alle Bookmarks des Benutzers abrufen
exports.getUserBookmarks = async (req, res) => {
  try {
    const bookmarks = await Bookmark.findAll({
      where: { UserId: req.user.id },
      include: [
        {
          model: Alternative,
          include: [
            {
              model: User,
              as: 'submitter',
              attributes: ['id', 'username']
            },
            {
              model: Tag,
              attributes: ['id', 'name', 'slug', 'color']
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(bookmarks);
  } catch (error) {
    logger.error('Fehler beim Abrufen der Bookmarks:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Bookmarks.' });
  }
};

// Bookmark hinzufügen
exports.addBookmark = async (req, res) => {
  const { alternativeId } = req.body;

  try {
    // Überprüfen ob Alternative existiert
    const alternative = await Alternative.findByPk(alternativeId);
    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    // Überprüfen ob Bookmark bereits existiert
    const existingBookmark = await Bookmark.findOne({
      where: {
        UserId: req.user.id,
        AlternativeId: alternativeId
      }
    });

    if (existingBookmark) {
      return res.status(400).json({ message: 'Bookmark existiert bereits.' });
    }

    const bookmark = await Bookmark.create({
      UserId: req.user.id,
      AlternativeId: alternativeId
    });

    const bookmarkWithAlternative = await Bookmark.findByPk(bookmark.id, {
      include: [
        {
          model: Alternative,
          include: [
            {
              model: User,
              as: 'submitter',
              attributes: ['id', 'username']
            },
            {
              model: Tag,
              attributes: ['id', 'name', 'slug', 'color']
            }
          ]
        }
      ]
    });

    res.status(201).json(bookmarkWithAlternative);
  } catch (error) {
    logger.error('Fehler beim Hinzufügen des Bookmarks:', error);
    res.status(500).json({ message: 'Serverfehler beim Hinzufügen des Bookmarks.' });
  }
};

// Bookmark entfernen
exports.removeBookmark = async (req, res) => {
  const { alternativeId } = req.params;

  try {
    const bookmark = await Bookmark.findOne({
      where: {
        UserId: req.user.id,
        AlternativeId: alternativeId
      }
    });

    if (!bookmark) {
      return res.status(404).json({ message: 'Bookmark nicht gefunden.' });
    }

    await bookmark.destroy();

    res.json({ message: 'Bookmark erfolgreich entfernt.' });
  } catch (error) {
    logger.error('Fehler beim Entfernen des Bookmarks:', error);
    res.status(500).json({ message: 'Serverfehler beim Entfernen des Bookmarks.' });
  }
};

// Überprüfen ob Alternative gebookmarkt ist
exports.checkBookmark = async (req, res) => {
  const { alternativeId } = req.params;

  try {
    const bookmark = await Bookmark.findOne({
      where: {
        UserId: req.user.id,
        AlternativeId: alternativeId
      }
    });

    res.json({ isBookmarked: !!bookmark });
  } catch (error) {
    logger.error('Fehler beim Überprüfen des Bookmarks:', error);
    res.status(500).json({ message: 'Serverfehler beim Überprüfen des Bookmarks.' });
  }
};
