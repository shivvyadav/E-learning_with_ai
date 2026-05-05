const course = require("../../../models/coursemodel");
const review = require("../../../models/review");

exports.createreview = async (req, res) => {
  const userId = req.user.id;
  const {rating, comment} = req.body;
  const courseId = req.params.id;
  if (!rating || !comment || !courseId) {
    return res.status(400).json({
      message: "please provide rating,message,courses",
    });
  }

  const courseexist = await course.findById(courseId);
  if (!courseexist) {
    return res.status(404).json({
      message: "course with that courseid doesnot exist",
    });
  }

  await review.create({
    userId,
    courseId,
    rating,
    comment,
  });
  res.status(200).json({
    message: "review added successfully",
  });
};

exports.getmyreviews = async (req, res) => {
  const userId = req.user.id;
  const reviews = await review.find({userId});
  if (reviews.length === 0) {
    res.status(404).json({
      message: "you haven't given review to any courses yet",
      reviews: [],
    });
  } else {
    res.status(200).json({
      message: "Review fetched successfully",
      data: reviews,
    });
  }
};

exports.deletereview = async (req, res) => {
  const reviewid = req.params.id;
  const userId = req.user.id;
  if (!reviewid) {
    res.status(400).json({
      message: "please provide reviewid",
    });
  }
  const reviews = await review.findById(reviewid);
  const ownerofreview = reviews.userId.toString();
  if (ownerofreview !== userId.toString()) {
    return res.status(400).json({
      message: "you dont have permission to delete this review",
    });
  }
  // Whenever you compare any MongoDB ID with anything — always .toString() both sides. No exceptions. ✅

  await review.findByIdAndDelete(reviewid);
  res.status(200).json({
    message: "review deleted successfully",
  });
};
