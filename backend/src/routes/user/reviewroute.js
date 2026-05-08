

const { getmyreviews, deletereview, createreview } = require("../../controllers/user/review/reviewcontroller")
const isAuthenticated = require("../../middlewares/authMiddleware")
const restrict = require("../../middlewares/restrict")
const catchasync = require("../../services/catchasync")
const router = require("express").Router()

router.route("/reviews").get(isAuthenticated,catchasync(getmyreviews))
router.route("/reviews/:id").delete(isAuthenticated,catchasync(deletereview)).post(isAuthenticated,restrict("customer"),catchasync(createreview))

module.exports = router