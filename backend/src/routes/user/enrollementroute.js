const {checkifenroll, getMyEnrollments} = require("../../controllers/user/enroll/enrollcontroller");
const isAuthenticated = require("../../middlewares/authMiddleware");
const restrictto = require("../../middlewares/restrict");
const catchasync = require("../../services/catchasync");

const router = require("express").Router();

router.route("/enroll").post(isAuthenticated, restrictto("customer"), catchasync(checkifenroll));

router.route("/my-enrollments").get(isAuthenticated, catchasync(getMyEnrollments));

module.exports = router;
