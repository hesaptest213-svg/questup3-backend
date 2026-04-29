// =====================================================
// QuestUp backend server
// =====================================================
// Boots in demo mode by default so the frontend can run without a
// prepared database. Set DEMO_MODE=false to require Postgres.

import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import dotenv from 'dotenv';
import os from 'os';
import path from 'path';
import { fileURLToPath } from 'url';
import rateLimit from 'express-rate-limit';
import { connectDB, pool } from './src/config/database.js';
import { setupRoutes } from './src/routes/index.js';
import { setupSocketIO } from './src/utils/socket.js';
import { errorHandler } from './src/middleware/errorHandler.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const demoMode = process.env.DEMO_MODE !== 'false';
const HOST = process.env.HOST || '0.0.0.0';
const PORT = Number(process.env.PORT || 5000);
const APP_URL = String(process.env.APP_URL || '').trim();

function resolveCorsOrigins() {
  const raw = [process.env.FRONTEND_URL, process.env.CORS_ORIGIN]
    .filter(Boolean)
    .join(',');
  const origins = raw
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

  if (!origins.length || demoMode) {
    return true;
  }

  return origins;
}

function isCapacitorLikeOrigin(origin = '') {
  const safeOrigin = String(origin || '').trim().toLowerCase();
  return safeOrigin.startsWith('capacitor://')
    || safeOrigin.startsWith('ionic://')
    || safeOrigin === 'http://localhost'
    || safeOrigin === 'https://localhost';
}

function createCorsOriginHandler(originSetting) {
  if (originSetting === true) {
    return true;
  }

  const allowedOrigins = Array.isArray(originSetting) ? originSetting : [];
  return (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin) || isCapacitorLikeOrigin(origin)) {
      callback(null, true);
      return;
    }

    callback(new Error('CORS origin reddedildi'));
  };
}

function getPreferredIpv4Address() {
  const networkInterfaces = os.networkInterfaces();
  for (const addresses of Object.values(networkInterfaces)) {
    for (const address of addresses || []) {
      if (address.family === 'IPv4' && !address.internal && !address.address.startsWith('169.254.')) {
        return address.address;
      }
    }
  }
  return '127.0.0.1';
}

const app = express();
const httpServer = createServer(app);
const corsOrigin = resolveCorsOrigins();
const corsOriginHandler = createCorsOriginHandler(corsOrigin);
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: corsOriginHandler,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  },
});

app.use(cors({
  origin: corsOriginHandler,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));
app.options('*', cors({ origin: corsOriginHandler, credentials: true }));
app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ limit: '20mb', extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

function isAuthRouteExemptFromApiLimit(req) {
  const originalUrl = String(req.originalUrl || req.url || '').split('?')[0];
  return [
    '/api/v1/auth/login',
    '/api/v1/auth/admin-login',
    '/api/v1/auth/register',
    '/api/v1/auth/forgot-password',
    '/api/v1/auth/reset-password',
    '/api/v1/auth/verify-reset-code',
  ].includes(originalUrl);
}

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1200,
  skip: isAuthRouteExemptFromApiLimit,
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Cok fazla istek gonderdiniz.',
    });
  },
});
app.use('/api/', apiLimiter);

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Cok fazla basarisiz giris denemesi.',
    });
  },
});

try {
  await connectDB();
  console.log('Veritabani baglandi');
} catch (error) {
  if (demoMode) {
    console.warn('Demo mode aktif, veritabani atlandi:', error.message);
  } else {
    throw error;
  }
}

const healthPayload = {
  success: true,
  message: 'API calisiyor',
  mode: demoMode ? 'DEMO_MODE' : 'DATABASE_MODE',
  timestamp: new Date().toISOString(),
  data: {
    mode: demoMode ? 'DEMO_MODE' : 'DATABASE_MODE',
    version: process.env.API_VERSION || 'v1',
  },
};

app.get('/health', (req, res) => {
  res.json({
    ...healthPayload,
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/v1/health', (req, res) => {
  res.json({
    ...healthPayload,
    timestamp: new Date().toISOString(),
  });
});

setupRoutes(app, loginLimiter);
setupSocketIO(io);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint bulunamadi',
    data: {
      path: req.path,
      method: req.method,
    },
  });
});

app.use(errorHandler);

httpServer.listen(PORT, HOST, () => {
  const ipv4Address = getPreferredIpv4Address();
  console.log('QuestUp backend running');
  console.log(`Mode:    ${demoMode ? 'DEMO_MODE' : 'DATABASE_MODE'}`);
  console.log('API Health:');
  console.log(`Local:   http://localhost:${PORT}/api/v1/health`);
  console.log(`Network: http://${ipv4Address}:${PORT}/api/v1/health`);
  console.log(`Bind:    http://${HOST}:${PORT}`);
  if (APP_URL) {
    console.log(`App URL: ${APP_URL}`);
  }
});

process.on('SIGTERM', async () => {
  httpServer.close(async () => {
    try {
      await pool.end();
    } catch (error) {
      console.warn('Pool kapatma atlandi:', error.message);
    }
    process.exit(0);
  });
});

export { app, httpServer, io };
