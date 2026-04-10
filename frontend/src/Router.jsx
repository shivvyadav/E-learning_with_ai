import {createBrowserRouter, RouterProvider, Outlet} from "react-router-dom";
import {useState} from "react";

import Navbar from "./components/Navbar.jsx";
import Sidebar from "./components/Sidebar.jsx";

import Login from "./pages/Login.jsx";
import Admin from "./pages/Admin.jsx";
import Users from "./pages/Users.jsx";
import Courses from "./pages/Courses.jsx";
import Purchases from "./pages/Purchases.jsx";


import ProtectedRoute from "./context/ProtectedRoute.jsx";

const Layout = () => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className='h-screen flex'>
      <Navbar setIsOpen={setIsOpen} />
      <Sidebar isOpen={isOpen} setIsOpen={setIsOpen} />

      <div className='flex-1 pt-20 lg:ml-64'>
        <Outlet />
      </div>
    </div>
  );
};

const Router = () => {
  const router = createBrowserRouter([
    {
      element: (
        <ProtectedRoute>
          <Layout />
        </ProtectedRoute>
      ),
      children: [
        {path: "/", element: <Admin />},
        {path: "/courses", element: <Courses />},
        {path: "/users", element: <Users />},
        {path: "/purchases", element: <Purchases />},
      ],
    },
    {
      path: "/login",
      element: <Login />,
    },
  ]);

  return <RouterProvider router={router} />;
};

export default Router;
