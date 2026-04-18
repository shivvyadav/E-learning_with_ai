import React, {useState} from "react";
import {Link} from "react-router-dom";
import {useAuth} from "../context/AdminContext";

export default function TopCourses() {
  const {courses, enrollments, dataLoading} = useAuth();

  // Track which images have failed to load
  const [failedImages, setFailedImages] = useState({});

  // 1. Calculate popularity and sort
  const topCourses = courses
    .map((course) => {
      // Count how many enrollments exist for this specific course
      const studentCount = enrollments.filter(
        (emp) => (emp.course?._id || emp.course) === course._id,
      ).length;

      return {...course, studentCount};
    })
    // 2. Sort by studentCount descending (highest first)
    .sort((a, b) => b.studentCount - a.studentCount)
    // 3. Take the top 5
    .slice(0, 5);

  const handleImageError = (id) => {
    // If the image fails to load, mark its ID as failed
    setFailedImages((prev) => ({...prev, [id]: true}));
  };

  return (
    <div className='bg-neutral-50 rounded-xl p-6 shadow-sm w-full border border-neutral-300'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-lg font-semibold text-gray-800'>Top Courses</h2>

        <Link to='/courses' className='text-blue-500 text-sm font-medium hover:underline'>
          View All
        </Link>
      </div>

      <div className='space-y-6'>
        {dataLoading ? (
          // Skeleton Loader
          [...Array(5)].map((_, i) => (
            <div key={i} className='flex gap-4 items-start animate-pulse'>
              <div className='w-14 h-14 rounded-md bg-neutral-200 shrink-0' />
              <div className='flex-1 space-y-2'>
                <div className='h-4 bg-neutral-200 rounded w-3/4' />
                <div className='h-3 bg-neutral-200 rounded w-1/4' />
              </div>
            </div>
          ))
        ) : topCourses.length > 0 ? (
          topCourses.map((course) => (
            <div key={course._id} className='flex gap-4 items-start'>
              {/* Course Thumbnail or Placeholder on Error */}
              {failedImages[course._id] || !course.coursethumbnail ? (
                // Use a generic placeholder
                <img
                  src='https://via.placeholder.com/150/f4f4f5/52525b?text=Course'
                  alt='placeholder'
                  className='w-14 h-14 rounded-md object-cover border border-neutral-200 shrink-0 bg-neutral-100'
                />
              ) : (
                // Try loading the thumbnail
                <img
                  src={course.coursethumbnail}
                  alt={course.Coursename}
                  onError={() => handleImageError(course._id)} // <-- The Fix
                  className='w-14 h-14 rounded-md object-cover border border-neutral-200 shrink-0'
                />
              )}

              <div className='flex-1 min-w-0'>
                <p className='font-medium text-gray-800 leading-snug truncate'>
                  {course.Coursename}
                </p>

                <p className='text-sm text-gray-500 mt-1 flex items-center gap-3'>
                  <span className='font-medium text-blue-600'>{course.studentCount} Students</span>
                  <span className='text-neutral-300'>|</span>
                  <span className='font-semibold text-green-600'>
                    {course.CoursePrice === 0 ? "Free" : `Rs ${course.CoursePrice}`}
                  </span>
                </p>
              </div>
            </div>
          ))
        ) : (
          <p className='text-center py-4 text-neutral-500 text-sm italic'>No courses available</p>
        )}
      </div>
    </div>
  );
}
