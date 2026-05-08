const { createcourseselection, getmyselectedcourse, updatemycourseselection, deletemycourseselection } = require("../../controllers/user/courseselection/courseselectcontroller")
const isAuthenticated = require("../../middlewares/authMiddleware")
const catchasync = require("../../services/catchasync")

const router = require("express").Router()

router.route("/courseSelect")
.post(isAuthenticated,catchasync(createcourseselection))
.get(isAuthenticated,catchasync(getmyselectedcourse))

router.route("/courseSelect/:id")
.patch(isAuthenticated,catchasync(updatemycourseselection))
.delete(isAuthenticated,catchasync(deletemycourseselection))

module.exports = router