import React, { useState, useEffect, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';
import Button from '../components/Button';
import Loading from '../components/Loading';
import { getDashboardStats, approveAlternative } from '../services/adminService';

const AdminDashboard = () => {
  const { user, isAuthenticated } = useContext(AuthContext);
  const navigate = useNavigate();
  
  const [stats, setStats] = useState(null);
  const [latestAlternatives, setLatestAlternatives] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Überprüfen, ob der Benutzer angemeldet und Admin ist
    if (!isAuthenticated) {
      navigate('/login', { state: { from: `/admin` } });
      return;
    }
    
    if (isAuthenticated && !user?.isAdmin) {
      navigate('/');
      return;
    }
    
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await getDashboardStats();
        setStats(data.stats);
        setLatestAlternatives(data.latestAlternatives);
        setLoading(false);
      } catch (err) {
        setError('Fehler beim Laden der Dashboard-Daten.');
        setLoading(false);
      }
    };
    
    fetchData();
  }, [isAuthenticated, user, navigate]);
  const handleApprove = async (id, approved) => {
   try {
     await approveAlternative(id, approved);
     
     // Aktualisiere die Liste nach Genehmigung/Ablehnung
     setLatestAlternatives(
       latestAlternatives.map(alt => 
         alt.id === id ? { ...alt, approved } : alt
       )
     );
   } catch (err) {
     setError('Fehler beim Aktualisieren des Genehmigungsstatus.');
   }
 };

 if (loading) return <div className="max-w-7xl mx-auto px-4 py-8"><Loading /></div>;
 if (error) return <div className="max-w-7xl mx-auto px-4 py-8 bg-red-50 p-4 rounded text-red-800">{error}</div>;
 if (!stats) return <div className="max-w-7xl mx-auto px-4 py-8">Keine Daten verfügbar.</div>;

 return (
   <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
     <h1 className="text-3xl font-bold text-gray-900 mb-8">Admin-Dashboard</h1>
     
     <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Alternativen</h2>
         <p className="text-3xl font-bold text-primary-600">{stats.totalAlternatives}</p>
       </div>
       
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Ausstehend</h2>
         <p className="text-3xl font-bold text-yellow-500">{stats.pendingAlternatives}</p>
       </div>
       
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Benutzer</h2>
         <p className="text-3xl font-bold text-primary-600">{stats.totalUsers}</p>
       </div>
       
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Kommentare</h2>
         <p className="text-3xl font-bold text-primary-600">{stats.totalComments}</p>
       </div>
     </div>
     
     <div className="bg-white rounded-lg shadow mb-8">
       <div className="px-6 py-4 border-b border-gray-200">
         <h2 className="text-lg font-medium text-gray-900">Neueste Alternativen</h2>
       </div>
       
       <div className="divide-y divide-gray-200">
         {latestAlternatives.length === 0 ? (
           <div className="px-6 py-4 text-gray-500">
             Keine Alternativen vorhanden.
           </div>
         ) : (
           latestAlternatives.map((alternative) => (
             <div key={alternative.id} className="px-6 py-4 flex items-center justify-between">
               <div>
               <Link 
                  to={`/alternatives/${alternative.id}`}
                  className="text-primary-600 hover:text-primary-800"
              >
                  {alternative.title}
              </Link>
                 <p className="text-sm text-gray-500">
                   Ersetzt: {alternative.replaces} | Kategorie: {alternative.category}
                 </p>
               </div>
               
               <div className="flex space-x-2">
                 {alternative.approved ? (
                   <Button 
                     variant="danger" 
                     onClick={() => handleApprove(alternative.id, false)}
                   >
                     Ablehnen
                   </Button>
                 ) : (
                   <Button 
                     onClick={() => handleApprove(alternative.id, true)}
                   >
                     Genehmigen
                   </Button>
                 )}
               </div>
             </div>
           ))
         )}
       </div>
     </div>
     
     <div className="flex space-x-4">
       <Link to="/admin/alternatives" className="btn-secondary">
         Alle Alternativen verwalten
       </Link>
       <Link to="/admin/users" className="btn-secondary">
         Benutzer verwalten
       </Link>
     </div>
   </div>
 );
};

export default AdminDashboard;
