const mongoose = require('mongoose');

const recordSchema = new mongoose.Schema(
  {
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Patient', // 🔗 Reference to Patient model
      required: [true, 'Patient ID is required'],
    },
    type: {
      type: String,
      required: [true, 'Record type is required'],
      enum: {
        values: [
          'Blood Pressure',
          'Respiratory Rate',
          'Blood Oxygen Level',
          'Heartbeat Rate',
          'Heart Rate',
        ],
        message: '{VALUE} is not a valid record type',
      },
    },
    value: {
      type: String,
      required: [true, 'Value is required'],
      trim: true,
      validate: {
        validator: function (v) {
          const numericRegex = /^\d+(\.\d+)?$/;
          const bloodPressureRegex = /^\d+\/\d+$/;
          return this.type === 'Blood Pressure'
            ? bloodPressureRegex.test(v)
            : numericRegex.test(v);
        },
        message: props =>
          `${props.value} is not a valid value for ${props.instance?.type || 'record'}`,
      },
    },
    notes: {
      type: String,
      trim: true,
      default: '',
    },
    timestamp: {
      type: Date,
      default: () => new Date(), // ✅ Ensures valid Date object
    },
  },
  {
    timestamps: true, // ✅ Adds createdAt & updatedAt
  }
);

// ✅ Format output for frontend (hide _id/__v and rename to id)
recordSchema.set('toJSON', {
  virtuals: true,
  transform: (_, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Record', recordSchema);
