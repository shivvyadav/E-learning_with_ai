const { updatevideopdf, getuserprogress } = require("../../controllers/user/progress/progresscontroller");
const isAuthenticated = require("../../middlewares/authMiddleware");

const catchasync = require("../../services/catchasync");

const router = require("express").Router()

router.route("/updateprogress").patch(isAuthenticated,catchasync(updatevideopdf))

router.route("/updateprogress/:courseId").get(isAuthenticated,catchasync(getuserprogress))


module.exports = router;