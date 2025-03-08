const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const { protect } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Benutzer registrieren
router.post(
  '/register',
  [
    body('username')
      .isLength({ min: 3, max: 20 })
      .withMessage('Benutzername muss zwischen 3 und 20 Zeichen lang sein')
      .trim(),
    body('email')
      .isEmail()
      .withMessage('Gültige E-Mail-Adresse erforderlich')
      .normalizeEmail(),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Passwort muss mindestens 8 Zeichen lang sein')
  ],
  validateRequest,
  authController.register
);

// Benutzer anmelden
router.post(
  '/login',
  [
    body('email')
      .isEmail()
      .withMessage('Gültige E-Mail-Adresse erforderlich')
      .normalizeEmail(),
    body('password')
      .not()
      .isEmpty()
      .withMessage('Passwort erforderlich')
  ],
  validateRequest,
  authController.login
);

// Benutzerprofil abrufen
router.get('/profile', protect, authController.getProfile);

// Benutzerprofil aktualisieren
router.put(
  '/profile',
  protect,
  [
    body('username')
      .optional()
      .isLength({ min: 3, max: 20 })
      .withMessage('Benutzername muss zwischen 3 und 20 Zeichen lang sein')
      .trim(),
    body('email')
      .optional()
      .isEmail()
      .withMessage('Gültige E-Mail-Adresse erforderlich')
      .normalizeEmail()
  ],
  validateRequest,
  authController.updateProfile
);

// Passwort ändern
router.put(
  '/password',
  protect,
  [
    body('oldPassword')
      .not()
      .isEmpty()
      .withMessage('Aktuelles Passwort erforderlich'),
    body('newPassword')
      .isLength({ min: 8 })
      .withMessage('Neues Passwort muss mindestens 8 Zeichen lang sein')
  ],
  validateRequest,
  authController.changePassword
);

module.exports = router;
