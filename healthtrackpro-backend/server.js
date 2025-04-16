const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');
const rateLimit = require('express-rate-limit');

// 🔐 Load environment variables
dotenv.config();

const app = express();

// 🛡️ Security Middleware
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: '❌ Too many requests from this IP, please try again later.',
});

// Apply rate limiting to all routes
app.use(limiter);

// 🌍 CORS Configuration
const corsOptions = {
  origin: process.env.NODE_ENV === 'production'
    ? ['https://healthtrackpro.com', 'https://app.healthtrackpro.com']
    : ['http://localhost:3000', 'http://localhost:5000', 'http://localhost:8080', 'http://localhost:50743'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-App-Version'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  credentials: true,
  maxAge: 600, // 10 minutes
};

app.use(cors(corsOptions));

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging in development
if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    console.log(`📝 ${req.method} ${req.url}`);
    next();
  });
}

// 🔧 Constants
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('❌ MONGODB_URI is missing in .env file');
  process.exit(1);
}

// 🛡 MongoDB connection options
let connectionOptions = {
  useNewUrlParser: true,
  useUnifiedTopology: true,
};

if (MONGODB_URI.includes('authMechanism=MONGODB-X509')) {
  const certPath = path.resolve(__dirname, 'cert.pem');
  if (!fs.existsSync(certPath)) {
    console.error('❌ SSL Certificate not found at:', certPath);
    process.exit(1);
  }

  connectionOptions = {
    ssl: true,
    sslKey: fs.readFileSync(certPath),
    sslCert: fs.readFileSync(certPath),
    useNewUrlParser: true,
    useUnifiedTopology: true,
  };
}

// ✅ MongoDB Connection
mongoose
  .connect(MONGODB_URI, connectionOptions)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch((err) => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });

// 🚀 Root API Test
app.get('/', (req, res) => {
  res.send('🚀 Welcome to HealthTrackPro API');
});

// 📦 Route Loader
const routeMappings = [
  { path: '/api/patients', file: './routes/patientRoutes' },
  { path: '/api/records', file: './routes/recordRoutes' },
  { path: '/api/users', file: './routes/userRoutes' },
];

routeMappings.forEach(({ path, file }) => {
  try {
    const route = require(file);
    app.use(path, route);
    console.log(`✅ Route mounted: ${path}`);
  } catch (err) {
    console.error(`❌ Failed to mount ${path} from ${file}:`, err.message);
  }
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌ Error:', err.stack);
  res.status(500).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message
  });
});

// 🛑 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: '❌ Route not found' });
});

let server; // Define server variable outside

// Only start listening if the file is run directly
if (require.main === module) {
  server = app.listen(PORT, () => { 
    console.log(`🌐 Server running in ${process.env.NODE_ENV || 'development'} mode at http://localhost:${PORT}`);
  });
} else {
  console.log('Server starting skipped as required by module (e.g., test)');
}

// Export app and server (server might be undefined if not run directly)
module.exports = { app, server };
