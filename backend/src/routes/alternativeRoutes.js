const express = require('express');
const { body, query } = require('express-validator');
const alternativeController = require('../controllers/alternativeController');
const { protect } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Öffentliche Routen
router.get('/', alternativeController.getAlternatives);
router.get('/latest', alternativeController.getLatestAlternatives);
router.get('/check', alternativeController.checkIfAlternativeExists);
router.get('/:id', alternativeController.getAlternativeById);
router.get('/:id/comments', alternativeController.getComments);

// Geschützte Routen
router.post(
  '/',
  protect,
  [
    body('title')
      .isLength({ min: 3, max: 100 })
      .withMessage('Titel muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('replaces')
      .isLength({ min: 3, max: 100 })
      .withMessage('Zu ersetzendes Produkt muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('description')
      .isLength({ min: 10 })
      .withMessage('Beschreibung muss mindestens 10 Zeichen lang sein')
      .trim(),
    body('reasons')
      .isLength({ min: 10 })
      .withMessage('Gründe müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('benefits')
      .isLength({ min: 10 })
      .withMessage('Vorteile müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('category')
      .not()
      .isEmpty()
      .withMessage('Kategorie erforderlich')
      .trim()
  ],
  validateRequest,
  alternativeController.createAlternative
);

router.put(
  '/:id',
  protect,
  [
    body('title')
      .optional()
      .isLength({ min: 3, max: 100 })
      .withMessage('Titel muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('replaces')
      .optional()
      .isLength({ min: 3, max: 100 })
      .withMessage('Zu ersetzendes Produkt muss zwischen 3 und 100 Zeichen lang sein')
      .trim(),
    body('description')
      .optional()
      .isLength({ min: 10 })
      .withMessage('Beschreibung muss mindestens 10 Zeichen lang sein')
      .trim(),
    body('reasons')
      .optional()
      .isLength({ min: 10 })
      .withMessage('Gründe müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('benefits')
      .optional()
      .isLength({ min: 10 })
      .withMessage('Vorteile müssen mindestens 10 Zeichen lang sein')
      .trim(),
    body('category')
      .optional()
      .not()
      .isEmpty()
      .withMessage('Kategorie erforderlich')
      .trim()
  ],
  validateRequest,
  alternativeController.updateAlternative
);

router.delete('/:id', protect, alternativeController.deleteAlternative);

router.post(
  '/:id/vote',
  protect,
  [
    body('type')
      .isIn(['upvote', 'downvote'])
      .withMessage('Abstimmungstyp muss "upvote" oder "downvote" sein')
  ],
  validateRequest,
  alternativeController.voteAlternative
);

router.post(
  '/:id/comments',
  protect,
  [
    body('content')
      .isLength({ min: 3 })
      .withMessage('Kommentar muss mindestens 3 Zeichen lang sein')
      .trim()
  ],
  validateRequest,
  alternativeController.addComment
);

module.exports = router;
