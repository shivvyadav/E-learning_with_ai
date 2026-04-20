import React from "react";
import {Link} from "react-router-dom";
import {useAuth} from "../context/AdminContext";

export default function LatestPurchases() {
  const {enrollments, dataLoading} = useAuth();

  const latestPurchases = enrollments.slice(-5).reverse();

  return (
    <div className='bg-neutral-50 rounded-xl p-6 shadow-sm w-full border border-neutral-300'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-lg font-semibold text-gray-800'>Latest Purchases</h2>

        <Link to='/purchases' className='text-blue-500 text-sm font-medium hover:underline'>
          View All
        </Link>
      </div>

      <div className='space-y-5'>
        {dataLoading ? (
          [...Array(5)].map((_, i) => (
            <div key={i} className='flex justify-between items-start animate-pulse'>
              <div className='flex-1 space-y-2'>
                <div className='h-4 bg-neutral-200 rounded w-3/4' />
                <div className='h-3 bg-neutral-200 rounded w-1/2' />
              </div>
              <div className='h-4 bg-neutral-200 rounded w-12' />
            </div>
          ))
        ) : latestPurchases.length > 0 ? (
          latestPurchases.map((item) => (
            <div key={item._id} className='flex justify-between items-start gap-4'>
              <div className='min-w-0'>
                <p className='font-medium text-gray-800 leading-snug truncate'>
                  {item.course?.Coursename || "Deleted Course"}
                </p>

                <p className='text-sm text-gray-500 mt-1 truncate'>
                  {item.user?.username || "Unknown Student"}
                </p>
              </div>

              <span className='text-green-600 font-bold text-sm shrink-0'>
                Rs {item.course?.CoursePrice || 0}
              </span>
            </div>
          ))
        ) : (
          <p className='text-center py-4 text-neutral-500 text-sm italic'>
            No purchases recorded yet
          </p>
        )}
      </div>
    </div>
  );
}
