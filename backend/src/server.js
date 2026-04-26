const dns = require("dns");
dns.setDefaultResultOrder("ipv4first");
dns.setServers(["8.8.8.8", "8.8.4.4"]);
const express = require("express");
const cors = require("cors");
const cookieParser = require("cookie-parser");
require("dotenv").config();

const connectDB = require("./config/db.js");

const app = express();

app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  }),
);

const path = require("path");

app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

app.use(express.static(path.join(__dirname, "../uploads")));

app.get("/admin", (req, res) => {
  res.sendFile(path.join(__dirname, "../admin.html"));
});

app.use(express.json());
app.use(express.urlencoded({extended: true}));

app.use(cookieParser());

app.get("/", (req, res) => {
  return res.json({message: "Welcome to the E-learning API!"});
});

function getLocalIp() {
  const {networkInterfaces} = require("os");
  const nets = networkInterfaces();

  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === "IPv4" && !net.internal) {
        return net.address;
      }
    }
  }
  return "localhost";
}

const authroutes = require("./routes/auth/authroutes");
const courseaddRoute = require("./routes/admin/courseroute");
const courseselectadminRoute = require("./routes/admin/admincourseselectroute");
const dataserviceRoute = require("./routes/admin/dataservice");
const enrollmentadminRoute = require("./routes/admin/enrollmentadminroute");
const adminuserRoute = require("./routes/admin/adminuserroute.js");
const courseselectRoute = require("./routes/user/courseselectroute");
const paymentroute = require("./routes/user/paymentroute");
const profileroute = require("./routes/user/profileroute");
const reviewroute = require("./routes/user/reviewroute");
const enrollementroute = require("./routes/user/enrollementroute");
const progressroute = require("./routes/user/progrssroute.js");

app.use("/api/auth", authroutes);
app.use("/api", courseaddRoute);
app.use("/api", courseselectadminRoute);
app.use("/api", dataserviceRoute);
app.use("/api", adminuserRoute);
app.use("/api", enrollmentadminRoute);
app.use("/api", courseselectRoute);
app.use("/api", paymentroute);
app.use("/api", profileroute);
app.use("/api", reviewroute);
app.use("/api", enrollementroute);
app.use("/api", progressroute);

const port = process.env.PORT || 3000;

connectDB().then(() => {
  console.log("Database connected, starting server...");
  app.listen(port, "0.0.0.0", () => {
    const localIp = getLocalIp();
    console.log("\nSERVER STARTED SUCCESSFULLY!");
    console.log("=".repeat(50));
    console.log(`   Local access:   http://localhost:${port}`);
    console.log(`   Network access: http://${localIp}:${port}`);
    console.log(`   Uploads folder: /uploads`);
    console.log("=".repeat(50));
    console.log("\nFor mobile device testing:");
    console.log(`   Use this URL on your phone: http://${localIp}:${port}`);
    console.log("\nMake sure:");
    console.log("   1. Phone and computer are on the same WiFi");
    console.log("   2. Windows Firewall allows port 8000");
    console.log("   3. Network profile is set to 'Private'\n");
  });
});
