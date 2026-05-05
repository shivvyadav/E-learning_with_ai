const {default: axios} = require("axios");
const courseselect = require("../../../models/courserelated");

exports.intitialkhaltipayment = async (req, res) => {
  const {courseselectId, amount} = req.body;
  if (!courseselectId || !amount) {
    return res.status(400).json({
      message: "please provide courseselectedid ,amount",
    });
  }
  let courses = await courseselect.findById(courseselectId);
  if (!courses) {
    return res.status(400).json({
      message: "selected course with that id not found",
    });
  }
  if (courses.totalamount !== amount) {
    return res.status(400).json({
      message: "Amount must be equal to toalamount",
    });
  }
  const data = {
    return_url: "http://localhost:3000/success",
    purchase_order_id: courseselectId,
    amount: amount * 100,
    website_url: "http://localhost:3000/",
    purchase_order_name: "coursename_" + courseselectId,
  };
  const response = await axios.post("https://dev.khalti.com/api/v2/epayment/initiate/", data, {
    headers: {
      Authorization: "key 503d66b404944ee787dd041aff687c5b",
    },
  });
  console.log("Khalti response:", response.data);
  console.log("pidx to save:", response.data.pidx);
  courses.paymentdetail.pidx = response.data.pidx;
  console.log(courses.paymentdetail.pidx);
  await courses.save();

  res.status(200).json({
    message: "payment initiated successfully",
    paymentUrl: response.data.payment_url,
  });
};

// ============================================
// FIXED: verifypdx - Always returns a response with proper status
// ============================================
exports.verifypdx = async (req, res) => {
  const pidx = req.body.pidx;
  const userId = req.user.id;

  console.log("🔍 Verifying payment for pidx:", pidx);

  // Validate input
  if (!pidx) {
    console.log("❌ No pidx provided");
    return res.status(400).json({
      success: false,
      status: "error",
      message: "Payment identifier (pidx) is required",
    });
  }

  try {
    // Call Khalti API to check payment status
    const response = await axios.post(
      "https://dev.khalti.com/api/v2/epayment/lookup/",
      {pidx},
      {
        headers: {
          Authorization: "key 503d66b404944ee787dd041aff687c5b",
        },
      },
    );

    console.log("Khalti lookup response:", response.data);

    const paymentStatus = response.data.status;

    // ============================================
    // Case 1: Payment is Completed
    // ============================================
    if (paymentStatus == "Completed") {
      console.log("✅ Payment completed for pidx:", pidx);

      let courses = await courseselect.find({"paymentdetail.pidx": pidx});

      if (courses && courses.length > 0) {
        courses[0].paymentdetail.method = "khalti";
        courses[0].paymentdetail.status = "paid";
        await courses[0].save();

        return res.status(200).json({
          success: true,
          status: "completed",
          message: "Payment verified successfully",
        });
      } else {
        return res.status(200).json({
          success: false,
          status: "not_found",
          message: "Course selection not found for this payment",
        });
      }
    }

    // ============================================
    // Case 2: Payment is Pending
    // ============================================
    else if (paymentStatus == "Pending") {
      console.log("⏳ Payment pending for pidx:", pidx);
      return res.status(200).json({
        success: false,
        status: "pending",
        message: "Payment is still pending. Please complete the payment.",
      });
    }

    // ============================================
    // Case 3: Payment Failed or Cancelled
    // ============================================
    else {
      console.log("❌ Payment failed/cancelled for pidx:", pidx, "Status:", paymentStatus);
      return res.status(200).json({
        success: false,
        status: "failed",
        message: `Payment ${paymentStatus}. Please try again.`,
      });
    }
  } catch (error) {
    console.error("Error verifying payment:", error.message);

    // ============================================
    // Check if error is from Khalti API (404 = not found)
    // ============================================
    if (error.response) {
      console.log("Khalti API error response:", error.response.data);

      if (error.response.status === 404) {
        return res.status(200).json({
          success: false,
          status: "not_found",
          message: "Payment record not found. The payment may have been cancelled.",
        });
      }

      // Other Khalti API errors
      return res.status(200).json({
        success: false,
        status: "error",
        message: `Khalti API error: ${error.response.data?.message || error.message}`,
      });
    }

    // ============================================
    // Network or other errors
    // ============================================
    return res.status(200).json({
      success: false,
      status: "error",
      message: "Payment verification failed: " + error.message,
    });
  }
};
