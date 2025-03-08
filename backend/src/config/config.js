require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.prod' : '.env.dev' });

module.exports = {
  development: {
    port: process.env.APP_PORT || 8100,
    jwtSecret: process.env.JWT_SECRET || 'dev_jwt_secret',
    jwtExpiry: process.env.JWT_EXPIRY || '24h',
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
    database: {
      host: process.env.DB_HOST || 'postgres',
      port: process.env.DB_PORT || 5432,
      name: process.env.DB_NAME || 'fwf_collector_prod',
      user: process.env.DB_USER || 'fwf_user',
      password: process.env.DB_PASSWORD || 'prod_password'
    }
  }
};
