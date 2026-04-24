const mongoose =require('mongoose')
const Schema= mongoose.Schema

const userSchema = new Schema(
  {
    useremail:{
        type:String,
        required :[true,'Email Must be provided'],
        unique:true,
        lowercase:true
    },
    userphonenumber:{
        type:Number,
        required:[true,"phonenumber must be provided"]
    },
    username:{
      type:String,
      required:[true,"username must be provided"]
    },
    userpassword:{
      type:String,
      required:[true],
      select:false //this will not be shown  in the frontend 
    },
    profileimage:{
      type:String
    },
    role:{
        type:String,
        enum:["customer","admin"],
        default:"customer"
    },
    otp:{
      type:Number
    },
    isotpverified:{
      type:Boolean,
      default:false
    },
    
  },
  {
    timestamps: true,
  },
);

const User = mongoose.model("User", userSchema)
module.exports = User;
