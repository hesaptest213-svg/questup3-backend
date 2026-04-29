// =====================================================
// Database Configuration (PostgreSQL baglantisi)
// =====================================================

import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

function shouldUseSsl() {
  const explicit = String(process.env.DATABASE_SSL || '').trim().toLowerCase();
  if (['true', '1', 'yes', 'on'].includes(explicit)) {
    return { rejectUnauthorized: false };
  }

  if (process.env.DATABASE_URL && process.env.NODE_ENV === 'production') {
    return { rejectUnauthorized: false };
  }

  return false;
}

function buildPoolConfig() {
  if (process.env.DATABASE_URL) {
    return {
      connectionString: process.env.DATABASE_URL,
      ssl: shouldUseSsl(),
    };
  }

  return {
    user: process.env.DATABASE_USER || 'postgres',
    password: process.env.DATABASE_PASSWORD || 'password',
    host: process.env.DATABASE_HOST || 'localhost',
    port: process.env.DATABASE_PORT || 5432,
    database: process.env.DATABASE_NAME || 'questup_db',
    ssl: shouldUseSsl(),
  };
}

export const pool = new Pool(buildPoolConfig());

export async function connectDB() {
  try {
    const client = await pool.connect();
    console.log('PostgreSQL baglantisi basarili!');
    const result = await client.query('SELECT NOW()');
    console.log('Server zamani:', result.rows[0].now);
    client.release();
  } catch (error) {
    console.error('Veritabani baglanti hatasi:', error.message);
    throw error;
  }
}

export async function query(sql, values) {
  try {
    const result = await pool.query(sql, values);
    return result;
  } catch (error) {
    console.error('SQL Hatasi:', error.message);
    console.error('SQL:', sql);
    console.error('Values:', values);
    throw error;
  }
}

export async function queryOne(sql, values) {
  const result = await query(sql, values);
  return result.rows[0];
}

export async function queryAll(sql, values) {
  const result = await query(sql, values);
  return result.rows;
}

export default pool;
