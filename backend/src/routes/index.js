const express = require('express');
const authRoutes = require('./authRoutes');
const alternativeRoutes = require('./alternativeRoutes');
const adminRoutes = require('./adminRoutes');
const tagRoutes = require('./tagRoutes');
const bookmarkRoutes = require('./bookmarkRoutes');

const router = express.Router();

// API-Routen
router.use('/auth', authRoutes);
router.use('/alternatives', alternativeRoutes);
router.use('/admin', adminRoutes);
router.use('/tags', tagRoutes);
router.use('/bookmarks', bookmarkRoutes);

module.exports = router;
