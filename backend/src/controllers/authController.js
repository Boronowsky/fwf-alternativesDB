const jwt = require('jsonwebtoken');
const { User } = require('../models');
const config = require('../config/config')[process.env.NODE_ENV === 'production' ? 'production' : 'development'];
const logger = require('../utils/logger');

// JWT-Token generieren
const generateToken = (id, username, email, isAdmin) => {
  return jwt.sign(
    { id, username, email, isAdmin },
    config.jwtSecret,
    { expiresIn: config.jwtExpiry }
  );
};

// Benutzer registrieren
exports.register = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Überprüfen, ob Benutzername oder E-Mail bereits existieren
    const existingUser = await User.findOne({
      where: {
        [Sequelize.Op.or]: [
          { username },
          { email }
        ]
      }
    });

    if (existingUser) {
      if (existingUser.username === username) {
        return res.status(400).json({ message: 'Benutzername bereits vergeben.' });
      }
      return res.status(400).json({ message: 'E-Mail bereits registriert.' });
    }

    // Neuen Benutzer erstellen
    const user = await User.create({
      username,
      email,
      password
    });

    // Token generieren
    const token = generateToken(user.id, user.username, user.email, user.isAdmin);

    res.status(201).json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        isAdmin: user.isAdmin
      }
    });
  } catch (error) {
    logger.error('Fehler bei der Registrierung:', error);
    res.status(500).json({ message: 'Serverfehler bei der Registrierung.' });
  }
};

// Benutzer anmelden
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Benutzer in der Datenbank suchen
    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(401).json({ message: 'Ungültige E-Mail oder Passwort.' });
    }

    // Passwort überprüfen
    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Ungültige E-Mail oder Passwort.' });
    }

    // Token generieren
    const token = generateToken(user.id, user.username, user.email, user.isAdmin);

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        isAdmin: user.isAdmin
      }
    });
  } catch (error) {
    logger.error('Fehler beim Login:', error);
    res.status(500).json({ message: 'Serverfehler beim Login.' });
  }
};

// Benutzerprofil abrufen
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password'] }
    });

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht gefunden.' });
    }

    res.json(user);
  } catch (error) {
    logger.error('Fehler beim Abrufen des Profils:', error);
    res.status(500).json({ message: 'Serverfehler beim Abrufen des Profils.' });
  }
};

// Benutzerprofil aktualisieren
exports.updateProfile = async (req, res) => {
  const { username, email } = req.body;

  try {
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht gefunden.' });
    }

    // Überprüfen, ob Benutzername oder E-Mail bereits existieren
    if (username && username !== user.username) {
      const existingUsername = await User.findOne({ where: { username } });
      if (existingUsername) {
        return res.status(400).json({ message: 'Benutzername bereits vergeben.' });
      }
      user.username = username;
    }

    if (email && email !== user.email) {
      const existingEmail = await User.findOne({ where: { email } });
      if (existingEmail) {
        return res.status(400).json({ message: 'E-Mail bereits registriert.' });
      }
      user.email = email;
    }

    await user.save();

    res.json({
      id: user.id,
      username: user.username,
      email: user.email,
      isAdmin: user.isAdmin
    });
  } catch (error) {
    logger.error('Fehler beim Aktualisieren des Profils:', error);
    res.status(500).json({ message: 'Serverfehler beim Aktualisieren des Profils.' });
  }
};

// Passwort ändern
exports.changePassword = async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  try {
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht gefunden.' });
    }

    // Altes Passwort überprüfen
    const isMatch = await user.comparePassword(oldPassword);

    if (!isMatch) {
      return res.status(401).json({ message: 'Aktuelles Passwort ist falsch.' });
    }

    // Neues Passwort setzen
    user.password = newPassword;
    await user.save();

    res.json({ message: 'Passwort erfolgreich geändert.' });
  } catch (error) {
    logger.error('Fehler beim Ändern des Passworts:', error);
    res.status(500).json({ message: 'Serverfehler beim Ändern des Passworts.' });
  }
};
