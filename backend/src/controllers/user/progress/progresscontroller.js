const course = require("../../../models/coursemodel");
const enroll = require("../../../models/enrollment");
const progress = require("../../../models/progress");

exports.updatevideopdf = async (req, res) => {
  const userId = req.user.id;
  const {courseId, videoId, pdfId} = req.body;

  const enrolled = await enroll.findOne({
    user: userId,
    course: courseId,
  });

  if (!enrolled) {
    return res.status(403).json({
      message: "Not Enrolled",
    });
  }
  const userprogress = await progress.findOne({
    user: userId,
    course: courseId,
  });
  if (!userprogress) {
    return res.status(404).json({
      message: "Progress not found",
    });
  }
  if (videoId && !userprogress.completedvideos.some((id) => id.toString() === videoId)) {
    userprogress.completedvideos.push(videoId);
  }
  if (pdfId && !userprogress.completedpdfs.some((id) => id.toString() === pdfId)) {
    userprogress.completedpdfs.push(pdfId);
  }

  userprogress.lastAccessed = new Date();
  await userprogress.save();

  const courses = await course.findById(courseId);

  const totalvideos = courses.modules.reduce((sum, module) => {
    return sum + module.videos.length;
  }, 0);

  const totalpdfs = courses.modules.reduce((sum, module) => {
    return sum + module.pdfs.length;
  }, 0);

  const totalItems = totalvideos + totalpdfs;
  const completeditems = userprogress.completedvideos.length + userprogress.completedpdfs.length;

  const percentage = (completeditems / totalItems) * 100;
  enrolled.progress = percentage;
  if (percentage >= 100) {
    enrolled.status = "completed";
  }
  await enrolled.save();

  res.status(200).json({
    message: "video and pdf progress updated",
    data: percentage,
  });
};

exports.getuserprogress = async (req, res) => {
  const userId = req.user.id;
  const {courseId} = req.params;

  const progresses = await progress
    .findOne({
      user: userId,
      course: courseId,
    })
    .populate("course");

  res.status(200).json({
    message: "progress fetched successfully",
    data: progresses,
  });
};
