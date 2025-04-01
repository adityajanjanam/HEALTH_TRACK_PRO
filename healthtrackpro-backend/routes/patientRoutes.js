const express = require('express');
const bcrypt = require('bcrypt');
const router = express.Router();
const Patient = require('../models/Patient');

// 🔹 GET all patients
router.get('/', async (req, res) => {
  try {
    const patients = await Patient.find();
    res.status(200).json(patients);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🔹 GET a patient by ID
router.get('/:id', async (req, res) => {
  try {
    const patient = await Patient.findById(req.params.id);
    if (!patient) return res.status(404).json({ error: 'Patient not found' });
    res.status(200).json(patient);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🔹 CREATE a new patient
router.post('/', async (req, res) => {
  try {
    if (!req.body.name || !req.body.contact) {
      return res.status(400).json({ error: 'Name and contact are required' });
    }

    const newPatient = new Patient(req.body);
    await newPatient.save();
    res.status(201).json({ message: 'Patient added successfully', patient: newPatient });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ UPDATED: 🔹 UPDATE patient (REST-style)
router.put('/:id', async (req, res) => {
  try {
    const updatedPatient = await Patient.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!updatedPatient) return res.status(404).json({ error: 'Patient not found' });
    res.status(200).json({ message: 'Patient updated', patient: updatedPatient });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ UPDATED: 🔹 DELETE patient (REST-style)
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Patient.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ error: 'Patient not found' });
    res.status(200).json({ message: 'Patient deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🔐 REGISTER a patient
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Name, email, and password are required.' });
    }

    const existing = await Patient.findOne({ email });
    if (existing) {
      return res.status(400).json({ error: 'Email already registered.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newPatient = new Patient({ email, password: hashedPassword, name });
    await newPatient.save();

    res.status(201).json({ message: 'Registration successful', patient: newPatient });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🔐 LOGIN
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const patient = await Patient.findOne({ email });
    if (!patient) return res.status(401).json({ error: 'Invalid credentials.' });

    const match = await bcrypt.compare(password, patient.password);
    if (!match) return res.status(401).json({ error: 'Invalid credentials.' });

    res.status(200).json({ message: 'Login successful', patient });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 🔐 FORGOT Password (Mock)
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    const patient = await Patient.findOne({ email });

    if (!patient) return res.status(404).json({ error: 'Email not found.' });

    // Ideally generate token and send via email
    res.status(200).json({ message: 'Password reset link sent (mock)' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
