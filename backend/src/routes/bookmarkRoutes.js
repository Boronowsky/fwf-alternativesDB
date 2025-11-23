const express = require('express');
const { body } = require('express-validator');
const bookmarkController = require('../controllers/bookmarkController');
const { protect } = require('../middlewares/auth');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

// Alle Routen benötigen Authentifizierung
router.use(protect);

router.get('/', bookmarkController.getUserBookmarks);

router.post(
  '/',
  [
    body('alternativeId')
      .isUUID()
      .withMessage('Gültige Alternative-ID erforderlich')
  ],
  validateRequest,
  bookmarkController.addBookmark
);

router.delete('/:alternativeId', bookmarkController.removeBookmark);

router.get('/check/:alternativeId', bookmarkController.checkBookmark);

module.exports = router;
