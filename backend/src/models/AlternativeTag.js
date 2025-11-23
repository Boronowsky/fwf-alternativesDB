const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const AlternativeTag = sequelize.define('AlternativeTag', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  }
}, {
  timestamps: true
});

module.exports = AlternativeTag;
