import React, {createContext, useContext, useEffect, useState, useCallback} from "react";
import axios from "axios";

const AuthContext = createContext();

export const AdminProvider = ({children}) => {
  const [user, setUser] = useState(() => {
    const savedUser = localStorage.getItem("user");
    return savedUser ? JSON.parse(savedUser) : null;
  });
  const [token, setToken] = useState(() => localStorage.getItem("token"));
  const [loading, setLoading] = useState(true);

  const [courses, setCourses] = useState([]);
  const [users, setUsers] = useState([]);
  const [enrollments, setEnrollments] = useState([]);
  
  const [dataLoading, setDataLoading] = useState(false);

  const logout = useCallback(() => {
    localStorage.removeItem("user");
    localStorage.removeItem("token");
    setUser(null);
    setToken(null);
    setCourses([]);
    setUsers([]);
    setEnrollments([]);
   
  }, []);

  const fetchAllData = useCallback(async () => {
    if (!token) return;

    setDataLoading(true);
    try {
      const BASE_URL = import.meta.env.VITE_BASE_URL || "http://localhost:3000";
      const res = await axios.get(`${BASE_URL}/api/misc/datas`, {
        headers: {Authorization: `Bearer ${token}`},
      });

      console.log("API response:", JSON.stringify(res.data, null, 2)); //  debug line, remove later

      if (res.data.data) {
        const {courses, users, enrollments} = res.data.data;
        console.log("First enrollment status:", enrollments?.[0]?.status);
        
        //  Always ensure arrays before setting state
        setCourses(Array.isArray(courses) ? courses : []);
        setUsers(Array.isArray(users) ? users : []);
        setEnrollments(Array.isArray(enrollments) ? enrollments : []);
        
      }
    } catch (err) {
      console.error("Error fetching admin dashboard data:", err);
    } finally {
      setDataLoading(false);
    }
  }, [token]);

  useEffect(() => {
    setLoading(false);
  }, []);

  useEffect(() => {
    if (token && user) {
      fetchAllData();
    }
  }, [token, user, fetchAllData]);

  const login = (userData, userToken) => {
    localStorage.setItem("user", JSON.stringify(userData));
    localStorage.setItem("token", userToken);
    setUser(userData);
    setToken(userToken);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        login,
        logout,
        isAuthenticated: !!token && !!user,
        loading,
        courses,
        setCourses,
        users,
        enrollments,
        dataLoading,
        isReady: !loading && !dataLoading, //  combined ready flag
        refreshAll: fetchAllData,
      }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used inside AdminProvider");
  return context;
};