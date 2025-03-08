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
