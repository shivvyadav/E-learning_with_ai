import React from "react";
import {Link} from "react-router-dom";
import {Star} from "lucide-react";
import {useAuth} from "../context/AdminContext";

export default function LatestReviews() {
  const {reviews, dataLoading} = useAuth();

  // Get the 5 most recent reviews (last in array, reversed)
  const latestReviews = reviews.slice(-5).reverse();

  const renderStars = (rating) => {
    const stars = [];
    const fullStars = Math.floor(rating || 0);

    for (let i = 0; i < 5; i++) {
      stars.push(
        <Star
          key={i}
          size={14}
          className={`${i < fullStars ? "text-yellow-500 fill-yellow-500" : "text-neutral-300"}`}
        />,
      );
    }
    return stars;
  };

  return (
    <div className='bg-neutral-50 rounded-xl p-6 shadow-sm w-full border border-neutral-300'>
      <div className='flex justify-between items-center mb-6'>
        <h2 className='text-lg font-semibold text-gray-800'>Latest Reviews</h2>
        <Link to='/reviews' className='text-blue-500 text-sm font-medium hover:underline'>
          View All
        </Link>
      </div>

      <div className='space-y-5'>
        {dataLoading ? (
          // Skeleton Loader
          [...Array(5)].map((_, i) => (
            <div key={i} className='flex gap-4 animate-pulse'>
              <div className='w-10 h-10 rounded-full bg-neutral-200 shrink-0' />
              <div className='flex-1 space-y-2'>
                <div className='h-4 bg-neutral-200 rounded w-1/3' />
                <div className='h-3 bg-neutral-200 rounded w-1/4' />
              </div>
            </div>
          ))
        ) : latestReviews.length > 0 ? (
          latestReviews.map((review) => (
            <div key={review._id} className='flex gap-4'>
              {/* Avatar Logic: Image or Uppercase First Letter */}
              {review.userId?.profileimage ? (
                <img
                  src={review.userId.profileimage}
                  alt='user'
                  className='w-10 h-10 rounded-full object-cover shrink-0 border border-neutral-200'
                />
              ) : (
                <div className='w-10 h-10 shrink-0 rounded-full flex items-center justify-center text-white bg-[#3B4CCA] font-bold uppercase text-sm shadow-sm'>
                  {review.userId?.username?.charAt(0).toUpperCase() || "U"}
                </div>
              )}

              <div className='min-w-0 flex-1'>
                <div className='flex justify-between items-start gap-2'>
                  <p className='font-medium text-gray-800 truncate'>
                    {review.userId?.username || "Anonymous"}
                  </p>
                </div>

                <div className='flex items-center gap-2 mt-0.5'>
                  <div className='flex'>{renderStars(review.rating)}</div>
                  <span className='text-yellow-600 text-xs font-bold'>
                    {(review.rating || 0).toFixed(1)}
                  </span>
                </div>

                {review.comment && (
                  <p className='text-sm text-gray-500 mt-1 line-clamp-2 italic'>
                    "{review.comment}"
                  </p>
                )}
              </div>
            </div>
          ))
        ) : (
          <p className='text-center py-4 text-neutral-500 text-sm italic'>No reviews yet</p>
        )}
      </div>
    </div>
  );
}
