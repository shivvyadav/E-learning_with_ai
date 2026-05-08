const isAuthenticated = require("../../middlewares/authMiddleware");
const restrictto = require("../../middlewares/restrict");
const {multer, storage} = require("../../middlewares/multerconfig");
const catchasync = require("../../services/catchasync");
const {
  getcourse,
  getcourses,
  getCourseLessons,
} = require("../../controllers/global/globalcontroller");
const {
  createcourse,
  deletecourse,
  editcourse,
} = require("../../controllers/admin/course/coursecontroller");
const upload = multer({storage: storage});

const router = require("express").Router();

router
  .route("/courses")
  .post(
    isAuthenticated,
    restrictto("admin"),
    upload.fields([
      {name: "coursethumbnail", maxCount: 1},
      {name: "videos", maxCount: 50},
      {name: "pdfs", maxCount: 50},
    ]),
    catchasync(createcourse),
  )
  .get(catchasync(getcourses));

router
  .route("/course/:id")
  .get(catchasync(getcourse))
  .delete(isAuthenticated, restrictto("admin"), catchasync(deletecourse))
  .patch(
    isAuthenticated,
    restrictto("admin"),
    upload.fields([
      {name: "coursethumbnail", maxCount: 1},
      {name: "videos", maxCount: 50},
      {name: "pdfs", maxCount: 50},
    ]),
    catchasync(editcourse),
  );

router.get("/course/:id/lessons", catchasync(getCourseLessons));

module.exports = router;
