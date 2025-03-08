import React from 'react';
import { Link } from 'react-router-dom';

const Footer = () => {
 return (
   <footer className="bg-primary-earth/90 text-white mt-12 py-8 border-t">
     <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
       <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
         <div>
           <h3 className="text-lg font-semibold text-primary-light mb-4">FreeWorldFirst Collector</h3>
           <p className="text-white/90">
             Eine Plattform für ethische Alternativen zu BigTech-Produkten und -Diensten.
           </p>
         </div>
         <div>
           <h3 className="text-lg font-semibold text-primary-light mb-4">Links</h3>
           <ul className="space-y-2">
             <li>
               <Link to="/" className="text-white/90 hover:text-primary-light">
                 Startseite
               </Link>
             </li>
             <li>
               <Link to="/alternatives" className="text-white/90 hover:text-primary-light">
                 Alternativen
               </Link>
             </li>
             <li>
               <Link to="/about" className="text-white/90 hover:text-primary-light">
                 Über uns
               </Link>
             </li>
           </ul>
         </div>
         <div>
           <h3 className="text-lg font-semibold text-primary-light mb-4">Rechtliches</h3>
           <ul className="space-y-2">
             <li>
               <Link to="/privacy" className="text-white/90 hover:text-primary-light">
                 Datenschutz
               </Link>
             </li>
             <li>
               <Link to="/terms" className="text-white/90 hover:text-primary-light">
                 Nutzungsbedingungen
               </Link>
             </li>
             <li>
               <Link to="/imprint" className="text-white/90 hover:text-primary-light">
                 Impressum
               </Link>
             </li>
           </ul>
         </div>
       </div>
       <div className="mt-8 pt-8 border-t border-white/20">
         <p className="text-center text-white/80">
           &copy; {new Date().getFullYear()} FreeWorldFirst Collector. Alle Rechte vorbehalten.
         </p>
       </div>
     </div>
   </footer>
 );
};

export default Footer;