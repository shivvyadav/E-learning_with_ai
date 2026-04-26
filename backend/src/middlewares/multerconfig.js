const multer = require("multer");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // check the mimetypes of file
    const allowfiletypes = [
      "image/png",
      "image/jpg",
      "image/jpeg",
      "application/pdf",
      "video/mp4",
    ];

    if (!allowfiletypes.includes(file.mimetype)) {
      return cb(new Error("This file type is not supported"));
    }

    cb(null, "./uploads");
  },

  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

module.exports = { multer, storage };