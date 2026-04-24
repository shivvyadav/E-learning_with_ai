//this is a higher order function which takes another function as a argument
//and here first it does simillar to try catch first if error donot occur it works
//properly and if error occur then it catch them in catch((err))

module.exports =(fn)=>{
    return(req,res,next)=>{
        fn(req,res,next).catch((err)=>{
            return res.status(500).json({
                message:err.message,
                fullerror:err
            })
        })
    }
}