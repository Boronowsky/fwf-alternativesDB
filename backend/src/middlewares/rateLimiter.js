const rateLimit = require('express-rate-limit');
const config = require('../config/config')[process.env.NODE_ENV === 'production' ? 'production' : 'development'];

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: config.rateLimitWindowMs,
  max: config.rateLimitMax,
  message: 'Zu viele Anfragen von dieser IP, bitte versuchen Sie es später erneut.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Stricter rate limiter for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 login attempts per 15 minutes
  message: 'Zu viele Login-Versuche, bitte versuchen Sie es später erneut.',
  skipSuccessfulRequests: true,
});

module.exports = {
  apiLimiter,
  authLimiter
};
