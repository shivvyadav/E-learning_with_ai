const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const RecommendationSchema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: "User",
  },
  recommendedCourses: [
    {
      type: Schema.Types.ObjectId,
      ref: "Course",
    },
  ],
  generatedAt: {
    type: Date,
    default: Date.now,
  },
});

const airecommend = mongoose.model("airecommend", RecommendationSchema);
module.exports = airecommend;
