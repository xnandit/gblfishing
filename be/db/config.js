require('dotenv').config();
const config = {
  db: {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || "3306",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    connectTimeout: 70000
  },
  listPerPage: 30,
};
module.exports = config;
