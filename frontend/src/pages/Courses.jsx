import React, {useState} from "react";
import {Pencil, Trash2, Plus, X, Video, Loader2, Upload, ChevronDown, ChevronUp} from "lucide-react";
import {useAuth} from "../context/AdminContext";
import axios from "axios";
import {toast} from "react-hot-toast";

const StarRating = ({rating}) => {
  const stars = [1, 2, 3, 4, 5];
  return (
    <div className='flex text-lg'>
      {stars.map((star) => (
        <span key={star} className={rating >= star ? "text-yellow-400" : "text-gray-300"}>
          ★
        </span>
      ))}
    </div>
  );
};

const defaultModule = () => ({
  title: "",
  videos: [{title: "", duration: "", file: null}],
});

const Courses = () => {
  const {courses, enrollments,  dataLoading, setCourses, token} = useAuth();
  const [failedImages, setFailedImages] = useState({});
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [selectedCourse, setSelectedCourse] = useState(null);
  const [loading, setLoading] = useState(false);
  const [expandedModules, setExpandedModules] = useState({});

  const [formData, setFormData] = useState({
    Coursename: "",
    Coursedescription: "",
    CoursePrice: "",
    category: "",
    coursethumbnail: null,
    modules: [defaultModule()],
  });

  const handleImageError = (id) => setFailedImages((prev) => ({...prev, [id]: true}));

  

  const getStudentCount = (courseId) =>
    enrollments.filter((e) => e.course?._id === courseId || e.course === courseId).length;

  const toggleModule = (idx) =>
    setExpandedModules((prev) => ({...prev, [idx]: !prev[idx]}));

  const addModule = () => {
    const newIdx = formData.modules.length;
    setFormData({...formData, modules: [...formData.modules, defaultModule()]});
    setExpandedModules((prev) => ({...prev, [newIdx]: true}));
  };

  const removeModule = (mIdx) => {
    const newModules = formData.modules.filter((_, i) => i !== mIdx);
    setFormData({...formData, modules: newModules});
  };

  const updateModuleTitle = (mIdx, val) => {
    const newModules = [...formData.modules];
    newModules[mIdx] = {...newModules[mIdx], title: val};
    setFormData({...formData, modules: newModules});
  };

  const addVideo = (mIdx) => {
    const newModules = [...formData.modules];
    newModules[mIdx].videos = [...newModules[mIdx].videos, {title: "", duration: "", file: null}];
    setFormData({...formData, modules: newModules});
  };

  const removeVideo = (mIdx, vIdx) => {
    const newModules = [...formData.modules];
    newModules[mIdx].videos = newModules[mIdx].videos.filter((_, i) => i !== vIdx);
    setFormData({...formData, modules: newModules});
  };

  const updateVideo = (mIdx, vIdx, field, val) => {
    const newModules = [...formData.modules];
    newModules[mIdx].videos[vIdx] = {...newModules[mIdx].videos[vIdx], [field]: val};
    setFormData({...formData, modules: newModules});
  };

  const openAddModal = () => {
    setSelectedCourse(null);
    setFormData({
      Coursename: "",
      Coursedescription: "",
      CoursePrice: "",
      category: "",
      coursethumbnail: null,
      modules: [defaultModule()],
    });
    setExpandedModules({0: true});
    setIsModalOpen(true);
  };

  const openEditModal = (course) => {
    setSelectedCourse(course);
    const mappedModules = (course.modules || []).map((mod) => ({
      title: mod.title || "",
      videos: (mod.videos || []).map((v) => ({
        title: v.title || "",
        duration: v.duration || "",
        file: null,
        existingUrl: v.videoUrl || "",
      })),
    }));
    setFormData({
      Coursename: course.Coursename,
      Coursedescription: course.Coursedescription,
      CoursePrice: course.CoursePrice,
      category: course.category,
      coursethumbnail: null,
      modules: mappedModules.length > 0 ? mappedModules : [defaultModule()],
    });
    setExpandedModules({0: true});
    setIsModalOpen(true);
  };

  const buildFormData = () => {
    const data = new FormData();
    data.append("Coursename", formData.Coursename);
    data.append("Coursedescription", formData.Coursedescription);
    data.append("CoursePrice", formData.CoursePrice);
    data.append("category", formData.category);

    if (formData.coursethumbnail) {
      data.append("coursethumbnail", formData.coursethumbnail);
    }

    const modulesJson = formData.modules.map((mod) => ({
      title: mod.title,
      videos: mod.videos.map((v) => ({
        title: v.title,
        duration: v.duration || 0,
        videoUrl: v.existingUrl || "",
        hasNewFile: !!v.file,
      })),
    }));
    data.append("modules", JSON.stringify(modulesJson));

    formData.modules.forEach((mod) => {
      mod.videos.forEach((v) => {
        if (v.file) {
          data.append("videos", v.file);
        }
      });
    });

    return data;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const BASE_URL = import.meta.env.VITE_BASE_URL || "http://localhost:3000";
      const url = selectedCourse
        ? `${BASE_URL}/api/course/${selectedCourse._id}`
        : `${BASE_URL}/api/courses`;

      const res = await axios({
        method: selectedCourse ? "patch" : "post",
        url,
        data: buildFormData(),
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "multipart/form-data",
        },
      });

      toast.success(res.data.message);
      setIsModalOpen(false);
      window.location.reload();
    } catch (err) {
      toast.error(err.response?.data?.message || "Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  //  FIXED: instant UI update without reload
  const handleDelete = async () => {
    setLoading(true);
    try {
      const BASE_URL = import.meta.env.VITE_BASE_URL || "http://localhost:3000";
      await axios.delete(`${BASE_URL}/api/course/${selectedCourse._id}`, {
        headers: {Authorization: `Bearer ${token}`},
      });
      toast.success("Course deleted");
      setCourses((prev) => prev.filter((c) => c._id !== selectedCourse._id)); // ✅ remove from UI instantly
      setIsDeleteModalOpen(false);
      setSelectedCourse(null); //  clear selected course
    } catch (err) {
      toast.error("Delete failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className='h-[calc(100vh-80px)] flex flex-col p-4 md:p-6'>
      <div className='bg-white border border-neutral-300 rounded-xl flex flex-col h-full overflow-hidden shadow-sm'>
        {/* Header */}
        <div className='flex items-center justify-between px-6 py-4 border-b border-neutral-300 shrink-0'>
          <h2 className='text-xl font-semibold text-blue-600'>
            Courses ({Array.isArray(courses) ? courses.length : 0})
          </h2>
          <button
            onClick={openAddModal}
            className='flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition'>
            <Plus size={18} /> Add Course
          </button>
        </div>

        {/* Course List */}
        <div className='flex-1 overflow-y-auto divide-y divide-neutral-300'>
          {dataLoading ? (
            <div className='flex items-center justify-center py-20'>
              <Loader2 className='animate-spin text-blue-600' />
            </div>
          ) : Array.isArray(courses) && courses.length > 0 ? (
            courses.map((course) => (
              <div
                key={course._id}
                className='flex items-start justify-between gap-4 px-6 py-6 hover:bg-neutral-50 transition-colors'>
                <div className='flex gap-4 flex-1 min-w-0'>
                  <div className='w-16 h-16 rounded-md bg-neutral-200 shrink-0 overflow-hidden border border-neutral-100'>
                    <img
                      src={
                        failedImages[course._id] || !course.coursethumbnail
                          ? "https://via.placeholder.com/150"
                          : course.coursethumbnail
                      }
                      alt={course.Coursename}
                      onError={() => handleImageError(course._id)}
                      className='w-full h-full object-cover'
                    />
                  </div>
                  <div className='space-y-1 min-w-0'>
                    <h3 className='font-semibold text-gray-800 truncate'>{course.Coursename}</h3>
                    <div className='text-sm text-gray-600 flex gap-3'>
                      <span className='bg-blue-50 text-blue-700 px-2 py-0.5 rounded text-xs'>
                        {getStudentCount(course._id)} students
                      </span>
                      <span className='text-green-600 font-bold'>Rs. {course.CoursePrice}</span>
                    </div>
                  
                  </div>
                </div>
                <div className='flex items-center gap-3 shrink-0'>
                  <button
                    onClick={() => openEditModal(course)}
                    className='w-10 h-10 rounded-full bg-gray-100 hover:bg-blue-100 flex items-center justify-center'>
                    <Pencil size={18} className='text-blue-600' />
                  </button>
                  <button
                    onClick={() => {setSelectedCourse(course); setIsDeleteModalOpen(true);}}
                    className='w-10 h-10 rounded-full bg-gray-100 hover:bg-red-100 flex items-center justify-center'>
                    <Trash2 size={18} className='text-red-500' />
                  </button>
                </div>
              </div>
            ))
          ) : (
            <div className='flex items-center justify-center py-20 text-neutral-400 text-sm italic'>
              No courses found
            </div>
          )}
        </div>
      </div>

     
      {isModalOpen && (
        <div className='fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm'>
          <div className='bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] flex flex-col overflow-hidden shadow-2xl'>
            <div className='p-6 border-b flex justify-between items-center shrink-0'>
              <h3 className='text-xl font-bold text-gray-800'>
                {selectedCourse ? "Edit Course" : "Add New Course"}
              </h3>
              <button onClick={() => setIsModalOpen(false)} className='text-gray-400 hover:text-gray-600'>
                <X />
              </button>
            </div>

            <div className='flex-1 overflow-y-auto p-6 space-y-5'>
              <div className='grid md:grid-cols-2 gap-4'>
                <div className='space-y-1'>
                  <label className='text-sm font-medium text-gray-700'>Course Name</label>
                  <input
                    required
                    className='w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none'
                    value={formData.Coursename}
                    onChange={(e) => setFormData({...formData, Coursename: e.target.value})}
                  />
                </div>
                <div className='space-y-1'>
                  <label className='text-sm font-medium text-gray-700'>Category</label>
                  <input
                    required
                    className='w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none'
                    value={formData.category}
                    onChange={(e) => setFormData({...formData, category: e.target.value})}
                  />
                </div>
              </div>

              <div className='space-y-1'>
                <label className='text-sm font-medium text-gray-700'>Description</label>
                <textarea
                  required
                  className='w-full border border-gray-300 rounded-lg p-2.5 h-24 resize-none focus:ring-2 focus:ring-blue-500 outline-none'
                  value={formData.Coursedescription}
                  onChange={(e) => setFormData({...formData, Coursedescription: e.target.value})}
                />
              </div>

              <div className='grid md:grid-cols-2 gap-4'>
                <div className='space-y-1'>
                  <label className='text-sm font-medium text-gray-700'>Price (Rs.)</label>
                  <input
                    type='number'
                    required
                    className='w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none'
                    value={formData.CoursePrice}
                    onChange={(e) => setFormData({...formData, CoursePrice: e.target.value})}
                  />
                </div>
                <div className='space-y-1'>
                  <label className='text-sm font-medium text-gray-700'>
                    Thumbnail{" "}
                    {selectedCourse && (
                      <span className='text-xs text-gray-400'>(leave empty to keep current)</span>
                    )}
                  </label>
                  <input
                    type='file'
                    accept='image/*'
                    className='w-full text-sm border border-gray-300 rounded-lg p-2 file:mr-3 file:py-1 file:px-3 file:rounded file:border-0 file:bg-blue-50 file:text-blue-600 file:text-sm'
                    onChange={(e) => setFormData({...formData, coursethumbnail: e.target.files[0]})}
                  />
                </div>
              </div>

              <div className='border-t pt-5'>
                <div className='flex justify-between items-center mb-4'>
                  <h4 className='font-bold text-gray-800 text-base'>Modules & Content</h4>
                  <button
                    type='button'
                    onClick={addModule}
                    className='flex items-center gap-1 text-sm text-blue-600 font-semibold hover:underline'>
                    <Plus size={14} /> Add Module
                  </button>
                </div>

                <div className='space-y-4'>
                  {formData.modules.map((mod, mIdx) => (
                    <div key={mIdx} className='border border-gray-200 rounded-xl overflow-hidden'>
                      <div className='flex items-center gap-2 bg-gray-50 px-4 py-3 border-b border-gray-200'>
                        <button
                          type='button'
                          onClick={() => toggleModule(mIdx)}
                          className='text-gray-400 hover:text-gray-600'>
                          {expandedModules[mIdx] ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
                        </button>
                        <input
                          placeholder={`Module ${mIdx + 1} Title`}
                          className='flex-1 bg-transparent font-semibold text-gray-800 outline-none placeholder-gray-400'
                          value={mod.title}
                          onChange={(e) => updateModuleTitle(mIdx, e.target.value)}
                        />
                        <span className='text-xs text-gray-400 flex items-center gap-1'>
                          <Video size={11} /> {mod.videos.length}
                        </span>
                        {formData.modules.length > 1 && (
                          <button
                            type='button'
                            onClick={() => removeModule(mIdx)}
                            className='ml-2 text-red-400 hover:text-red-600'>
                            <X size={16} />
                          </button>
                        )}
                      </div>

                      {expandedModules[mIdx] && (
                        <div className='p-4 space-y-5'>
                          <div>
                            <div className='flex items-center justify-between mb-2'>
                              <span className='text-sm font-semibold text-gray-700 flex items-center gap-1.5'>
                                <Video size={14} className='text-blue-500' /> Videos
                              </span>
                              <button
                                type='button'
                                onClick={() => addVideo(mIdx)}
                                className='text-xs text-blue-600 font-medium hover:underline flex items-center gap-1'>
                                <Plus size={12} /> Add Video
                              </button>
                            </div>

                            <div className='space-y-3'>
                              {mod.videos.map((v, vIdx) => (
                                <div key={vIdx} className='bg-blue-50 rounded-lg p-3 space-y-2'>
                                  <div className='flex items-center gap-2'>
                                    <span className='text-xs font-bold text-blue-400 w-5'>#{vIdx + 1}</span>
                                    <input
                                      placeholder='Video title'
                                      className='flex-1 text-sm border border-blue-200 rounded-md p-1.5 outline-none focus:ring-1 focus:ring-blue-400 bg-white'
                                      value={v.title}
                                      onChange={(e) => updateVideo(mIdx, vIdx, "title", e.target.value)}
                                    />
                                    <input
                                      placeholder='Duration (mins)'
                                      type='number'
                                      className='w-28 text-sm border border-blue-200 rounded-md p-1.5 outline-none focus:ring-1 focus:ring-blue-400 bg-white'
                                      value={v.duration}
                                      onChange={(e) => updateVideo(mIdx, vIdx, "duration", e.target.value)}
                                    />
                                    {mod.videos.length > 1 && (
                                      <button
                                        type='button'
                                        onClick={() => removeVideo(mIdx, vIdx)}
                                        className='text-red-400 hover:text-red-600'>
                                        <X size={14} />
                                      </button>
                                    )}
                                  </div>

                                  <div className='flex items-center gap-2 pl-5'>
                                    <label className='flex items-center gap-2 cursor-pointer bg-white border border-dashed border-blue-300 rounded-md px-3 py-1.5 text-xs text-blue-600 hover:bg-blue-50 transition flex-1'>
                                      <Upload size={12} />
                                      {v.file ? (
                                        <span className='truncate max-w-[200px] font-medium'>{v.file.name}</span>
                                      ) : v.existingUrl ? (
                                        <span className='text-green-600 truncate max-w-[200px]'>✓ Existing video (click to replace)</span>
                                      ) : (
                                        <span>Choose video file (.mp4, .webm)</span>
                                      )}
                                      <input
                                        type='file'
                                        accept='video/*'
                                        className='hidden'
                                        onChange={(e) => updateVideo(mIdx, vIdx, "file", e.target.files[0])}
                                      />
                                    </label>
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            </div>

            <div className='p-5 border-t bg-gray-50 flex justify-end gap-3 shrink-0'>
              <button
                type='button'
                onClick={() => setIsModalOpen(false)}
                className='px-6 py-2 rounded-lg border border-gray-300 font-medium text-gray-700 hover:bg-gray-100'>
                Cancel
              </button>
              <button
                onClick={handleSubmit}
                disabled={loading}
                className='bg-blue-600 text-white px-8 py-2 rounded-lg font-bold hover:bg-blue-700 flex items-center gap-2 disabled:opacity-60'>
                {loading && <Loader2 className='animate-spin' size={18} />}
                {selectedCourse ? "Update Course" : "Create Course"}
              </button>
            </div>
          </div>
        </div>
      )}

      {isDeleteModalOpen && (
        <div className='fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4 backdrop-blur-sm'>
          <div className='bg-white rounded-xl p-6 w-full max-w-md shadow-2xl'>
            <h3 className='text-lg font-bold text-gray-800'>Delete Course?</h3>
            <p className='text-gray-600 mt-2'>
              This will permanently remove{" "}
              <span className='font-bold'>"{selectedCourse?.Coursename}"</span> and all associated files.
            </p>
            <div className='mt-6 flex justify-end gap-3'>
              <button
                onClick={() => {setIsDeleteModalOpen(false); setSelectedCourse(null);}}
                className='px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-50'>
                Cancel
              </button>
              <button
                onClick={handleDelete}
                disabled={loading}
                className='bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 disabled:opacity-60'>
                {loading ? "Deleting..." : "Delete Permanently"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Courses;