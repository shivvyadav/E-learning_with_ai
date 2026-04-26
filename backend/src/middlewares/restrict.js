const restrictto =(...roles)=>{
    //(...)also known as rest operator if usedd as parameter and if used in array like[...] spread operator.here it defines everything passed as a argument as array 
    //Take all passed arguments and combine them into an array called roles
     return (req,res,next)=>{
        const userrole = req.user.role
        if(!roles.includes(userrole)){
            res.status(403).json({
                message:"you dont have permission for this .... forbidden"
            })
        }else{
            next()
        }
     }
}
module.exports = restrictto