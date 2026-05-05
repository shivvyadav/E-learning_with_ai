const enroll = require("../../../models/enrollment");

exports.getAllEnrollments = async (req, res) => {
  const enrollments = await enroll.find().populate("user").populate("course");

  res.status(200).json({
    message: "enrollment fetched successfully",
    data: enrollments,
  });
};

exports.deleteEnrollment = async (req, res) => {
  const {id} = req.params;
  if (!id) return res.status(400).json({message: "please provide id"});

  const enrollment = await enroll.findById(id);
  if (!enrollment) return res.status(404).json({message: "enrollment not found"});

  await enroll.findByIdAndDelete(id);

  res.status(200).json({message: "enrollment deleted successfully"});
};
