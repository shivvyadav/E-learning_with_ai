import {Menu} from "lucide-react";

const Navbar = ({setIsOpen}) => {
  return (
    <div className='fixed top-0 left-0 w-full h-16 bg-white shadow-sm flex items-center z-30 px-4 md:px-6 lg:pl-72'>
      <button className='lg:hidden mr-3' onClick={() => setIsOpen(true)}>
        <Menu size={24} />
      </button>

      <h1 className='text-lg font-bold text-neutral-800'>E-Learning Admin</h1>
    </div>
  );
};

export default Navbar;
