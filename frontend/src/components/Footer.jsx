import React from 'react';
import { Link } from 'react-router-dom';

const Footer = () => {
  return (
    <footer className="bg-white mt-12 py-8 border-t">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">FreeWorldFirst Collector</h3>
            <p className="text-gray-600">
              Eine Plattform für ethische Alternativen zu BigTech-Produkten und -Diensten.
            </p>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Links</h3>
            <ul className="space-y-2">
              <li>
                <Link to="/" className="text-gray-600 hover:text-primary-600">
                  Startseite
                </Link>
              </li>
              <li>
                <Link to="/alternatives" className="text-gray-600 hover:text-primary-600">
                  Alternativen
                </Link>
              </li>
              <li>
                <Link to="/about" className="text-gray-600 hover:text-primary-600">
                  Über uns
                </Link>
              </li>
            </ul>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Rechtliches</h3>
            <ul className="space-y-2">
              <li>
                <Link to="/privacy" className="text-gray-600 hover:text-primary-600">
                  Datenschutz
                </Link>
              </li>
              <li>
                <Link to="/terms" className="text-gray-600 hover:text-primary-600">
                  Nutzungsbedingungen
                </Link>
              </li>
              <li>
                <Link to="/imprint" className="text-gray-600 hover:text-primary-600">
                  Impressum
                </Link>
              </li>
            </ul>
          </div>
        </div>
        <div className="mt-8 pt-8 border-t border-gray-200">
<p className="text-center text-gray-600">
            &copy; {new Date().getFullYear()} FreeWorldFirst Collector. Alle Rechte vorbehalten.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
