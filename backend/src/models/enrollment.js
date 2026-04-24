const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const enrollmentSchema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: "User",
  },
  course: {
    type: Schema.Types.ObjectId,
    ref: "course",
  },
  enrolleddate: {
    type: Date,
    default: Date.now,
  },
  status: {
    type: String,
    enum: ["active", "completed"],
    default: "active",
  },
  progress: {
    type: Number,
    default: 0,
  },
});

const enroll = mongoose.model("enroll", enrollmentSchema);
module.exports = enroll;
