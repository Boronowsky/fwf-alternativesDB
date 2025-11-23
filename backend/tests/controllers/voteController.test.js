const { Alternative, User, Vote, sequelize } = require('../../src/models');
const alternativeController = require('../../src/controllers/alternativeController');

describe('Vote System', () => {
  let testUser;
  let testAlternative;

  beforeAll(async () => {
    await sequelize.sync({ force: true });

    testUser = await User.create({
      username: 'voter',
      email: 'voter@example.com',
      password: 'password123'
    });

    testAlternative = await Alternative.create({
      title: 'Vote Test Alternative',
      replaces: 'Product',
      description: 'Test',
      reasons: 'Test',
      benefits: 'Test',
      category: 'Software',
      approved: true,
      submitterId: testUser.id
    });
  });

  afterAll(async () => {
    await sequelize.close();
  });

  beforeEach(async () => {
    await Vote.destroy({ where: {} });
    await testAlternative.update({ upvotes: 0 });
  });

  it('sollte Upvote hinzufügen', async () => {
    const req = {
      params: { id: testAlternative.id },
      body: { type: 'upvote' },
      user: testUser
    };
    const res = {
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };

    await alternativeController.voteAlternative(req, res);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'Abstimmung erfolgreich aktualisiert.',
        upvotes: 1
      })
    );

    const votes = await Vote.count({ where: { AlternativeId: testAlternative.id } });
    expect(votes).toBe(1);
  });

  it('sollte Vote entfernen bei erneutem gleichen Vote', async () => {
    // First vote
    await Vote.create({
      type: 'upvote',
      UserId: testUser.id,
      AlternativeId: testAlternative.id
    });
    await testAlternative.update({ upvotes: 1 });

    const req = {
      params: { id: testAlternative.id },
      body: { type: 'upvote' },
      user: testUser
    };
    const res = {
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };

    await alternativeController.voteAlternative(req, res);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        upvotes: 0
      })
    );

    const votes = await Vote.count({ where: { AlternativeId: testAlternative.id } });
    expect(votes).toBe(0);
  });

  it('sollte Vote-Typ ändern', async () => {
    // First upvote
    await Vote.create({
      type: 'upvote',
      UserId: testUser.id,
      AlternativeId: testAlternative.id
    });
    await testAlternative.update({ upvotes: 1 });

    const req = {
      params: { id: testAlternative.id },
      body: { type: 'downvote' },
      user: testUser
    };
    const res = {
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };

    await alternativeController.voteAlternative(req, res);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        upvotes: -1 // Changed from +1 to -1 (difference of 2)
      })
    );

    const vote = await Vote.findOne({ where: { AlternativeId: testAlternative.id } });
    expect(vote.type).toBe('downvote');
  });

  it('sollte ungültige Vote-Typen ablehnen', async () => {
    const req = {
      params: { id: testAlternative.id },
      body: { type: 'invalid' },
      user: testUser
    };
    const res = {
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };

    await alternativeController.voteAlternative(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'Ungültiger Abstimmungstyp.'
      })
    );
  });
});
