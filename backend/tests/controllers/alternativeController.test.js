const request = require('supertest');
const express = require('express');
const { Alternative, User, Tag, sequelize } = require('../../src/models');
const alternativeController = require('../../src/controllers/alternativeController');

const app = express();
app.use(express.json());

// Mock routes for testing
app.get('/alternatives', alternativeController.getAlternatives);
app.post('/alternatives', (req, res, next) => {
  req.user = { id: 'test-user-id', isAdmin: false };
  next();
}, alternativeController.createAlternative);

describe('Alternative Controller', () => {
  let testUser;

  beforeAll(async () => {
    await sequelize.sync({ force: true });

    testUser = await User.create({
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      isAdmin: false
    });
  });

  afterAll(async () => {
    await sequelize.close();
  });

  describe('GET /alternatives', () => {
    beforeEach(async () => {
      await Alternative.destroy({ where: {} });
    });

    it('sollte leeres Array zurückgeben wenn keine Alternativen vorhanden', async () => {
      const res = await request(app).get('/alternatives');

      expect(res.status).toBe(200);
      expect(res.body.alternatives).toEqual([]);
      expect(res.body.total).toBe(0);
    });

    it('sollte nur genehmigte Alternativen für nicht-Admin Benutzer zurückgeben', async () => {
      await Alternative.create({
        title: 'Approved Alternative',
        replaces: 'BigTech Product',
        description: 'Test description',
        reasons: 'Test reasons',
        benefits: 'Test benefits',
        category: 'Software',
        approved: true,
        submitterId: testUser.id
      });

      await Alternative.create({
        title: 'Pending Alternative',
        replaces: 'BigTech Product 2',
        description: 'Test description 2',
        reasons: 'Test reasons 2',
        benefits: 'Test benefits 2',
        category: 'Software',
        approved: false,
        submitterId: testUser.id
      });

      const res = await request(app).get('/alternatives');

      expect(res.status).toBe(200);
      expect(res.body.alternatives.length).toBe(1);
      expect(res.body.alternatives[0].title).toBe('Approved Alternative');
    });

    it('sollte Pagination korrekt handhaben', async () => {
      // Create 15 alternatives
      const alternatives = [];
      for (let i = 0; i < 15; i++) {
        alternatives.push({
          title: `Alternative ${i}`,
          replaces: `Product ${i}`,
          description: 'Test description',
          reasons: 'Test reasons',
          benefits: 'Test benefits',
          category: 'Software',
          approved: true,
          submitterId: testUser.id
        });
      }
      await Alternative.bulkCreate(alternatives);

      const res = await request(app).get('/alternatives?page=1&limit=10');

      expect(res.status).toBe(200);
      expect(res.body.alternatives.length).toBe(10);
      expect(res.body.page).toBe(1);
      expect(res.body.pages).toBe(2);
      expect(res.body.total).toBe(15);
    });

    it('sollte nach Kategorie filtern', async () => {
      await Alternative.create({
        title: 'Software Alternative',
        replaces: 'Product 1',
        description: 'Test',
        reasons: 'Test',
        benefits: 'Test',
        category: 'Software',
        approved: true,
        submitterId: testUser.id
      });

      await Alternative.create({
        title: 'Hardware Alternative',
        replaces: 'Product 2',
        description: 'Test',
        reasons: 'Test',
        benefits: 'Test',
        category: 'Hardware',
        approved: true,
        submitterId: testUser.id
      });

      const res = await request(app).get('/alternatives?category=Software');

      expect(res.status).toBe(200);
      expect(res.body.alternatives.length).toBe(1);
      expect(res.body.alternatives[0].category).toBe('Software');
    });

    it('sollte Suche durchführen', async () => {
      await Alternative.create({
        title: 'Signal Messenger',
        replaces: 'WhatsApp',
        description: 'Encrypted messaging',
        reasons: 'Privacy',
        benefits: 'End-to-end encryption',
        category: 'Messaging',
        approved: true,
        submitterId: testUser.id
      });

      const res = await request(app).get('/alternatives?search=Signal');

      expect(res.status).toBe(200);
      expect(res.body.alternatives.length).toBe(1);
      expect(res.body.alternatives[0].title).toBe('Signal Messenger');
    });
  });

  describe('POST /alternatives', () => {
    it('sollte neue Alternative erstellen', async () => {
      const newAlternative = {
        title: 'Test Alternative',
        replaces: 'Test Product',
        description: 'This is a test description',
        reasons: 'Test reasons',
        benefits: 'Test benefits',
        category: 'Software'
      };

      const res = await request(app)
        .post('/alternatives')
        .send(newAlternative);

      expect(res.status).toBe(201);
      expect(res.body.title).toBe(newAlternative.title);
      expect(res.body.approved).toBe(false); // Not admin, so not auto-approved
    });

    it('sollte Duplikate verhindern', async () => {
      const alternative = {
        title: 'Duplicate Test',
        replaces: 'Product X',
        description: 'Test',
        reasons: 'Test',
        benefits: 'Test',
        category: 'Software'
      };

      await request(app).post('/alternatives').send(alternative);
      const res = await request(app).post('/alternatives').send(alternative);

      expect(res.status).toBe(400);
      expect(res.body.message).toContain('existiert bereits');
    });
  });
});
