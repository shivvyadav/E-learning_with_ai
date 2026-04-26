const jwt = require("jsonwebtoken");
const { promisify } = require("util");
const User = require("../models/User");
require("dotenv").config();

const isAuthenticated = async (req, res, next) => {
  let token = req.headers.authorization;

  // Support both "Bearer <token>" and direct token values.
  if (typeof token === "string" && token.toLowerCase().startsWith("bearer ")) {
    token = token.slice(7).trim();
  }

  if (!token) {
    return res.status(403).json({
      message: "please login",
    });
  }

  try {
    const decoded = await promisify(jwt.verify)(
      token,
      process.env.SECRETKEY
    );

    const doesuserexist = await User.findOne({ _id: decoded.id });

    if (!doesuserexist) {
      return res.status(404).json({
        message: "User does not exist with that id/token",
      })
    }

    req.user = doesuserexist
    next()
  } catch (error) {
    res.status(400).json({
      message: error.message
    })
  }
}

module.exports = isAuthenticated