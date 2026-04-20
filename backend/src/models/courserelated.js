const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const paymentSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
    },
    course: {
      type: Schema.Types.ObjectId,
      ref: "course",
    },
    totalamount: {type: Number, required: true},
    phonenumber: {type: Number, required: true},

    paymentdetail: {
      pidx: {type: String},
      method: {type: String, default: "khalti"},
      status: {type: String, eum: ["paid", "unpaid", "pending"], default: "pending"},
    },
  },
  {
    timestamps: true,
  },
);

const courseselect = mongoose.model("courseselect", paymentSchema);
module.exports = courseselect;
