const { registeruser, loginuser, updateProfile, forgotpassword, verifyotp, resetpassword } = require("../../controllers/auth/authController")

const catchasync= require("../../services/catchasync")
const {multer,storage} = require("../../middlewares/multerconfig")
const upload = multer({storage:storage})
const isAuthenticated = require("../../middlewares/authMiddleware")


const router = require("express").Router()


router.route("/register").post(upload.single("profileimage"),catchasync( registeruser))
router.route("/login").post(catchasync(loginuser))
router.route("/profile").put(isAuthenticated, catchasync(updateProfile))
router.route("/forgotpassword").post(catchasync(forgotpassword))
router.route("/verifyotp").post(catchasync(verifyotp))
router.route("/resetpassword").post(catchasync(resetpassword))

module.exports = router