import React, {useState, useEffect} from "react";
import axios from "axios";
import {useAuth} from "../context/AdminContext";
import {useNavigate, useLocation} from "react-router-dom";

const Login = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const {login, isAuthenticated} = useAuth();

  // Get the redirect path or default to dashboard
  const from = location.state?.from?.pathname || "/";

  const [form, setForm] = useState({email: "", password: ""});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const BASE_URL = import.meta.env.VITE_BASE_URL;

  // Redirect if already logged in
  useEffect(() => {
    if (isAuthenticated) {
      navigate(from, {replace: true});
    }
  }, [isAuthenticated, navigate, from]);

  const handleChange = (e) => {
    setForm({...form, [e.target.name]: e.target.value});
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const res = await axios.post(`${BASE_URL}/api/auth/login`, form);

      // Adjusted based on your response structure
      const userData = res.data.data?.[0] || res.data.user;
      const userToken = res.data.token;

      if (userToken) {
        login(userData, userToken);
        // Navigation is handled by the useEffect above once isAuthenticated becomes true
      } else {
        setError("Invalid response from server");
      }
    } catch (err) {
      setError(err.response?.data?.message || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className='flex min-h-screen items-center justify-center bg-gray-100'>
      <div className='w-full max-w-md bg-white p-8 rounded-lg shadow-md'>
        <h2 className='text-2xl font-bold mb-6 text-center'>Admin Login</h2>

        {error && <p className='text-red-500 text-sm mb-3 text-center'>{error}</p>}

        <form onSubmit={handleSubmit} className='space-y-4'>
          <input
            type='email'
            name='email'
            placeholder='Email'
            value={form.email}
            onChange={handleChange}
            className='w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400'
            required
          />
          <input
            type='password'
            name='password'
            placeholder='Password'
            value={form.password}
            onChange={handleChange}
            className='w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400'
            required
          />
          <button
            type='submit'
            disabled={loading}
            className='w-full bg-blue-500 hover:bg-blue-600 text-white py-3 rounded-lg transition duration-200 disabled:bg-blue-300'>
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
