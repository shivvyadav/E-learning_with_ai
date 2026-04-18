import React from "react";
import {Link} from "react-router-dom";
import {useAuth} from "../context/AdminContext";

export default function NewUsers() {
  const {users, enrollments, dataLoading} = useAuth();

  //  Always ensure arrays before using array methods
  const safeUsers = Array.isArray(users) ? users : [];
  const safeEnrollments = Array.isArray(enrollments) ? enrollments : [];

  const latestUsers = safeUsers
    .slice(-5)
    .reverse()
    .map((user) => {
      const courseCount = safeEnrollments.filter(
        (emp) => (emp.user?._id || emp.user) === user._id,
      ).length;
      return {...user, courseCount};
    });

  return (
    <div className='bg-neutral-50 rounded-xl p-6 shadow-sm w-full border border-neutral-300'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-lg font-semibold text-gray-800'>New Users</h2>
        <Link to='/users' className='text-blue-500 text-sm font-medium hover:underline'>
          View All
        </Link>
      </div>

      <div className='space-y-5'>
        {dataLoading ? (
          [...Array(5)].map((_, i) => (
            <div key={i} className='flex items-center gap-4 animate-pulse'>
              <div className='w-10 h-10 rounded-full bg-neutral-200' />
              <div className='flex-1 space-y-2'>
                <div className='h-4 bg-neutral-200 rounded w-1/2' />
                <div className='h-3 bg-neutral-200 rounded w-1/3' />
              </div>
            </div>
          ))
        ) : latestUsers.length > 0 ? (
          latestUsers.map((user) => (
            <div key={user._id} className='flex items-center gap-4'>
              {user.profileimage ? (
                <img
                  src={user.profileimage}
                  alt={user.username}
                  className='w-10 h-10 rounded-full object-cover border border-neutral-200'
                />
              ) : (
                <div className='w-10 h-10 shrink-0 rounded-full flex items-center justify-center text-white bg-[#3B4CCA] font-bold text-lg uppercase shadow-sm'>
                  {user.username ? user.username.charAt(0).toUpperCase() : "U"}
                </div>
              )}

              <div className='min-w-0'>
                <p className='font-medium text-gray-800 truncate'>
                  {user.username || "Anonymous User"}
                </p>
                <p className='text-sm text-gray-500'>
                  Enrolled Courses:{" "}
                  <span className='font-semibold text-blue-600'>{user.courseCount}</span>
                </p>
              </div>
            </div>
          ))
        ) : (
          <p className='text-center py-4 text-neutral-500 text-sm italic'>No users found</p>
        )}
      </div>
    </div>
  );
}