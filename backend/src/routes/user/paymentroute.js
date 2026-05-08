const {
  intitialkhaltipayment,
  verifypdx,
} = require("../../controllers/user/payment/paymentcontroller");
const isAuthenticated = require("../../middlewares/authMiddleware");
const catchasync = require("../../services/catchasync");

const router = require("express").Router();

router.route("/payment").post(isAuthenticated, catchasync(intitialkhaltipayment));
router.route("/verify").post(isAuthenticated, catchasync(verifypdx));

module.exports = router;
