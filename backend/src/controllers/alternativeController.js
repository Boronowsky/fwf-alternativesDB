const { Alternative, User, Comment, Vote, sequelize } = require('../models');
const logger = require('../utils/logger');
const { Op } = require('sequelize');

// Alle Alternativen abrufen (mit Pagination und Filtern)
exports.getAlternatives = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const category = req.query.category;
    const search = req.query.search;
    const approved = req.query.approved === 'true';

    const whereClause = {};
    
    // Filter nach Kategorie
    if (category) {
      whereClause.category = category;
    }
    
    // Suche nach Titel oder ersetztem Produkt
    if (search) {
      whereClause[Op.or] = [
        { title: { [Op.iLike]: `%${search}%` } },
        { replaces: { [Op.iLike]: `%${search}%` } }
      ];
    }
    
    // Filter nach Genehmigungsstatus
    if (!req.user?.isAdmin) {
      whereClause.approved = true;
    } else if (req.query.approved !== undefined) {
      whereClause.approved = approved;
    }

    const { count, rows } = await Alternative.findAndCountAll({
      where: whereClause,
      limit,
      offset,
      include: [
        {
          model: User,
          as: 'submitter',
          attributes: ['id', 'username']
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json({
      alternatives: rows,
      page,
      pages: Math.ceil(count / limit),
      total: count
    });
  } catch (error) {
    logger.error('Fehler beim Abrufen der Alternativen:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Alternativen.' });
  }
};

// Neueste Alternativen abrufen
exports.getLatestAlternatives = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 6;
    
    const alternatives = await Alternative.findAll({
      where: { approved: true },
      limit,
      include: [
        {
          model: User,
          as: 'submitter',
          attributes: ['id', 'username']
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(alternatives);
  } catch (error) {
    logger.error('Fehler beim Abrufen der neuesten Alternativen:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der neuesten Alternativen.' });
  }
};

// Alternative nach ID abrufen
exports.getAlternativeById = async (req, res) => {
  try {
    const alternative = await Alternative.findByPk(req.params.id, {
      include: [
        {
          model: User,
          as: 'submitter',
          attributes: ['id', 'username']
        }
      ]
    });

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    // Wenn Alternative nicht genehmigt ist und Benutzer kein Admin ist
    if (!alternative.approved && !req.user?.isAdmin) {
      return res.status(403).json({ message: 'Diese Alternative wurde noch nicht freigegeben.' });
    }

    res.json(alternative);
  } catch (error) {
    logger.error('Fehler beim Abrufen der Alternative:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Alternative.' });
  }
};

// Neue Alternative erstellen
exports.createAlternative = async (req, res) => {
  const { title, replaces, description, reasons, benefits, website, category } = req.body;

  try {
    // Überprüfen, ob eine ähnliche Alternative bereits existiert
    const existingAlternative = await Alternative.findOne({
      where: {
        [Op.or]: [
          { title: { [Op.iLike]: title } },
          { 
            [Op.and]: [
              { replaces: { [Op.iLike]: replaces } },
              { category }
            ]
          }
        ]
      }
    });

    if (existingAlternative) {
      return res.status(400).json({ 
        message: 'Eine ähnliche Alternative existiert bereits.',
        alternativeId: existingAlternative.id
      });
    }

    const alternative = await Alternative.create({
      title,
      replaces,
      description,
      reasons,
      benefits,
      website,
      category,
      submitterId: req.user.id,
      approved: req.user.isAdmin // Automatisch genehmigt, wenn vom Admin erstellt
    });

    res.status(201).json(alternative);
  } catch (error) {
    logger.error('Fehler beim Erstellen der Alternative:', error);
    res.status(500).json({ message: 'Serverfehler beim Erstellen der Alternative.' });
  }
};

// Alternative aktualisieren
exports.updateAlternative = async (req, res) => {
  const { title, replaces, description, reasons, benefits, website, category, approved } = req.body;

  try {
    const alternative = await Alternative.findByPk(req.params.id);

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    // Überprüfen, ob der Benutzer der Ersteller oder ein Admin ist
    if (alternative.submitterId !== req.user.id && !req.user.isAdmin) {
      return res.status(403).json({ message: 'Keine Berechtigung zum Bearbeiten dieser Alternative.' });
    }

    // Felder aktualisieren
    alternative.title = title || alternative.title;
    alternative.replaces = replaces || alternative.replaces;
    alternative.description = description || alternative.description;
    alternative.reasons = reasons || alternative.reasons;
    alternative.benefits = benefits || alternative.benefits;
    alternative.website = website || alternative.website;
    alternative.category = category || alternative.category;
    
    // Nur Admins können den Genehmigungsstatus ändern
    if (req.user.isAdmin && approved !== undefined) {
      alternative.approved = approved;
    }

    await alternative.save();

    res.json(alternative);
  } catch (error) {
    logger.error('Fehler beim Aktualisieren der Alternative:', error);
    res.status(500).json({ message: 'Serverfehler beim Aktualisieren der Alternative.' });
  }
};

// Alternative löschen
exports.deleteAlternative = async (req, res) => {
  try {
    const alternative = await Alternative.findByPk(req.params.id);

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    // Überprüfen, ob der Benutzer der Ersteller oder ein Admin ist
    if (alternative.submitterId !== req.user.id && !req.user.isAdmin) {
      return res.status(403).json({ message: 'Keine Berechtigung zum Löschen dieser Alternative.' });
    }

    await alternative.destroy();

    res.json({ message: 'Alternative erfolgreich gelöscht.' });
  } catch (error) {
    logger.error('Fehler beim Löschen der Alternative:', error);
    res.status(500).json({ message: 'Serverfehler beim Löschen der Alternative.' });
  }
};

// Für eine Alternative abstimmen
exports.voteAlternative = async (req, res) => {
  const { id } = req.params;
  const { type } = req.body; // 'upvote' oder 'downvote'

  if (type !== 'upvote' && type !== 'downvote') {
    return res.status(400).json({ message: 'Ungültiger Abstimmungstyp.' });
  }

  try {
    const alternative = await Alternative.findByPk(id);

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    // Überprüfen, ob der Benutzer bereits abgestimmt hat
    const existingVote = await Vote.findOne({
      where: {
        userId: req.user.id,
        alternativeId: id
      }
    });

    const transaction = await sequelize.transaction();

    try {
if (existingVote) {
        // Wenn der Benutzer bereits abgestimmt hat
        if (existingVote.type === type) {
          // Benutzer stimmt erneut mit dem gleichen Typ ab -> Stimme entfernen
          await existingVote.destroy({ transaction });
          
          // Zähler aktualisieren
          if (type === 'upvote') {
            alternative.upvotes -= 1;
          } else {
            alternative.upvotes += 1;
          }
        } else {
          // Benutzer ändert seinen Abstimmungstyp
          existingVote.type = type;
          await existingVote.save({ transaction });
          
          // Zähler um 2 aktualisieren (1 für Entfernen des alten Typs, 1 für Hinzufügen des neuen)
          if (type === 'upvote') {
            alternative.upvotes += 2;
          } else {
            alternative.upvotes -= 2;
          }
        }
      } else {
        // Neue Abstimmung erstellen
        await Vote.create({
          type,
          userId: req.user.id,
          alternativeId: id
        }, { transaction });
        
        // Zähler aktualisieren
        if (type === 'upvote') {
          alternative.upvotes += 1;
        } else {
          alternative.upvotes -= 1;
        }
      }

      await alternative.save({ transaction });
      await transaction.commit();

      res.json({ 
        message: 'Abstimmung erfolgreich aktualisiert.', 
        upvotes: alternative.upvotes 
      });
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  } catch (error) {
    logger.error('Fehler bei der Abstimmung:', error);
    res.status(500).json({ message: 'Serverfehler bei der Abstimmung.' });
  }
};

// Kommentare für eine Alternative abrufen
exports.getComments = async (req, res) => {
  try {
    const comments = await Comment.findAll({
      where: { alternativeId: req.params.id },
      include: [
        {
          model: User,
          attributes: ['id', 'username']
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(comments);
  } catch (error) {
    logger.error('Fehler beim Abrufen der Kommentare:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Kommentare.' });
  }
};

// Kommentar zu einer Alternative hinzufügen
exports.addComment = async (req, res) => {
  const { content } = req.body;

  try {
    const alternative = await Alternative.findByPk(req.params.id);

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    const comment = await Comment.create({
      content,
      userId: req.user.id,
      alternativeId: req.params.id
    });

    // Benutzerinformationen für die Antwort abrufen
    const commentWithUser = await Comment.findByPk(comment.id, {
      include: [
        {
          model: User,
          attributes: ['id', 'username']
        }
      ]
    });

    res.status(201).json(commentWithUser);
  } catch (error) {
    logger.error('Fehler beim Hinzufügen des Kommentars:', error);
    res.status(500).json({ message: 'Serverfehler beim Hinzufügen des Kommentars.' });
  }
};

// Überprüfen, ob eine Alternative bereits existiert
exports.checkIfAlternativeExists = async (req, res) => {
  const { name, replaces, category } = req.query;

  try {
    const whereClause = {};
    
    if (name) {
      whereClause.title = { [Op.iLike]: `%${name}%` };
    }
    
    if (replaces && category) {
      whereClause[Op.or] = [
        { title: { [Op.iLike]: `%${name}%` } },
        { 
          [Op.and]: [
            { replaces: { [Op.iLike]: `%${replaces}%` } }, // Korrigiert zu replaces
            { category }
          ]
        }
      ];
    }
    
    const existingAlternative = await Alternative.findOne({
      where: whereClause
    });

    res.json({ 
      exists: !!existingAlternative,
      alternative: existingAlternative
    });
  } catch (error) {
    logger.error('Fehler beim Überprüfen der Alternative:', error);
    res.status(500).json({ message: 'Serverfehler beim Überprüfen der Alternative.' });
  }
};
