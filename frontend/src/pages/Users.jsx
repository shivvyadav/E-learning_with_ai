import {useState} from "react";
import {motion, AnimatePresence} from "framer-motion";
import {Search, Trash2, AlertTriangle} from "lucide-react";
import {useAuth} from "../context/AdminContext";
import axios from "axios";

export default function UsersPage() {
  const {users, enrollments, token, refreshAll} = useAuth();
  const [search, setSearch] = useState("");
  const [deleteId, setDeleteId] = useState(null); // Stores ID of user to be deleted
  const [isDeleting, setIsDeleting] = useState(false);

  // 1. Filter users based on search (Email)
  // 2. Calculate enrollment count dynamically from the enrollments state
  const filteredUsers = users
    .filter((user) => user.useremail.toLowerCase().includes(search.toLowerCase()))
    .map((user) => {
      const userCourses = enrollments.filter(
        (emp) => emp.user?._id === user._id || emp.user === user._id,
      ).length;
      return {...user, courseCount: userCourses};
    });

  const handleDelete = async () => {
    if (!deleteId) return;
    setIsDeleting(true);
    try {
      const BASE_URL = import.meta.env.VITE_BASE_URL || "http://localhost:3000";
      await axios.delete(`${BASE_URL}/api/users/${deleteId}`, {
        headers: {Authorization: `Bearer ${token}`},
      });
      await refreshAll(); // Refresh context data to reflect deletion
      setDeleteId(null);
    } catch (err) {
      alert(err.response?.data?.message || "Failed to delete user");
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <div className='w-full h-full p-4 flex justify-center items-start relative'>
      <div className='w-full lg:max-w-6xl bg-white border border-neutral-300 rounded-2xl flex flex-col h-[84vh] shadow-sm'>
        {/* Header & Search */}
        <div className='px-6 py-4 border-b border-neutral-300 flex flex-col md:flex-row md:items-center md:justify-between gap-4 min-w-150'>
          <h2 className='text-xl font-semibold text-blue-600'>Users ({users.length})</h2>
          <div className='relative w-full md:w-80'>
            <Search
              size={18}
              className='absolute left-3 top-1/2 -translate-y-1/2 text-neutral-400'
            />
            <input
              type='text'
              placeholder='Search by email...'
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className='w-full pl-9 pr-3 py-2 rounded-lg border border-neutral-300 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'
            />
          </div>
        </div>

        {/* Table Header */}
        <div className='overflow-x-auto flex-1'>
          <div className='min-w-150 flex flex-col h-full'>
            <div className='grid grid-cols-[35%_35%_15%_15%] px-6 py-4 text-sm font-medium text-neutral-600 border-b border-neutral-300 bg-neutral-50'>
              <span>User</span>
              <span>Email</span>
              <span>Enrolled</span>
              <span className='text-center'>Action</span>
            </div>

            {/* User List */}
            <div className='flex-1 overflow-y-auto'>
              {filteredUsers.map((user, index) => (
                <motion.div
                  key={user._id}
                  initial={{opacity: 0, y: 8}}
                  animate={{opacity: 1, y: 0}}
                  transition={{duration: 0.2, delay: index * 0.02}}
                  className='grid grid-cols-[35%_35%_15%_15%] px-6 py-4 border-b border-neutral-300 hover:bg-neutral-50 items-center'>
                  <div className='flex items-center gap-3'>
                    <div className='w-10 h-10 rounded-full bg-[#3B4CCA] text-white flex items-center justify-center font-semibold shrink-0'>
                      {user.username?.charAt(0).toUpperCase()}
                    </div>
                    <span className='font-medium truncate'>{user.username}</span>
                  </div>

                  <div className='text-neutral-600 truncate'>{user.useremail}</div>

                  <div className='font-medium pl-4'>
                    <span className='bg-blue-50 text-blue-700 px-2 py-1 rounded text-xs'>
                      {user.courseCount} Courses
                    </span>
                  </div>

                  <div className='flex justify-center'>
                    <button
                      onClick={() => setDeleteId(user._id)}
                      className='p-2 text-neutral-400 hover:text-red-600 hover:bg-red-50 rounded-full transition-colors'>
                      <Trash2 size={18} />
                    </button>
                  </div>
                </motion.div>
              ))}

              {filteredUsers.length === 0 && (
                <div className='text-center py-20 text-neutral-500 font-medium'>
                  No users found for "{search}"
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Confirmation Modal */}
      <AnimatePresence>
        {deleteId && (
          <div className='fixed inset-0 z-60 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm'>
            <motion.div
              initial={{scale: 0.9, opacity: 0}}
              animate={{scale: 1, opacity: 1}}
              exit={{scale: 0.9, opacity: 0}}
              className='bg-white rounded-2xl p-6 max-w-sm w-full shadow-2xl'>
              <div className='flex items-center gap-3 text-red-600 mb-4'>
                <AlertTriangle size={24} />
                <h3 className='text-lg font-bold'>Confirm Delete</h3>
              </div>
              <p className='text-neutral-600 mb-6'>
                Are you sure you want to delete this user? This action cannot be undone and will
                remove all their data.
              </p>
              <div className='flex gap-3'>
                <button
                  onClick={() => setDeleteId(null)}
                  className='flex-1 py-2 bg-neutral-100 hover:bg-neutral-200 text-neutral-700 rounded-lg font-medium transition'>
                  Cancel
                </button>
                <button
                  onClick={handleDelete}
                  disabled={isDeleting}
                  className='flex-1 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition disabled:bg-red-400'>
                  {isDeleting ? "Deleting..." : "Delete User"}
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
