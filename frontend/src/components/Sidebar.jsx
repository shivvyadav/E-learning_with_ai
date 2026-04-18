import {Link, useLocation} from "react-router-dom";
import {LayoutDashboard, BookOpen, Star, Users, ShoppingCart, X, LogOut} from "lucide-react";
import {useAuth} from "../context/AdminContext"; // Import your auth hook

const menuItems = [
  {name: "Dashboard", path: "/", icon: LayoutDashboard},
  {name: "Courses", path: "/courses", icon: BookOpen},
  {name: "Purchases", path: "/purchases", icon: ShoppingCart},
  {name: "Users", path: "/users", icon: Users},
];

const Sidebar = ({isOpen, setIsOpen}) => {
  const location = useLocation();
  const {logout} = useAuth();

  return (
    <>
      {isOpen && (
        <div
          className='fixed inset-0 bg-black/40 z-40 lg:hidden'
          onClick={() => setIsOpen(false)}
        />
      )}

      <div
        className={`fixed top-0 left-0 h-screen w-64 bg-[#3B4CCA] text-white z-50 transform transition-transform duration-300 border-r border-white/10 flex flex-col
        ${isOpen ? "translate-x-0" : "-translate-x-full"}
        lg:translate-x-0`}>
        <div className='flex items-center justify-between px-6 py-5 shrink-0'>
          <h1 className='text-xl font-bold'>E-Learning</h1>
          <button className='lg:hidden' onClick={() => setIsOpen(false)}>
            <X size={22} />
          </button>
        </div>

        <div className='flex flex-col gap-2 mt-4 px-3 overflow-y-auto'>
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;

            return (
              <Link
                key={item.name}
                to={item.path}
                onClick={() => setIsOpen(false)}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition
                ${isActive ? "bg-white text-[#3B4CCA] font-semibold" : "hover:bg-white/10"}`}>
                <Icon size={20} />
                {item.name}
              </Link>
            );
          })}
        </div>

        <div className='mt-auto p-4 border-t border-white/10'>
          <button
            onClick={() => {
              logout();
              setIsOpen(false);
            }}
            className='flex items-center gap-3 w-full px-4 py-3 rounded-xl transition hover:bg-red-500/20 text-red-200 hover:text-red-500'>
            <LogOut size={20} />
            <span className='font-medium'>Logout</span>
          </button>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
