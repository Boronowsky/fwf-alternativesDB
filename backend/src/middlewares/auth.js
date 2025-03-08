const jwt = require('jsonwebtoken');
const config = require('../config/config')[process.env.NODE_ENV === 'production' ? 'production' : 'development'];
const { User } = require('../models');

exports.protect = async (req, res, next) => {
  let token;

  // Token aus dem Authorization-Header extrahieren
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({ message: 'Nicht autorisiert. Bitte anmelden.' });
  }

  try {
    // Token verifizieren
    const decoded = jwt.verify(token, config.jwtSecret);

    // Benutzer aus der Datenbank abrufen
    const user = await User.findByPk(decoded.id);

    if (!user) {
      return res.status(401).json({ message: 'Benutzer nicht gefunden.' });
    }

    // Benutzer-Objekt an die Request anhängen
    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Ungültiger Token. Bitte erneut anmelden.' });
  }
};

exports.admin = (req, res, next) => {
  if (req.user && req.user.isAdmin) {
    next();
  } else {
    res.status(403).json({ message: 'Keine Berechtigung. Admin-Rechte erforderlich.' });
  }
};
