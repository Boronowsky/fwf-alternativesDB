const express = require('express');
const { body } = require('express-validator');
const tagController = require('../controllers/tagController');
const { protect, admin } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Öffentliche Routen
router.get('/', tagController.getAllTags);

// Admin-Routen
router.post(
  '/',
  protect,
  admin,
  [
    body('name')
      .isLength({ min: 2, max: 30 })
      .withMessage('Tag-Name muss zwischen 2 und 30 Zeichen lang sein')
      .trim(),
    body('color')
      .optional()
      .matches(/^#[0-9A-F]{6}$/i)
      .withMessage('Farbe muss ein gültiger Hex-Code sein (z.B. #3B82F6)')
  ],
  validateRequest,
  tagController.createTag
);

router.put(
  '/:id',
  protect,
  admin,
  [
    body('name')
      .optional()
      .isLength({ min: 2, max: 30 })
      .withMessage('Tag-Name muss zwischen 2 und 30 Zeichen lang sein')
      .trim(),
    body('color')
      .optional()
      .matches(/^#[0-9A-F]{6}$/i)
      .withMessage('Farbe muss ein gültiger Hex-Code sein')
  ],
  validateRequest,
  tagController.updateTag
);

router.delete('/:id', protect, admin, tagController.deleteTag);

// Tags zu Alternative hinzufügen
router.post(
  '/alternatives/:id/tags',
  protect,
  [
    body('tagIds')
      .isArray()
      .withMessage('tagIds muss ein Array sein')
  ],
  validateRequest,
  tagController.addTagsToAlternative
);

module.exports = router;
