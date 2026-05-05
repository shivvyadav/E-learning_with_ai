const course = require("../../../models/coursemodel")
const enroll = require("../../../models/enrollment")
const review = require("../../../models/review")
const User = require("../../../models/User")

exports.getdata = async (req, res) => {
  const userId = req.user.id; // ADD THIS — was missing!

  const [courses, users, enrollments, reviews] = await Promise.all([
    course.find(),
    User.find({ _id: { $ne: userId } }), // ✅ now userId is defined
    enroll.find().populate("user").populate("course"),
    review.find().populate("courseId"),
  ]);

  res.status(200).json({
    message: "data fetched successfully",
    data: {
      courses,
      users,
      enrollments,
      reviews,
    },
  });
};