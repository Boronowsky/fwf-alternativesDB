require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.prod' : '.env.dev' });

module.exports = {
  development: {
    port: process.env.APP_PORT || 8100,
    jwtSecret: process.env.JWT_SECRET || 'dev_jwt_secret',
    jwtExpiry: process.env.JWT_EXPIRY || '24h',
    corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    rateLimitWindowMs: 15 * 60 * 1000, // 15 minutes
    rateLimitMax: 100, // limit each IP to 100 requests per windowMs
    database: {
      host: process.env.DB_HOST || 'postgres',
      port: process.env.DB_PORT || 5432,
      name: process.env.DB_NAME || 'fwf_collector_dev',
      user: process.env.DB_USER || 'fwf_user',
      password: process.env.DB_PASSWORD || 'dev_password'
    }
  },
  production: {
    port: process.env.APP_PORT || 8000,
    jwtSecret: process.env.JWT_SECRET || 'prod_jwt_secret',
    jwtExpiry: process.env.JWT_EXPIRY || '24h',
    corsOrigin: process.env.CORS_ORIGIN || 'http://freeworldfirst.com:8181',
    rateLimitWindowMs: 15 * 60 * 1000, // 15 minutes
    rateLimitMax: 50, // stricter in production
    database: {
      host: process.env.DB_HOST || 'postgres',
      port: process.env.DB_PORT || 5432,
      name: process.env.DB_NAME || 'fwf_collector_prod',
      user: process.env.DB_USER || 'fwf_user',
      password: process.env.DB_PASSWORD || 'prod_password'
    }
  }
};
