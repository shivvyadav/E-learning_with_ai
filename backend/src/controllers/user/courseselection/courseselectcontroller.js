const courseselect = require("../../../models/courserelated")
const enroll = require("../../../models/enrollment")




exports.createcourseselection= async(req,res)=>{
    const  userId = req.user.id 
    const{course,totalamount,phonenumber,paymentdetail} = req.body 
    if(!course ||!totalamount ||!phonenumber ||!paymentdetail){
        return res.status(400).json({
            message:"please provide course, totalamount,phonenumber,paymentdetails"
        })
    }
        const createcourseselection = await  courseselect.create({
        user:userId,
        course,
        totalamount,
        paymentdetail,
        phonenumber
        
    })
    res.status(200).json({
        message:"course selection successfull",
        data:createcourseselection
    })
}

exports.getmyselectedcourse = async(req,res)=>{
    const userId = req.user.id 
    const courseselection = await courseselect.find({user:userId}).populate("course")
    if(courseselection.length ==0){
        return res.status(404).json({
            message:"no course selected",
            data:[]
        })
    }
    res.status(200).json({
        message:"selected course fetched successfully",
        data:courseselection
    })
}

exports.updatemycourseselection =async(req,res)=>{
    const userId = req.user.id 
    const {id} = req.params 
    const {course,courseselectid} = req.body
    if(!course ){
        return res.status(400).json({
            message:"please provide the course"
        })
    }
    const existingcourseselection = await enroll.findById(id)
    if(existingcourseselection.user.toString() !==userId.toString()){
        res.status(403).json({
            message:"you dont have permission to update this selected course"
        })
    }
    if(!existingcourseselection){
        return res.status(404).json({
            message:"no course selected with that id"
        })
    }
    if(existingcourseselection.status ==="Active"){
        return res.status(400).json({
            message:"you cannot update course selection it is already paid "
        })
    }
    const updateselectedcourse = await courseselect.findByIdAndUpdate(courseselectid,{course},{new:true})
        res.status(200).json({
          message:"course selection updated successfully",
          data:updateselectedcourse
        })  
}

exports.deletemycourseselection = async(req,res)=>{
    const userId = req.user.id 
    const {id} = req.params

    const courseselection = await enroll.findById(id)
    if(!courseselection){
      return res.status(400).json({
        message:"No course selected with that id"
      })
    }
    if(courseselection.user != userId){
        return res.status(400).json({
            message:"you dont have permission to delete this selected course"
        })
    }
    if(courseselection.status !=="completed"){
        return res.status(400).json({
            message:'you cannot this order as it is not pending'
        })
    }
    await courseselection.findByIDAndDelete(id)
    res.status(200).json({
        message:"selected course deleted successfully",
        data:null
    })

}

