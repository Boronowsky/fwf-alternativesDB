#!/bin/bash
# setup_backend.sh - Erstellt die Backend-Anwendung für FreeWorldFirst Collector

set -e  # Skript beenden, wenn ein Befehl fehlschlägt

# Farbcodes für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Hilfsfunktionen
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Erstellt package.json für das Backend
create_package_json() {
    log_info "Erstelle package.json für das Backend..."
    
    cat > backend/package.json << EOL
{
  "name": "freeworldfirst-collector-backend",
  "version": "1.0.0",
  "description": "Backend für FreeWorldFirst Collector",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest"
  },
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "express-validator": "^6.14.2",
    "helmet": "^6.0.1",
    "jsonwebtoken": "^9.0.0",
    "morgan": "^1.10.0",
    "pg": "^8.8.0",
    "pg-hstore": "^2.3.4",
    "sequelize": "^6.28.0",
    "winston": "^3.8.2"
  },
  "devDependencies": {
    "jest": "^29.3.1",
    "nodemon": "^2.0.20",
    "supertest": "^6.3.3"
  }
}
EOL

    log_info "package.json für das Backend wurde erstellt."
}

# Erstellt die Grundstruktur des Backends
create_backend_structure() {
    log_info "Erstelle Backend-Struktur..."
    
    mkdir -p backend/src/config
    mkdir -p backend/src/controllers
    mkdir -p backend/src/middlewares
    mkdir -p backend/src/models
    mkdir -p backend/src/routes
    mkdir -p backend/src/utils
    mkdir -p backend/src/services
    mkdir -p backend/tests
    
    log_info "Backend-Struktur wurde erstellt."
}

# Erstellt Umgebungsvariablen-Konfigurationen
create_env_config() {
    log_info "Erstelle Umgebungsvariablen-Konfiguration..."
    
    cat > backend/src/config/config.js << EOL
require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.prod' : '.env.dev' });

module.exports = {
  development: {
    port: process.env.APP_PORT || 8100,
    jwtSecret: process.env.JWT_SECRET || 'dev_jwt_secret',
    jwtExpiry: process.env.JWT_EXPIRY || '24h',
    database: {
      host: process.env.DB_HOST || 'postgres',
      port: process.env.DB_PORT || 5432,
      name: process.env.DB_NAME || 'fwf_collector_dev',
      user: process.env.DB_USER || 'fwf_user',
      password: process.env.DB_PASSWORD || 'dev_password'
    }
  },
  production: {
    port: process.env.APP_PORT || 8000,
    jwtSecret: process.env.JWT_SECRET || 'prod_jwt_secret',
    jwtExpiry: process.env.JWT_EXPIRY || '24h',
    database: {
      host: process.env.DB_HOST || 'postgres',
      port: process.env.DB_PORT || 5432,
      name: process.env.DB_NAME || 'fwf_collector_prod',
      user: process.env.DB_USER || 'fwf_user',
      password: process.env.DB_PASSWORD || 'prod_password'
    }
  }
};
EOL

    log_info "Umgebungsvariablen-Konfiguration wurde erstellt."
}

