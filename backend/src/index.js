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
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
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
      logger.info(`Server läuft im ${process.env.NODE_ENV || 'development'}-Modus auf Port ${PORT}`);
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
