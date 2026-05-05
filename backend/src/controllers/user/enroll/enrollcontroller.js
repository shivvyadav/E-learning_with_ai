const enroll = require("../../../models/enrollment");
const progress = require("../../../models/progress");

exports.checkifenroll = async (req, res) => {
  const userId = req.user.id;
  const courseId = req.body.id;

  const alreadyexist = await enroll.findOne({
    user: userId,
    course: courseId,
  });

  if (alreadyexist) {
    return res.status(400).json({
      message: "Already enrolled",
    });
  }
  //create enrollment
  const enrollment = await enroll.create({
    user: userId,
    course: courseId,
  });
  await progress.create({
    user: userId,
    course: courseId,
    completedvideos: [],
    completedpdfs: [],
    lastAccessed: new Date(),
  });

  res.status(200).json({
    message: "Enrolled successfully",
    data: enrollment,
  });
};

exports.getMyEnrollments = async (req, res) => {
  const userId = req.user.id;

  const enrollments = await enroll.find({user: userId}).populate("course");

  res.status(200).json({
    message: "Enrollments fetched successfully",
    data: enrollments,
  });
};