# Erstellt Datenbankverbindung
create_db_connection() {
    log_info "Erstelle Datenbankverbindung..."
    
    cat > backend/src/config/database.js << EOL
const { Sequelize } = require('sequelize');
const config = require('./config')[process.env.NODE_ENV === 'production' ? 'production' : 'development'];
const logger = require('../utils/logger');

const sequelize = new Sequelize(
  config.database.name,
  config.database.user,
  config.database.password,
  {
    host: config.database.host,
    port: config.database.port,
    dialect: 'postgres',
    logging: msg => logger.debug(msg),
    dialectOptions: {
      ssl: process.env.NODE_ENV === 'production' ? {
        require: true,
        rejectUnauthorized: false
      } : false
    },
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

const testConnection = async () => {
  try {
    await sequelize.authenticate();
    logger.info('Datenbankverbindung erfolgreich hergestellt.');
    return true;
  } catch (error) {
    logger.error('Fehler bei der Datenbankverbindung:', error);
    return false;
  }
};

module.exports = {
  sequelize,
  testConnection
};
EOL

    log_info "Datenbankverbindung wurde erstellt."
}

# Erstellt Logging-Funktionalität
create_logger() {
    log_info "Erstelle Logger..."
    
    cat > backend/src/utils/logger.js << EOL
const winston = require('winston');
const path = require('path');

const logFormat = winston.format.printf(({ level, message, timestamp }) => {
  return \`\${timestamp} [\${level.toUpperCase()}]: \${message}\`;
});

const logger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    logFormat
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        logFormat
      )
    }),
    new winston.transports.File({ 
      filename: path.join(__dirname, '../../logs/error.log'), 
      level: 'error' 
    }),
    new winston.transports.File({ 
      filename: path.join(__dirname, '../../logs/combined.log') 
    })
  ]
});

// Ordner für Logs erstellen
const fs = require('fs');
const logDir = path.join(__dirname, '../../logs');

if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

module.exports = logger;
EOL

    log_info "Logger wurde erstellt."
}

# Erstellt Modelle
create_models() {
    log_info "Erstelle Modelle..."
    
    # User-Modell
    cat > backend/src/models/User.js << EOL
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcryptjs');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  username: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      len: [3, 20]
    }
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  },
  isAdmin: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  hooks: {
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    }
  }
});

// Instance method zum Vergleichen der Passwörter
User.prototype.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = User;
EOL

    # Alternative-Modell
    cat > backend/src/models/Alternative.js << EOL
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Alternative = sequelize.define('Alternative', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  replaces: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  reasons: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  benefits: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  website: {
    type: DataTypes.STRING,
    allowNull: true
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false
  },
  upvotes: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  approved: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
});

module.exports = Alternative;
EOL

    # Comment-Modell
    cat > backend/src/models/Comment.js << EOL
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Comment = sequelize.define('Comment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
  }
});

module.exports = Comment;
EOL

    # Vote-Modell
    cat > backend/src/models/Vote.js << EOL
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Vote = sequelize.define('Vote', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  type: {
    type: DataTypes.ENUM('upvote', 'downvote'),
    allowNull: false
  }
});

module.exports = Vote;
EOL

    # Modell-Beziehungen definieren
    cat > backend/src/models/index.js << EOL
const User = require('./User');
const Alternative = require('./Alternative');
const Comment = require('./Comment');
const Vote = require('./Vote');

// Beziehungen definieren
Alternative.belongsTo(User, { as: 'submitter' });
User.hasMany(Alternative, { foreignKey: 'submitterId' });

Comment.belongsTo(User);
Comment.belongsTo(Alternative);
User.hasMany(Comment);
Alternative.hasMany(Comment);

Vote.belongsTo(User);
Vote.belongsTo(Alternative);
User.hasMany(Vote);
Alternative.hasMany(Vote);

module.exports = {
  User,
  Alternative,
  Comment,
  Vote
};
EOL

    log_info "Modelle wurden erstellt."
}

# Erstellt Middlewares
create_middlewares() {
    log_info "Erstelle Middlewares..."
    
    # Auth-Middleware
    cat > backend/src/middlewares/auth.js << EOL
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
EOL

    # Error-Handler-Middleware
    cat > backend/src/middlewares/errorHandler.js << EOL
const logger = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  
  logger.error(\`\${err.message} - \${req.originalUrl}\`);
  
  res.status(statusCode).json({
    message: err.message,
    stack: process.env.NODE_ENV === 'production' ? '🥞' : err.stack,
  });
};

module.exports = errorHandler;
EOL

    log_info "Middlewares wurden erstellt."
}

# Erstellt Controller
create_controllers() {
    log_info "Erstelle Controller..."
    
    # Auth-Controller
    cat > backend/src/controllers/authController.js << EOL
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
EOL

    # Alternative-Controller
    cat > backend/src/controllers/alternativeController.js << EOL
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
        { title: { [Op.iLike]: \`%\${search}%\` } },
        { replaces: { [Op.iLike]: \`%\${search}%\` } }
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
            { replaces: { [Op.iLike]: `%${replaces}%` } },
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
EOL

    # Admin-Controller
    cat > backend/src/controllers/adminController.js << EOL
const { Alternative, User, Comment, sequelize } = require('../models');
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
        { username: { [Op.iLike]: `%${search}%` } },
        { email: { [Op.iLike]: `%${search}%` } }
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
EOL

    log_info "Controller wurden erstellt."
}

# Erstellt Routen
create_routes() {
    log_info "Erstelle Routen..."
    
    # Auth-Routen
    cat > backend/src/routes/authRoutes.js << EOL
const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const { protect } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Benutzer registrieren
router.post(
  '/register',
  [
    body('username')
      .isLength({ min: 3, max: 20 })
      .withMessage('Benutzername muss zwischen 3 und 20 Zeichen lang sein')
      .trim(),
    body('email')
      .isEmail()
      .withMessage('Gültige E-Mail-Adresse erforderlich')
      .normalizeEmail(),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Passwort muss mindestens 8 Zeichen lang sein')
  ],
  validateRequest,
  authController.register
);

// Benutzer anmelden
router.post(
  '/login',
  [
    body('email')
      .isEmail()
      .withMessage('Gültige E-Mail-Adresse erforderlich')
      .normalizeEmail(),
    body('password')
      .not()
      .isEmpty()
      .withMessage('Passwort erforderlich')
  ],
  validateRequest,
  authController.login
);

// Benutzerprofil abrufen
router.get('/profile', protect, authController.getProfile);

// Benutzerprofil aktualisieren
router.put(
  '/profile',
  protect,
  [
    body('username')
      .optional()
      .isLength({ min: 3, max: 20 })
      .withMessage('Benutzername muss zwischen 3 und 20 Zeichen lang sein')
      .trim(),
    body('email')
      .optional()
      .isEmail()
      .withMessage('Gültige E-Mail-Adresse erforderlich')
      .normalizeEmail()
  ],
  validateRequest,
  authController.updateProfile
);

// Passwort ändern
router.put(
  '/password',
  protect,
  [
    body('oldPassword')
      .not()
      .isEmpty()
      .withMessage('Aktuelles Passwort erforderlich'),
    body('newPassword')
      .isLength({ min: 8 })
      .withMessage('Neues Passwort muss mindestens 8 Zeichen lang sein')
  ],
  validateRequest,
  authController.changePassword
);

module.exports = router;
EOL

    # Alternative-Routen
    cat > backend/src/routes/alternativeRoutes.js << EOL
const express = require('express');
const { body, query } = require('express-validator');
const alternativeController = require('../controllers/alternativeController');
const { protect } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Öffentliche Routen
router.get('/', alternativeController.getAlternatives);
router.get('/latest', alternativeController.getLatestAlternatives);
router.get('/check', alternativeController.checkIfAlternativeExists);
router.get('/:id', alternativeController.getAlternativeById);
router.get('/:id/comments', alternativeController.getComments);

// Geschützte Routen
router.post(
  '/',
  protect,
  [
    body('title')
      .isLength({ min: 3, max: 100 })
      .withMessage('Titel muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('replaces')
      .isLength({ min: 3, max: 100 })
      .withMessage('Zu ersetzendes Produkt muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('description')
      .isLength({ min: 10 })
      .withMessage('Beschreibung muss mindestens 10 Zeichen lang sein')
      .trim(),
    body('reasons')
      .isLength({ min: 10 })
      .withMessage('Gründe müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('benefits')
      .isLength({ min: 10 })
      .withMessage('Vorteile müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('category')
      .not()
      .isEmpty()
      .withMessage('Kategorie erforderlich')
      .trim()
  ],
  validateRequest,
  alternativeController.createAlternative
);

router.put(
  '/:id',
  protect,
  [
    body('title')
      .optional()
      .isLength({ min: 3, max: 100 })
      .withMessage('Titel muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('replaces')
      .optional()
      .isLength({ min: 3, max: 100 })
      .withMessage('Zu ersetzendes Produkt muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('description')
      .optional()
      .isLength({ min: 10 })
      .withMessage('Beschreibung muss mindestens 10 Zeichen lang sein')
      .trim(),
    body('reasons')
      .optional()
      .isLength({ min: 10 })
      .withMessage('Gründe müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('benefits')
      .optional()
      .isLength({ min: 10 })
      .withMessage('Vorteile müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('category')
      .optional()
      .not()
      .isEmpty()
      .withMessage('Kategorie erforderlich')
      .trim()
  ],
  validateRequest,
  alternativeController.updateAlternative
);

router.delete('/:id', protect, alternativeController.deleteAlternative);

router.post(
  '/:id/vote',
  protect,
  [
    body('type')
      .isIn(['upvote', 'downvote'])
      .withMessage('Abstimmungstyp muss "upvote" oder "downvote" sein')
  ],
  validateRequest,
  alternativeController.voteAlternative
);

router.post(
  '/:id/comments',
  protect,
  [
    body('content')
      .isLength({ min: 3 })
      .withMessage('Kommentar muss mindestens 3 Zeichen lang sein')
      .trim()
  ],
  validateRequest,
  alternativeController.addComment
);

module.exports = router;
EOL

    # Admin-Routen
    cat > backend/src/routes/adminRoutes.js << EOL
const express = require('express');
const { body } = require('express-validator');
const adminController = require('../controllers/adminController');
const { protect, admin } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Alle Admin-Routen werden mit protect und admin Middleware geschützt
router.use(protect, admin);

// Dashboard-Statistiken
router.get('/dashboard', adminController.getDashboardStats);

// Benutzer verwalten
router.get('/users', adminController.getUsers);

router.put(
  '/users/:id',
  [
    body('isAdmin')
      .isBoolean()
      .withMessage('isAdmin muss ein Boolean-Wert sein')
  ],
  validateRequest,
  adminController.updateUserAdminStatus
);

// Alternativen genehmigen/ablehnen
router.put(
  '/alternatives/:id/approve',
  [
    body('approved')
      .isBoolean()
      .withMessage('approved muss ein Boolean-Wert sein')
  ],
  validateRequest,
  adminController.approveAlternative
);

module.exports = router;
EOL

    # Haupt-Routen-Datei
    cat > backend/src/routes/index.js << EOL
const express = require('express');
const authRoutes = require('./authRoutes');
const alternativeRoutes = require('./alternativeRoutes');
const adminRoutes = require('./adminRoutes');

const router = express.Router();

// API-Routen
router.use('/auth', authRoutes);
router.use('/alternatives', alternativeRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
EOL

    log_info "Routen wurden erstellt."
}

# Erstellt die Haupt-App-Datei
create_main_app() {
    log_info "Erstelle Haupt-App-Datei..."
    
    cat > backend/src/index.js << EOL
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { sequelize, testConnection } = require('./config/database');
const routes = require('./routes');
const logger = require('./utils/logger');
const errorHandler = require('./middlewares/errorHandler');
const config = require('./config/config')[process.env.NODE_ENV === 'production' ? 'production' : 'development'];

// Initialisiere Express-App
const app = express();
const PORT = config.port;

// Middlewares
app.use(cors());
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging-Middleware
app.use(morgan('dev', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

// API-Routen
app.use('/api', routes);

// Einfache Startseite für API
app.get('/', (req, res) => {
  res.json({
    message: 'Willkommen bei der FreeWorldFirst Collector API',
    version: '1.0.0',
    env: process.env.NODE_ENV || 'development'
  });
});

// 404-Handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route nicht gefunden' });
});

// Error-Handler
app.use(errorHandler);

// Starte den Server
const startServer = async () => {
  try {
    // Teste Datenbankverbindung
    const dbConnected = await testConnection();
    
    if (!dbConnected) {
      logger.error('Datenbankverbindung konnte nicht hergestellt werden. Server wird nicht gestartet.');
      process.exit(1);
    }
    
    // Synchronisiere Modelle mit der Datenbank
    await sequelize.sync({ alter: true });
    logger.info('Datenbankmodelle wurden synchronisiert.');
    
    // Starte den Server
    app.listen(PORT, () => {
      logger.info(\`Server läuft im \${process.env.NODE_ENV || 'development'}-Modus auf Port \${PORT}\`);
    });
  } catch (error) {
    logger.error('Fehler beim Starten des Servers:', error);
    process.exit(1);
  }
};

startServer();

// Handle unerwartete Fehler
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Promise Rejection:', err);
  // Beende den Prozess nicht, um den Server am Laufen zu halten
});

process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  // Beende den Prozess in einer kontrollierten Weise
  process.exit(1);
});
EOL

    log_info "Haupt-App-Datei wurde erstellt."
}

# Erstellt eine einfache Validierungs-Middleware
create_validation_middleware() {
    log_info "Erstelle Validierungs-Middleware..."
    
    cat > backend/src/middlewares/validateRequest.js << EOL
const { validationResult } = require('express-validator');

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      message: 'Validierungsfehler',
      errors: errors.array().map(err => ({
        field: err.param,
        message: err.msg
      }))
    });
  }
  next();
};

module.exports = validateRequest;
EOL

    log_info "Validierungs-Middleware wurde erstellt."
}

# Erstellt einfache Tests
create_tests() {
    log_info "Erstelle Tests..."
    
    # Beispiel-Test für den Auth-Controller
    mkdir -p backend/tests/controllers
    cat > backend/tests/controllers/authController.test.js << EOL
const request = require('supertest');
const app = require('../../src/app'); // Du müsstest die App zum Testen exportieren

describe('Auth Controller', () => {
  describe('POST /api/auth/register', () => {
    it('sollte einen neuen Benutzer registrieren', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123'
        });
      
      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('token');
      expect(res.body.user).toHaveProperty('id');
      expect(res.body.user.username).toEqual('testuser');
    });
  });

  // Weitere Tests hier...
});
EOL

    log_info "Tests wurden erstellt."
}

# Hauptprogramm
main() {
    log_info "Starte Erstellung der Backend-Anwendung..."
    create_package_json
    create_backend_structure
    create_env_config
    create_db_connection
    create_logger
    create_models
    create_middlewares
    create_validation_middleware
    create_controllers
    create_routes
    create_main_app
    create_tests
    log_info "Backend-Anwendung wurde erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main
