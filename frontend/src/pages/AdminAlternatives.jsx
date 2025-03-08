import React, { useState, useEffect, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';
import Button from '../components/Button';
import Loading from '../components/Loading';
import { getAlternatives } from '../services/alternativeService';
import { approveAlternative, deleteAlternative } from '../services/adminService';

const AdminAlternatives = () => {
 const { user, isAuthenticated } = useContext(AuthContext);
 const navigate = useNavigate();
 
 const [alternatives, setAlternatives] = useState([]);
 const [loading, setLoading] = useState(true);
 const [error, setError] = useState(null);
 const [page, setPage] = useState(1);
 const [totalPages, setTotalPages] = useState(1);
 const [filter, setFilter] = useState('');
 const [showApproved, setShowApproved] = useState('all'); // 'all', 'approved', 'pending'

 useEffect(() => {
   // Überprüfen, ob der Benutzer angemeldet und Admin ist
   if (!isAuthenticated) {
     navigate('/login', { state: { from: '/admin/alternatives' } });
     return;
   }
   
   if (isAuthenticated && !user?.isAdmin) {
     navigate('/');
     return;
   }
   
   const fetchAlternatives = async () => {
     try {
       setLoading(true);
       const params = { 
         page, 
         search: filter,
       };
       
       if (showApproved !== 'all') {
         params.approved = showApproved === 'approved';
       }
       
       const response = await getAlternatives(params);
       setAlternatives(response.alternatives);
       setTotalPages(response.pages);
       setLoading(false);
     } catch (err) {
       setError('Fehler beim Laden der Alternativen.');
       setLoading(false);
     }
   };
   
   fetchAlternatives();
 }, [isAuthenticated, user, navigate, page, filter, showApproved]);

 const handleNextPage = () => {
   if (page < totalPages) {
     setPage(page + 1);
     window.scrollTo(0, 0);
   }
 };

 const handlePreviousPage = () => {
   if (page > 1) {
     setPage(page - 1);
     window.scrollTo(0, 0);
   }
 };

 const handleApprove = async (id, approved) => {
   try {
     await approveAlternative(id, approved);
     
     // Aktualisiere die Liste nach Genehmigung/Ablehnung
     setAlternatives(
       alternatives.map(alt => 
         alt.id === id ? { ...alt, approved } : alt
       )
     );
   } catch (err) {
     setError('Fehler beim Aktualisieren des Genehmigungsstatus.');
   }
 };

 const handleDelete = async (id) => {
   if (!window.confirm('Möchten Sie diese Alternative wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.')) {
     return;
   }
   
   try {
     await deleteAlternative(id);
     
     // Entferne die gelöschte Alternative aus der Liste
     setAlternatives(alternatives.filter(alt => alt.id !== id));
   } catch (err) {
     setError('Fehler beim Löschen der Alternative.');
   }
 };

 if (loading && page === 1) return <div className="max-w-7xl mx-auto px-4 py-8"><Loading /></div>;
 
 return (
   <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
     <div className="flex justify-between items-center mb-8">
       <h1 className="text-3xl font-bold text-gray-900">Alternativen verwalten</h1>
       <Link to="/admin" className="btn-secondary">
         Zurück zum Dashboard
       </Link>
     </div>
     
     <div className="bg-white rounded-lg shadow p-6 mb-8">
       <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
         <div>
           <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-1">
             Suche
           </label>
           <input
             type="text"
             id="search"
             value={filter}
             onChange={(e) => {
               setFilter(e.target.value);
               setPage(1);
             }}
             placeholder="Nach Titel oder ersetztem Produkt suchen..."
             className="input-field"
           />
         </div>
         
         <div>
           <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-1">
             Status
           </label>
           <select
             id="status"
             value={showApproved}
             onChange={(e) => {
               setShowApproved(e.target.value);
               setPage(1);
             }}
             className="input-field"
           >
             <option value="all">Alle</option>
             <option value="approved">Genehmigt</option>
             <option value="pending">Ausstehend</option>
           </select>
         </div>
       </div>
     </div>
     
     {error && (
       <div className="bg-red-50 p-4 rounded-lg mb-6 text-red-800">
         {error}
       </div>
     )}
     
     <div className="bg-white rounded-lg shadow mb-8">
       <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
         <h2 className="text-lg font-medium text-gray-900">Alternativen</h2>
         <span className="text-sm text-gray-500">
           Seite {page} von {totalPages}
         </span>
       </div>
       
       {loading ? (
         <div className="p-6">
           <Loading />
         </div>
       ) : alternatives.length === 0 ? (
         <div className="px-6 py-4 text-gray-500">
           Keine Alternativen gefunden.
         </div>
       ) : (
         <div className="overflow-x-auto">
           <table className="min-w-full divide-y divide-gray-200">
             <thead className="bg-gray-50">
               <tr>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Titel
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Ersetzt
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Kategorie
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Status
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Upvotes
                 </th>
                 <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Aktionen
                 </th>
               </tr>
             </thead>
             <tbody className="bg-white divide-y divide-gray-200">
               {alternatives.map((alternative) => (
                 <tr key={alternative.id}>
                   <td className="px-6 py-4 whitespace-nowrap">
                   <Link 
                      to={`/alternatives/${alternative.id}`}
                      className="text-primary-600 hover:text-primary-800"
                  >
                    {alternative.title}
                    </Link>
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.replaces}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.category}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.approved ? (
                       <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                         Genehmigt
                       </span>
                     ) : (
                       <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                         Ausstehend
                       </span>
                     )}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.upvotes}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                     <div className="flex justify-end space-x-2">
                       {alternative.approved ? (
                         <Button 
                           variant="danger" 
                           onClick={() => handleApprove(alternative.id, false)}
                           className="text-xs py-1 px-2"
                         >
                           Ablehnen
                         </Button>
                       ) : (
                         <Button 
                           onClick={() => handleApprove(alternative.id, true)}
                           className="text-xs py-1 px-2"
                         >
                           Genehmigen
                         </Button>
                       )}
                       <Button 
                         variant="danger" 
                         onClick={() => handleDelete(alternative.id)}
                         className="text-xs py-1 px-2"
                       >
                         Löschen
                       </Button>
                     </div>
                   </td>
                 </tr>
               ))}
             </tbody>
           </table>
         </div>
       )}
       
       <div className="px-6 py-4 border-t border-gray-200 flex justify-between">
         <Button
           variant="secondary"
           onClick={handlePreviousPage}
           disabled={page === 1}
         >
           Vorherige Seite
         </Button>
         <Button
           variant="secondary"
           onClick={handleNextPage}
           disabled={page === totalPages}
         >
           Nächste Seite
         </Button>
       </div>
     </div>
   </div>
 );
};

export default AdminAlternatives;
