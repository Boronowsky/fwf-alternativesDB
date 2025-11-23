const { sequelize } = require('../src/config/database');

beforeAll(async () => {
  // Setup test database
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  // Close database connection
  await sequelize.close();
});
