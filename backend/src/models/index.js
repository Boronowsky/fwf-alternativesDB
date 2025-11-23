const User = require('./User');
const Alternative = require('./Alternative');
const Comment = require('./Comment');
const Vote = require('./Vote');
const Tag = require('./Tag');
const AlternativeTag = require('./AlternativeTag');
const Bookmark = require('./Bookmark');

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

// Many-to-Many Beziehung zwischen Alternative und Tag
Alternative.belongsToMany(Tag, { through: AlternativeTag });
Tag.belongsToMany(Alternative, { through: AlternativeTag });

// Bookmarks
Bookmark.belongsTo(User);
Bookmark.belongsTo(Alternative);
User.hasMany(Bookmark);
Alternative.hasMany(Bookmark);

module.exports = {
  User,
  Alternative,
  Comment,
  Vote,
  Tag,
  AlternativeTag,
  Bookmark,
  sequelize: require('../config/database').sequelize
};
