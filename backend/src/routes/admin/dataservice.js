const {getdata} = require("../../controllers/admin/misc/dataservice");
const isAuthenticated = require("../../middlewares/authMiddleware");
const restrictto = require("../../middlewares/restrict");
const catchasync = require("../../services/catchasync");

const router = require("express").Router();

router.route("/misc/datas").get(isAuthenticated, restrictto("admin"), catchasync(getdata));

module.exports = router;
