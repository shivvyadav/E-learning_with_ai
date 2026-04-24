const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const ProgressSchema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: "User",
  },
  course: {
    type: Schema.Types.ObjectId,
    ref: "course",
  },
  completedvideos: [
    {
      _id: {type: Schema.Types.ObjectId, auto: true},
      title: String,
      videoUrl: String,
      duration: Number,
    },
  ],
  completedpdfs: [
    {
      _id: {type: Schema.Types.ObjectId, auto: true},
      title: String,
      pdfUrl: String,
    },
  ],
  lastAccessed: Date,
});

const progress = mongoose.model("progress", ProgressSchema);
module.exports = progress;
