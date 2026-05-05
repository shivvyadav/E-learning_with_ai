const User = require("../../../models/User");
const bcrypt = require("bcryptjs");

exports.getmyprofile = async (req, res) => {
  try {
    const userId = req.user.id;
    const myprofile = await User.findById(userId);
    res.status(200).json({
      data: myprofile,
      message: "profile fetched successfully",
    });
  } catch (error) {
    res.status(500).json({message: error.message});
  }
};

exports.updatemyprofile = async (req, res) => {
  try {
    const {username, useremail, userphonenumber} = req.body;
    const userId = req.user.id;
    const updatedata = await User.findByIdAndUpdate(
      userId,
      {username, useremail, userphonenumber},
      {
        runValidators: true,
        new: true,
      },
    );
    res.status(200).json({
      message: "profile updated successfully",
      data: updatedata,
    });
  } catch (error) {
    res.status(500).json({message: error.message});
  }
};

exports.deletemyprofile = async (req, res) => {
  try {
    const userId = req.user.id;
    await User.findByIdAndDelete(userId);
    res.status(200).json({
      message: "profile deleted successfully",
      data: null,
    });
  } catch (error) {
    res.status(500).json({message: error.message});
  }
};

exports.updatemypass = async (req, res) => {
  console.log("🔐 Change password function called");

  try {
    const userId = req.user.id;
    const {oldpassword, newpassword, confirmpassword} = req.body;

    // Validate inputs
    if (!oldpassword || !newpassword || !confirmpassword) {
      return res.status(400).json({
        message: "Please provide oldpassword, newpassword, and confirmpassword",
      });
    }

    if (newpassword !== confirmpassword) {
      return res.status(400).json({
        message: "New password and confirm password do not match",
      });
    }

    if (newpassword.length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters long",
      });
    }

    // IMPORTANT: Use .select('+userpassword') to include the password field
    const user = await User.findById(userId).select("+userpassword");

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // Verify old password
    const isMatch = bcrypt.compareSync(oldpassword, user.userpassword);

    if (!isMatch) {
      return res.status(400).json({
        message: "Current password is incorrect",
      });
    }

    // Update password
    const hashedPassword = bcrypt.hashSync(newpassword, 10);
    user.userpassword = hashedPassword;
    await user.save();

    return res.status(200).json({
      message: "Password changed successfully",
    });
  } catch (error) {
    console.error("❌ Error in updatemypass:", error);
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};
