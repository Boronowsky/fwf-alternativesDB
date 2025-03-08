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
