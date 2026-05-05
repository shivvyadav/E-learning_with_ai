
const bcrypt = require ("bcryptjs")
const jwt= require("jsonwebtoken")
const fs = require("fs")
const User = require("../../models/User")
const sendemail = require("../../services/sendemail")
require("dotenv").config()

const makeFileUrl = (value) => {
  if (!value) return "";
  const trimmed = value.toString().trim();

  if (/^https?:\/\//i.test(trimmed)) {
    // Fix broken double URL cases like "http://localhost:3000/https://..."
    const badPrefix = "http://localhost:3000/https://";
    const badPrefixHttps = "https://localhost:3000/https://";
    if (trimmed.startsWith(badPrefix)) return trimmed.replace(badPrefix, "https://");
    if (trimmed.startsWith(badPrefixHttps)) return trimmed.replace(badPrefixHttps, "https://");

    // Correct local URLs that miss /uploads/.
    const localMatch = trimmed.match(/^https?:\/\/localhost:3000\/(.*)$/i);
    if (localMatch) {
      const rest = localMatch[1];
      if (rest.startsWith("uploads/")) return trimmed;
      return `http://localhost:3000/uploads/${rest.replace(/^\//, "")}`;
    }

    return trimmed;
  }

  const base = process.env.localhost_url?.replace(/\/+$/, "") ?? "";
  const filename = trimmed.replace(/^\//, "");
  return `${base}/uploads/${filename}`;
};

exports.registeruser = async(req,res)=>{
  let file= req.file 
  let filepath;
  if(!file){
    filepath = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1dQPM88-Vq0f-YM8xILMQdKktXgKBMN6XH9cCBleA&s"
  } else {
    filepath = file.filename
  }
  const{email,password,phonenumber,username}=req.body
  if(!email||!password||!phonenumber||!username){
    return res.status(400).json({
      message:"please provide email,password,phonenumber and username"
    })
  }
  //check if that email aready exist or not
  const foundEmail = await User.find({useremail:email})
  if(foundEmail.length>0){
    return res.status(404).json({
      message:"User with that email already exists"
    })
  }
  const user = await User.create({
    username:username,
    userphonenumber:phonenumber,
    useremail:email,
    userpassword:bcrypt.hashSync(password,10),
    profileimage: makeFileUrl(filepath)

  })
  res.status(201).json({
    message:"User registered successfully",
    data:user
  })

  
}

exports.loginuser= async(req,res)=>{
  const {email,password}= req.body
  if(!email||!password){
    return res.status(400).json({
      message:"Please enter email ,password"
    })
  }
  const foundemail= await User.find({useremail:email}).select("+userpassword")
  if(foundemail.length===0){
    return res.status(404).json({
      message:"User with this email is not registered"
    })
  }
  const ismatched = bcrypt.compareSync(password,foundemail[0].userpassword)
  if(ismatched){
    const token = jwt.sign({id:foundemail[0]._id},process.env.SECRETKEY,{
      expiresIn:"30d"
    })

    // Normalize profile images for clients
    const users = foundemail.map((u) => {
      const obj = u.toObject ? u.toObject() : { ...u };
      obj.profileimage = makeFileUrl(obj.profileimage);
      return obj;
    });

    res.status(200).json({
      message:"User logged in successfully",
      data: users,
      token:token
    })
  }

}

exports.updateProfile = async (req, res) => {
  const { username } = req.body;
  if (!username || typeof username !== 'string') {
    return res.status(400).json({ message: 'Username is required' });
  }

  const user = req.user;
  user.username = username;
  await user.save();

  const obj = user.toObject ? user.toObject() : { ...user };
  obj.profileimage = makeFileUrl(obj.profileimage);

  res.status(200).json({
    message: 'Profile updated',
    data: obj,
  });
};

exports.forgotpassword = async(req,res)=>{
  const {email} =req.body;
  if(!email){
    return res.status(400).json({
      message:"please provide email"
    })
  }
  const foundemail = await User.find({useremail:email})
  if(foundemail.length ===0){
    return res.status(404).json({
      message:"user with email is not registered"
    })
  }

 const otp = Math.floor(1000+ Math.random()*9000);
 foundemail[0].otp =otp;
 await foundemail[0].save()

 await sendemail({
  email:email,
  subject:"YOUR OTP FOR E-LEARNING FORGOTPASSWORD",
  message:`your otp is ${otp}. Do not share with anyone `
 })
 res.status(200).json({
  message:"Otp sent successfully",
  data:email
 })
}

exports.verifyotp= async(req,res)=>{
  const{email,otp}= req.body;
  if(!email||!otp){
    return res.status(400).json({
      message:"please provide email or otp"
    })
  }
  //check if that otp is correct or not fot that email
  const userexist = await User.find({useremail:email}).select("+otp +isotpverified")
  if(userexist.length===0){
    return res.status(404).json({
      message:"Email is not registered"
    })
  }
  if(userexist[0].otp !==otp*1){
   // since the opt send from the frontend is in the form of string so converting 
   //it into the number form we are multiplying it with 1
   res.status(400).json({
    message:"invalid otp"
   })
  }else{
    userexist[0].otp = undefined
    userexist[0].isotpverified =true
    await userexist[0].save()
    res.status(200).json({
      message:"otp is correct"
    })
  }
    
}

exports.resetpassword =async(req,res)=>{
  const{email,newpassword,confirmpassword} = req.body
  if(!email||!newpassword||!confirmpassword){
    return res.status(400).json({
      message:"please provide email,newpassword,confirmpassword"
    })
  }
  if(newpassword!==confirmpassword){
    return res.status(400).json({
      message:"newpassword and confirmassword doesnot match"
    })
  }
  const userexist = await User.find({useremail:email}).select("+isotpverified")
  if(userexist.length ==0){
    return res.status(404).json({
      message:"user email not registered"
    })
  }
  if(userexist[0].isotpverified !==true){
    return res.status(400).json({
      message:"you cannot perform this action"
    })
  }
  userexist[0].userpassword = bcrypt.hashSync(newpassword,10)
  userexist[0].isotpverified =false
  await userexist[0].save()

  res.status(200).json({
    message:"password changed successfuly"
  })
}