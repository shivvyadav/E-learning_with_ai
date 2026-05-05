const courseselect = require("../../../models/courserelated")


exports.getallselectedcourse =async(req,res)=>{
    const courses=await courseselect.find().populate('course').populate('user')
if(courses.length==0){
    return res.status(404).json({
        message:"No course selected",
        data:[]
    })
}
res.status(200).json({
    message:"selected course fetched successfully",
    data:courses
})
}

exports.getsingleselectedcourse = async(req,res)=>{
    const {id} = req.params 
     
    //check if course is selected or not
    const courses = await courseselect.findById(id)
    if(!courses){
      return res.status(404).json({
        message:"No course selected   with that id"
      })
    }
    res.status(200).json({
        message:" selected course fetched successfully",
        data:courses
    })
}

exports.updatePaymentStatus = async(req,res)=>{
    const {id} = req.params 
    const {paymentStatus} = req.body 

    if(!paymentStatus || !['pending','unpaid','paid'].includes(paymentStatus.toLowerCase())){
        return res.status(400).json({
            message : "paymentStatus is invalid or should be provided"
        })
    }
    const courses= await courseselect.findById(id)
    if(!courses){
        return res.status(404).json({
            message : "No course selected  with that id"
        })
    }
    const updatedcourse = await courseselect.findByIdAndUpdate(id,{
        'paymentdetails.status' : paymentStatus
    },{new:true}).populate('course').populate('user')

    res.status(200).json({
        message : "payment  status updated Successfully",
        data : updatedcourse
    })
}

exports.deleteselectedcourse = async(req,res)=>{
    const {id}= req.params
    const courses = await courseselect.findById(id)
    if(!courses){
      return res.status(400).json({
        message:"No course are selected  with that id"
      })
    }
    await courseselect.findByIdAndDelete(id)
    res.status(200).json({
        message:"courses deleted successfully",
        data :null
    })
}