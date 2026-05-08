

const { getmyprofile, deletemyprofile, updatemyprofile, updatemypass } = require("../../controllers/user/profile/profilecontroller")
const isAuthenticated = require("../../middlewares/authMiddleware")
const catchasync = require("../../services/catchasync")
const router = require("express").Router()


router.route("/profile").get(isAuthenticated,catchasync(getmyprofile)).delete(isAuthenticated,catchasync(deletemyprofile))
.patch(isAuthenticated,catchasync(updatemyprofile))

router.route("/changepassword").patch(isAuthenticated,catchasync(updatemypass))

module.exports = router;