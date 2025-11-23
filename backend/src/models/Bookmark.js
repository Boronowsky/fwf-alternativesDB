const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Bookmark = sequelize.define('Bookmark', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  }
}, {
  timestamps: true,
  indexes: [
    {
      unique: true,
      fields: ['UserId', 'AlternativeId']
    }
  ]
});

module.exports = Bookmark;
