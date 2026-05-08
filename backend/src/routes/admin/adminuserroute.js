const {getusers, deleteuser} = require("../../controllers/admin/users/usercontroller");
const isAuthenticated = require("../../middlewares/authMiddleware");
const restrictto = require("../../middlewares/restrict");
const catchasync = require("../../services/catchasync");

const router = require("express").Router();
router.route("/users").get(isAuthenticated, restrictto("admin"), catchasync(getusers));

router.route("/users/:id").delete(isAuthenticated, restrictto("admin"), catchasync(deleteuser));

module.exports = router;
