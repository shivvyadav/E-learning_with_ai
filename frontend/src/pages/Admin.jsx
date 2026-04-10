import React from "react";
import {Users, UserCheck, BookOpen, Star} from "lucide-react";
import {useAuth} from "../context/AdminContext";

import NewUsers from "../components/NewUsers";
import LatestReviews from "../components/LatestReviews";
import LatestPurchases from "../components/LatestPurchases";
import TopCourses from "../components/TopCourses";

export default function Admin() {
  const {users, enrollments, courses, reviews, dataLoading} = useAuth();

  //  Safe counts — fallback to 0 if array is undefined/null
  const userCount       = users?.length       ?? 0;
  const enrollmentCount = enrollments?.length  ?? 0;
  const courseCount     = courses?.length      ?? 0;
  // const reviewCount     = reviews?.length      ?? 0;

  const stats = [
    {
      title: "Total Users",
      value: userCount.toLocaleString(),
      icon: <Users size={20} className='text-white' />,
      bg: "bg-orange-500",
    },
    {
      title: "Total Enrolled Users",
      value: enrollmentCount.toLocaleString(),
      icon: <UserCheck size={20} className='text-white' />,
      bg: "bg-blue-500",
    },
    {
      title: "Total Courses",
      value: courseCount.toLocaleString(),
      icon: <BookOpen size={20} className='text-white' />,
      bg: "bg-purple-500",
    },
    // {
    //   title: "Total Reviews",
    //   value: reviewCount.toLocaleString(),
    //   icon: <Star size={20} className='text-white' />,
    //   bg: "bg-teal-500",
    // },
  ];

  return (
    <div className='p-4 md:p-6 space-y-6'>
      <div className='grid gap-6 sm:grid-cols-2 lg:grid-cols-4'>
        {stats.map((item, index) => (
          <div
            key={index}
            className='flex items-center gap-4 bg-neutral-50 border border-neutral-300 rounded-xl p-6 shadow-sm'>
            <div
              className={`w-12 h-12 shrink-0 flex items-center justify-center rounded-full ${item.bg}`}>
              {item.icon}
            </div>
            <div className='min-w-0'>
              <p className='text-sm text-gray-500 truncate'>{item.title}</p>
              {dataLoading ? (
                <div className='h-6 w-12 bg-neutral-200 animate-pulse rounded mt-1'></div>
              ) : (
                <p className='text-xl font-semibold text-gray-800'>{item.value}</p>
              )}
            </div>
          </div>
        ))}
      </div>

      <div className='grid gap-6 lg:grid-cols-2'>
        <NewUsers />
        {/* <LatestReviews /> */}
        <LatestPurchases />
      </div>

      <div className='grid gap-6 lg:grid-cols-2'>
        
        <TopCourses />
      </div>
    </div>
  );
}