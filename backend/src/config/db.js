// import dotenv from "dotenv";
// dotenv.config();

const mongoose = require("mongoose");
const adminseeder = require("../../adminseeder");

const mongoURI = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/elearning";

const connectDB = async () => {
  if (!mongoURI) {
    throw new Error("MONGO_URI is not defined in environment variables");
  }

  try {
    await mongoose.connect(mongoURI);
    console.log("Database connected successfully");
    adminseeder();
  } catch (error) {
    console.error("MONGODB CONNECTION FAILED:", error);
    process.exit(1);
  }
};

module.exports = connectDB;