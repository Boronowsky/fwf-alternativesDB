const { Alternative, User, Comment, sequelize } = require('../models');
const { Op } = require('sequelize');  // Diese Zeile hinzufügen
const logger = require('../utils/logger');

// Dashboard-Statistiken abrufen
exports.getDashboardStats = async (req, res) => {
  try {
    const totalAlternatives = await Alternative.count();
    const pendingAlternatives = await Alternative.count({ where: { approved: false } });
    const totalUsers = await User.count();
    const totalComments = await Comment.count();

    const latestAlternatives = await Alternative.findAll({
      limit: 5,
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
      stats: {
        totalAlternatives,
        pendingAlternatives,
        totalUsers,
        totalComments
      },
      latestAlternatives
    });
  } catch (error) {
    logger.error('Fehler beim Abrufen der Dashboard-Statistiken:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Dashboard-Statistiken.' });
  }
};

// Benutzer verwalten (Liste abrufen)
exports.getUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const search = req.query.search;
    
    const whereClause = {};
    
    if (search) {
      whereClause[Op.or] = [
        { username: { [Op.iLike]: `%${search}%` } },  // search statt name
        { email: { [Op.iLike]: `%${search}%` } }     // search statt email
      ];
    }

    const { count, rows } = await User.findAndCountAll({
      where: whereClause,
      attributes: { exclude: ['password'] },
      limit,
      offset,
      order: [['createdAt', 'DESC']]
    });

    res.json({
      users: rows,
      page,
      pages: Math.ceil(count / limit),
      total: count
    });
  } catch (error) {
    logger.error('Fehler beim Abrufen der Benutzer:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen der Benutzer.' });
  }
};

// Benutzer-Admin-Status aktualisieren
exports.updateUserAdminStatus = async (req, res) => {
  const { isAdmin } = req.body;

  try {
    const user = await User.findByPk(req.params.id);

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht gefunden.' });
    }

    // Verhindern, dass der letzte Admin seine Rechte verliert
    if (user.isAdmin && !isAdmin) {
      const adminCount = await User.count({ where: { isAdmin: true } });
      if (adminCount <= 1) {
        return res.status(400).json({ message: 'Es muss mindestens ein Admin-Benutzer vorhanden sein.' });
      }
    }

    user.isAdmin = isAdmin;
    await user.save();

    res.json({
      id: user.id,
      username: user.username,
      email: user.email,
      isAdmin: user.isAdmin
    });
  } catch (error) {
    logger.error('Fehler beim Aktualisieren des Admin-Status:', error);
    res.status(500).json({ message: 'Serverfehler beim Aktualisieren des Admin-Status.' });
  }
};

// Alternative genehmigen oder ablehnen
exports.approveAlternative = async (req, res) => {
  const { approved } = req.body;

  try {
    const alternative = await Alternative.findByPk(req.params.id);

    if (!alternative) {
      return res.status(404).json({ message: 'Alternative nicht gefunden.' });
    }

    alternative.approved = approved;
    await alternative.save();

    res.json({ 
      message: `Alternative wurde ${approved ? 'genehmigt' : 'abgelehnt'}.`,
      alternative
    });
  } catch (error) {
    logger.error('Fehler beim Genehmigen/Ablehnen der Alternative:', error);
    res.status(500).json({ message: 'Serverfehler beim Genehmigen/Ablehnen der Alternative.' });
  }
};

// In backend/src/controllers/adminController.js hinzufügen

// Benutzerpasswort zurücksetzen
exports.resetUserPassword = async (req, res) => {
  const { userId } = req.params;
  const { newPassword } = req.body;

  try {
    if (!newPassword) {
      return res.status(400).json({ message: 'Neues Passwort ist erforderlich.' });
    }

    const user = await User.findByPk(userId);

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht gefunden.' });
    }

    // Passwort aktualisieren (der bcrypt-Hash wird automatisch durch den User-Model-Hook erstellt)
    user.password = newPassword;
    await user.save();

    res.json({ message: 'Passwort wurde erfolgreich zurückgesetzt.' });
  } catch (error) {
    logger.error('Fehler beim Zurücksetzen des Passworts:', error);
    res.status(500).json({ message: 'Serverfehler beim Zurücksetzen des Passworts.' });
  }
};

// Benutzer löschen
exports.deleteUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findByPk(userId);

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht gefunden.' });
    }

    // Verhindern, dass der letzte Admin gelöscht wird
    if (user.isAdmin) {
      const adminCount = await User.count({ where: { isAdmin: true } });
      if (adminCount <= 1) {
        return res.status(400).json({ message: 'Der letzte Administrator kann nicht gelöscht werden.' });
      }
    }

    await user.destroy();

    res.json({ message: 'Benutzer wurde erfolgreich gelöscht.' });
  } catch (error) {
    logger.error('Fehler beim Löschen des Benutzers:', error);
    res.status(500).json({ message: 'Serverfehler beim Löschen des Benutzers.' });
  }
};