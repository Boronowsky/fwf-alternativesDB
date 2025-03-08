const express = require('express');
const authRoutes = require('./authRoutes');
const alternativeRoutes = require('./alternativeRoutes');
const adminRoutes = require('./adminRoutes');

const router = express.Router();

// API-Routen
router.use('/auth', authRoutes);
router.use('/alternatives', alternativeRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
