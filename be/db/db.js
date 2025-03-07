const mysql = require('mysql2/promise');
const config = require('./config'); // Adjust path if necessary

// Create a connection pool using settings from config.js
const pool = mysql.createPool(config.db);

/**
 * Execute a SQL query with provided parameters
 * @param {string} sql - The SQL query to execute
 * @param {array} params - Parameters for the SQL query
 * @returns {Promise} - Resolves with query result
 */
async function query(sql, params) {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (error) {
    console.error('Database query error:', error.message);
    throw error;
  }
}

/**
 * Close the pool connection gracefully
 * Use this function if you need to shut down the database connection, e.g., during testing or app shutdown.
 */
async function closePool() {
  await pool.end();
}

module.exports = {
  query,
  closePool,
  pool
};