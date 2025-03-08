const express = require('express');
const { body } = require('express-validator');
const adminController = require('../controllers/adminController');
const { protect, admin } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Alle Admin-Routen werden mit protect und admin Middleware geschützt
router.use(protect, admin);

// Dashboard-Statistiken
router.get('/dashboard', adminController.getDashboardStats);

// Benutzer verwalten
router.get('/users', adminController.getUsers);

router.put(
  '/users/:id',
  [
    body('isAdmin')
      .isBoolean()
      .withMessage('isAdmin muss ein Boolean-Wert sein')
  ],
  validateRequest,
  adminController.updateUserAdminStatus
);

// Alternativen genehmigen/ablehnen
router.put(
  '/alternatives/:id/approve',
  [
    body('approved')
      .isBoolean()
      .withMessage('approved muss ein Boolean-Wert sein')
  ],
  validateRequest,
  adminController.approveAlternative
);

module.exports = router;
