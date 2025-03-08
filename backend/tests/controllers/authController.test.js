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
