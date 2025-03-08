import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';

const Navbar = () => {
  const { user, logout } = useContext(AuthContext);

  return (
    <nav className="bg-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="flex-shrink-0 flex items-center">
              <span className="text-xl font-bold text-primary-600">FreeWorldFirst</span>
              <span className="ml-1 text-gray-600">Collector</span>
            </Link>
            <div className="ml-10 flex space-x-4">
              <Link to="/" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                Startseite
              </Link>
              <Link to="/alternatives" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                Alternativen
              </Link>
              <Link to="/about" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                Über uns
              </Link>
            </div>
          </div>
          <div className="flex items-center">
            {user ? (
              <div className="flex items-center space-x-4">
                {user.isAdmin && (
                  <Link to="/admin" className="px-3 py-2 rounded-md text-sm font-medium text-primary-600 hover:bg-primary-50">
                    Admin
                  </Link>
                )}
                <span className="text-sm text-gray-700">Hallo, {user.username}</span>
                <button 
                  onClick={logout}
                  className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-red-600 hover:bg-gray-50"
                >
                  Abmelden
                </button>
              </div>
            ) : (
              <div className="flex items-center space-x-4">
                <Link to="/login" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                  Anmelden
                </Link>
                <Link to="/register" className="px-3 py-2 rounded-md text-sm font-medium bg-primary-500 text-white hover:bg-primary-600 px-4 py-2 rounded">
                  Registrieren
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
