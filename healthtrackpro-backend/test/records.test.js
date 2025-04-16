const request = require('supertest');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const { app, server } = require('../server'); // Assuming server.js exports app and the running server instance
const Record = require('../models/Record');
const Patient = require('../models/Patient'); // Need Patient model for patientId

dotenv.config();

// Hold a reference to a test patient and record ID
let testPatientId;
let testRecordId;

describe('Record API Endpoints', () => {

  // Connect to DB before all tests
  beforeAll(async () => {
    const MONGODB_URI = process.env.MONGODB_URI;
    if (!MONGODB_URI) {
      throw new Error('MONGODB_URI missing in .env for testing');
    }
    try {
      await mongoose.connect(MONGODB_URI);
      // Create a dummy patient for testing records
      const testPatient = new Patient({ 
        name: 'Test Patient for Records', 
        age: 40, 
        gender: 'Other',
        contact: '0000000',
        timestamp: new Date().toISOString()
      });
      const savedPatient = await testPatient.save();
      testPatientId = savedPatient._id.toString();
    } catch (err) {
      console.error('DB Connection or test patient creation error:', err);
      // Throw error to stop tests if DB connection fails
      throw err;
    }
  });

  // Clean up and close connection after all tests
  afterAll(async () => {
    // Delete the test patient and any created records
    if (testPatientId) {
      await Record.deleteMany({ patientId: testPatientId });
      await Patient.findByIdAndDelete(testPatientId);
    }
    await mongoose.connection.close();
    // Close the server instance if it was exported from server.js
    // This depends on how server.js is structured.
    // If server.listen() returns the server instance and it's exported:
    if (server && server.close) { 
       await new Promise(resolve => server.close(resolve));
    } else {
      console.warn('Server instance not found or close method unavailable for teardown.');
    }
  });

  // Test POST /api/records
  it('should create a new record', async () => {
    const res = await request(app)
      .post('/api/records')
      .send({
        patientId: testPatientId, 
        type: 'Heart Rate',
        value: '85',
        timestamp: new Date().toISOString()
      });
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('id'); // Check for 'id' (virtual)
    expect(res.body.type).toEqual('Heart Rate');
    expect(res.body.value).toEqual('85');
    expect(res.body.patientId).toEqual(testPatientId);
    testRecordId = res.body.id; // Save the virtual 'id'
  });

  // Test GET /api/records/:patientId
  it('should fetch records for a specific patient', async () => {
    expect(testRecordId).toBeDefined(); 

    const res = await request(app)
      .get(`/api/records/${testPatientId}`);
      
    expect(res.statusCode).toEqual(200);
    expect(res.body).toBeInstanceOf(Array);
    expect(res.body.length).toBeGreaterThan(0);
    // Find record using the virtual 'id'
    const foundRecord = res.body.find(r => r.id === testRecordId);
    expect(foundRecord).toBeDefined();
    expect(foundRecord.type).toEqual('Heart Rate');
  });

  // Test PUT /api/records/:id
  it('should update an existing record', async () => {
    expect(testRecordId).toBeDefined();

    const res = await request(app)
      // Use the virtual 'id' in the URL
      .put(`/api/records/${testRecordId}`)
      .send({
        value: '90' // Update the value
      });
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('id', testRecordId); // Check virtual id remains same
    expect(res.body).toHaveProperty('value', '90');
  });

  // Add more tests: 
  // - Test GET /api/records/:patientId for non-existent patient (expect 404 or empty array)
  // - Test PUT /api/records/:id for non-existent record (expect 404)
  // - Test POST /api/records with invalid data (expect 400)
  // - Test GET /api/records (get all - if needed)
}); 