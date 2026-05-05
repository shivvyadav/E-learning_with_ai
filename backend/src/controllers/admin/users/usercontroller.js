const User = require("../../../models/User");

exports.getusers = async (req, res) => {
  const userId = req.user.id;
  const users = await User.find({_id: {$ne: userId}});
  if (users.length > 0) {
    res.status(200).json({
      message: "users fetched successfully",
      data: users,
    });
  } else {
    res.status(404).json({
      message: "user collection is empty",
    });
  }
};

exports.deleteuser = async (req, res) => {
  const {id} = req.params;
  if (!id) {
    return res.status(400).json({
      message: "please provide id",
    });
  }
  //check if that id user exsits or not
  const Users = await User.findById(id);
  if (!Users) {
    res.status(404).json({
      message: "user not found with that id",
    });
  } else {
    await User.findByIdAndDelete(id);
    res.status(200).json({
      message: "User deleted successfully",
    });
  }
};
