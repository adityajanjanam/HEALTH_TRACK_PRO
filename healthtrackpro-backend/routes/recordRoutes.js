const express = require('express');
const router = express.Router();
const Record = require('../models/Record');

// @route   POST /api/records
// @desc    Add a new clinical record for a patient
router.post('/', async (req, res) => {
  try {
    const { patientId, type, value, timestamp } = req.body;

    if (!patientId || !type || !value) {
      return res.status(400).json({
        error: 'Fields patientId, type, and value are required.',
      });
    }

    const newRecord = new Record({
      patientId,
      type,
      value,
      timestamp: timestamp || new Date(), // ✅ fallback to now
    });

    const savedRecord = await newRecord.save();
    return res.status(201).json(savedRecord);
  } catch (err) {
    console.error('❌ Failed to add record:', err.message);
    return res.status(400).json({ error: err.message });
  }
});

// @route   GET /api/records
// @desc    Get all records (with patient info)
router.get('/', async (req, res) => {
  try {
    const records = await Record.find()
      .populate('patientId') // ✅ includes full patient details
      .sort({ timestamp: -1 });

    return res.status(200).json(records);
  } catch (err) {
    console.error('❌ Error fetching all records:', err.message);
    return res.status(500).json({ error: err.message });
  }
});

// @route   GET /api/records/:patientId
// @desc    Get records for a specific patient (with patient info)
router.get('/:patientId', async (req, res) => {
  try {
    const { patientId } = req.params;
    const records = await Record.find({ patientId })
      .populate('patientId') // ✅ includes full patient details
      .sort({ timestamp: -1 });

    if (!records.length) {
      return res.status(404).json({ message: 'No records found for this patient.' });
    }

    return res.status(200).json(records);
  } catch (err) {
    console.error('❌ Error fetching records by patient ID:', err.message);
    return res.status(500).json({ error: err.message });
  }
});

// @route   POST /api/records/sync
// @desc    Sync multiple offline records (bulk insert)
router.post('/sync', async (req, res) => {
  try {
    const { records } = req.body;

    if (!Array.isArray(records) || records.length === 0) {
      return res.status(400).json({ error: 'No records provided for sync.' });
    }

    const validRecords = records
      .filter((r) => r.patientId && r.type && r.value)
      .map((r) => ({
        ...r,
        timestamp: r.timestamp || new Date(), // ✅ fallback to now
      }));

    if (validRecords.length === 0) {
      return res.status(400).json({ error: 'Invalid record data provided.' });
    }

    const savedRecords = await Record.insertMany(validRecords);
    return res.status(200).json({
      message: `${savedRecords.length} records synced successfully.`,
      data: savedRecords,
    });
  } catch (err) {
    console.error('❌ Sync error:', err.message);
    return res.status(500).json({ error: err.message });
  }
});

module.exports = router;
