const mongoose = require("mongoose")
const Schema = mongoose.Schema

const courseSchema = new Schema({
    Coursename:{
        type:String,
        required:[true,"Coursename must be provided"]
    },
    Coursedescription:{
        type:String,
        required:[true,"Coursedescription must be provided"]
    },
    CoursePrice:{
        type:Number,
        required:[true,"coursePrice must be provided"]
    },
    
    coursethumbnail:{
        type:String
    },
    modules:[
        {
        title: String,
        videos:[
            {
                _id: { type: Schema.Types.ObjectId, auto:true },
                title:String,
                videoUrl:String,
                duration:Number
            }
        ],
        pdfs:[
            {
                _id:{ type:Schema.Types.ObjectId, auto:true },
                title:String,
                pdfUrl:String
            }
        ]
        }
    ],
    category:String,
    // AI Recommendation attributes
    tags: [String], // e.g., ["web-development", "javascript", "frontend"]
    difficulty: {
        type: String,
        enum: ["beginner", "intermediate", "advanced"],
        default: "beginner"
    },
    careerOutcomes: [String], // e.g., ["full-stack-developer", "data-scientist"]
    videoFormat: {
        type: String,
        enum: ["recorded", "live", "mixed"],
        default: "recorded"
    },
    timeCommitment: {
        type: String,
        enum: ["short", "medium", "long"],
        default: "medium"
    },
    
},{
    timestamps:true
})

const course = mongoose.model("course",courseSchema)
module.exports = course