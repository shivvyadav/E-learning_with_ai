import React, {useState} from "react";
import {useAuth} from "../context/AdminContext";
import axios from "axios";
import {toast} from "react-hot-toast";
import {Trash2} from "lucide-react";

const Purchases = () => {
  const {enrollments, dataLoading, refreshAll, token} = useAuth();
  const [deletingId, setDeletingId] = useState(null);

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to remove this enrollment?")) return;
    setDeletingId(id);
    try {
      const BASE_URL = import.meta.env.VITE_BASE_URL || "http://localhost:3000";
      await axios.delete(`${BASE_URL}/api/enrollment/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      toast.success("Enrollment deleted");
      await refreshAll(); // ✅ instant UI update via context
    } catch (err) {
      toast.error(err.response?.data?.message || "Delete failed");
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <div className='p-4 md:p-6'>
      <div className='bg-white border border-neutral-300 rounded-xl overflow-hidden shadow-sm'>
        <div className='px-6 py-4 border-b border-neutral-300 flex justify-between items-center'>
          <h2 className='text-xl font-semibold text-blue-600'>Enrollments</h2>
          <span className='text-sm bg-blue-50 text-blue-600 px-3 py-1 rounded-full font-medium'>
            Total: {enrollments.length}
          </span>
        </div>

        <div className='overflow-auto max-h-[calc(100vh-200px)]'>
          {dataLoading ? (
            <div className='flex items-center justify-center py-20'>
              <div className='animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600'></div>
            </div>
          ) : enrollments.length === 0 ? (
            <div className='text-center py-20 text-neutral-500'>No enrollment records found.</div>
          ) : (
            <table className='w-full min-w-175'>
              <thead className='bg-neutral-100 border-b border-neutral-300 sticky top-0 z-10'>
                <tr className='text-left text-neutral-700 text-sm md:text-base'>
                  <th className='px-6 py-4 font-semibold'>User</th>
                  <th className='px-6 py-4 font-semibold'>Course Name</th>
                  <th className='px-6 py-4 font-semibold'>Status</th>
                  <th className='px-6 py-4 font-semibold'>Price</th>
                  <th className='px-6 py-4 font-semibold'>Purchased At</th>
                  <th className='px-6 py-4 font-semibold'>Action</th>
                </tr>
              </thead>

              <tbody className='divide-y divide-neutral-300'>
                {enrollments.map((item) => (
                  <tr key={item._id} className='hover:bg-neutral-50 transition'>
                    <td className='px-6 py-4'>
                      <div className='flex items-center gap-3'>
                        <div className='w-10 h-10 shrink-0 rounded-full bg-[#3B4CCA] flex items-center justify-center text-white font-medium'>
                          {item.user?.username?.charAt(0) || "U"}
                        </div>
                        <div className='min-w-0'>
                          <p className='font-medium text-neutral-800 truncate'>
                            {item.user?.username || "Unknown User"}
                          </p>
                          <p className='text-sm text-neutral-500 truncate'>
                            {item.user?.useremail || "No Email"}
                          </p>
                        </div>
                      </div>
                    </td>

                    <td className='px-6 py-4'>
                      <span className='text-neutral-800 font-medium'>
                        {item.course?.Coursename || "Deleted Course"}
                      </span>
                    </td>

                    <td className='px-6 py-4'>
                      <span
                        className={`px-2 py-1 rounded-md text-xs font-bold uppercase ${
                          item.status === "active"
                            ? "bg-green-100 text-green-600"
                            : "bg-blue-100 text-blue-600"
                        }`}>
                        {item.status}
                      </span>
                    </td>

                    <td className='px-6 py-4 font-medium text-neutral-700'>
                      Rs {item.course?.CoursePrice || "0"}
                    </td>

                    <td className='px-6 py-4 text-neutral-600 whitespace-nowrap text-sm'>
                      {formatDate(item.enrolleddate)}
                    </td>

                    {/* ✅ Delete Action */}
                    <td className='px-6 py-4'>
                      <button
                        onClick={() => handleDelete(item._id)}
                        disabled={deletingId === item._id}
                        className='w-9 h-9 rounded-full bg-gray-100 hover:bg-red-100 flex items-center justify-center transition disabled:opacity-50'>
                        {deletingId === item._id ? (
                          <div className='w-4 h-4 border-2 border-red-400 border-t-transparent rounded-full animate-spin' />
                        ) : (
                          <Trash2 size={16} className='text-red-500' />
                        )}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
};

export default Purchases;