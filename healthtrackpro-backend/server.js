const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

// 🔐 Load environment variables
dotenv.config();

const app = express();

// 🌍 Middleware
app.use(cors());
app.use(express.json());

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

// 🛑 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: '❌ Route not found' });
});

// 🚀 Start Server
app.listen(PORT, () => {
  console.log(`🌐 Server running at http://localhost:${PORT}`);
});
