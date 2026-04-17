import React from "react";
import {Navigate, useLocation} from "react-router-dom";
import {useAuth} from "../context/AdminContext";

const ProtectedRoute = ({children}) => {
  const {isAuthenticated, loading} = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className='flex h-screen items-center justify-center'>
        <div className='animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500'></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    // Redirect to login but save the current location to return later
    return <Navigate to='/login' state={{from: location}} replace />;
  }

  return children;
};

export default ProtectedRoute;
