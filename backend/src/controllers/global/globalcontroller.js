const mongoose = require("mongoose");
const course = require("../../models/coursemodel");
const review = require("../../models/review");

const makeFileUrl = (value) => {
  if (!value) return "";
  const trimmed = value.toString().trim();

  // If the value already points to a remote URL, return it.
  if (/^https?:\/\//i.test(trimmed)) {
    // Fix malformed URLs like "http://localhost:3000/https://..."
    const badPrefix = "http://localhost:3000/https://";
    const badPrefixHttps = "https://localhost:3000/https://";
    if (trimmed.startsWith(badPrefix)) return trimmed.replace(badPrefix, "https://");
    if (trimmed.startsWith(badPrefixHttps)) return trimmed.replace(badPrefixHttps, "https://");

    // If it's local but missing /uploads, inject it.
    const localMatch = trimmed.match(/^https?:\/\/localhost:3000\/(.*)$/i);
    if (localMatch) {
      const rest = localMatch[1];
      if (rest.startsWith("uploads/")) return trimmed;
      return `http://localhost:3000/uploads/${rest.replace(/^\//, "")}`;
    }

    return trimmed;
  }

  // Relative path (filename) - serve from /uploads
  // Default to localhost base so clients can resolve URLs without needing an env var.
  const base = (process.env.localhost_url || "http://localhost:8000").replace(/\/+$/, "");
  const filename = trimmed.replace(/^\//, "");

  // If the stored value already includes the uploads folder, avoid doubling it.
  if (filename.toLowerCase().startsWith("uploads/")) {
    return `${base}/${filename}`;
  }

  return `${base}/uploads/${filename}`;
};

const normalizeCourseAssets = (courseObj) => {
  if (!courseObj) return courseObj;

  const normalized = { ...courseObj._doc };
  normalized.coursethumbnail = makeFileUrl(normalized.coursethumbnail);

  if (Array.isArray(normalized.modules)) {
    normalized.modules = normalized.modules.map((mod) => {
      const mapped = { ...mod };
      if (Array.isArray(mapped.videos)) {
        mapped.videos = mapped.videos.map((v) => ({
          ...v,
          videoUrl: makeFileUrl(v.videoUrl),
        }));
      }
      if (Array.isArray(mapped.pdfs)) {
        mapped.pdfs = mapped.pdfs.map((p) => ({
          ...p,
          pdfUrl: makeFileUrl(p.pdfUrl),
        }));
      }
      return mapped;
    });
  }

  return normalized;
};

exports.getcourses = async(req,res)=>{
    const courses = await course.find()
    if(courses.length ==0){
        res.status(400).json({
            message:"No  course found",
            courses:[]
        })
    }else{
        const normalized = courses.map(normalizeCourseAssets);
        res.status(200).json({
            message:"course fetched successfully",
            data:normalized
        })
    }
}


const isValidObjectId = (id) => mongoose.Types.ObjectId.isValid(id);

exports.getcourse = async (req, res) => {
  const { id } = req.params;
  if (!id || !isValidObjectId(id)) {
    return res.status(400).json({
      message: "Invalid course id",
    });
  }

  const courses = await course.find({ _id: id });
  const reviews = await review.find({ courseid: id }).populate("userid");
  if (courses.length == 0) {
    res.status(400).json({
      message: "No course found with that id",
      courses: [],
      reviews: [],
    });
  } else {
    const normalized = courses.map(normalizeCourseAssets);
    res.status(200).json({
      message: "courses fetched successfully",
      data: {
        courses: normalized,
        reviews,
      },
    });
  }
};

exports.getCourseLessons = async (req, res) => {
  const { id } = req.params;
  if (!id || !isValidObjectId(id)) {
    return res.status(400).json({
      message: "Invalid course id",
    });
  }

  const courseDoc = await course.findById(id);
  if (!courseDoc) {
    return res.status(404).json({ message: "Course not found" });
  }

  const lessons = [];
  let order = 0;

  (courseDoc.modules || []).forEach((mod) => {
    (mod.videos || []).forEach((video) => {
      lessons.push({
        _id: video._id,
        lessonTitle: video.title,
        videoUrl: makeFileUrl(video.videoUrl),
        order: order++,
      });
    });
  });

  res.status(200).json({ message: "ok", data: lessons });
};