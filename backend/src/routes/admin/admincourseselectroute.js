
const { getallselectedcourse, updatePaymentStatus, getsingleselectedcourse, deleteselectedcourse } = require("../../controllers/admin/courserelated/courseselectcontroller")
const isauthenticated = require("../../middlewares/authMiddleware")
const restrictto = require("../../middlewares/restrict")
const catchasync = require("../../services/catchasync")

const router = require("express").Router()
 router.route("/admincourseselect").get(isauthenticated,restrictto("admin"),catchasync(getallselectedcourse))
 router.route("/courseselect/paymentstatus/:id").patch(isauthenticated,restrictto("admin"),catchasync(updatePaymentStatus))
 router.route("/admincourseselect/:id").get(isauthenticated,restrictto("admin"),catchasync(getsingleselectedcourse))
 .delete(isauthenticated,restrictto("admin"),catchasync(deleteselectedcourse))



module.exports=router