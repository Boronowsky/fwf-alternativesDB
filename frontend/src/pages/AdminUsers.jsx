import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import Button from '../components/Button';
import Loading from '../components/Loading';
import Input from '../components/Input';
import { getUsers, updateUserAdminStatus, resetUserPassword, deleteUser } from '../services/adminService';

const AdminUsers = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Modal-State
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState(null);
  const [newPassword, setNewPassword] = useState('');
  const [passwordUpdateSuccess, setPasswordUpdateSuccess] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, [currentPage, searchTerm]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const data = await getUsers({ 
        page: currentPage, 
        limit: 10,
        search: searchTerm
      });
      setUsers(data.users);
      setTotalPages(data.pages);
      setLoading(false);
    } catch (err) {
      setError('Fehler beim Laden der Benutzer');
      setLoading(false);
    }
  };

  const handleToggleAdminStatus = async (userId, isCurrentlyAdmin) => {
    try {
      await updateUserAdminStatus(userId, !isCurrentlyAdmin);
      // Aktualisiere den Benutzer in der lokalen Zustandsliste
      setUsers(users.map(user => 
        user.id === userId ? { ...user, isAdmin: !isCurrentlyAdmin } : user
      ));
    } catch (err) {
      setError('Fehler beim Aktualisieren des Admin-Status');
    }
  };

  const openPasswordModal = (userId) => {
    setSelectedUserId(userId);
    setNewPassword('');
    setPasswordUpdateSuccess(false);
    setShowPasswordModal(true);
  };

  const closePasswordModal = () => {
    setShowPasswordModal(false);
    setSelectedUserId(null);
    setNewPassword('');
  };

  const handlePasswordChange = async (e) => {
    e.preventDefault();
    
    if (!newPassword) {
      setError('Bitte geben Sie ein neues Passwort ein');
      return;
    }
    
    try {
      await resetUserPassword(selectedUserId, newPassword);
      setPasswordUpdateSuccess(true);
      setTimeout(() => {
        closePasswordModal();
      }, 2000);
    } catch (err) {
      setError('Fehler beim Ändern des Passworts');
    }
  };

  const handleDeleteUser = async (userId) => {
    if (window.confirm('Möchten Sie diesen Benutzer wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.')) {
      try {
        await deleteUser(userId);
        // Benutzer aus der lokalen Liste entfernen
        setUsers(users.filter(user => user.id !== userId));
      } catch (err) {
        setError('Fehler beim Löschen des Benutzers');
      }
    }
  };

  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1); // Zurück zur ersten Seite bei neuer Suche
    fetchUsers();
  };

  const handlePageChange = (newPage) => {
    if (newPage > 0 && newPage <= totalPages) {
      setCurrentPage(newPage);
    }
  };

  if (loading) return <Loading />;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-4">Benutzerverwaltung</h1>
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex justify-between items-center mb-4">
            <div>
              <form onSubmit={handleSearch} className="flex">
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Suche nach Benutzername oder E-Mail"
                  className="input-field max-w-xs"
                />
                <Button type="submit" className="ml-2">Suchen</Button>
              </form>
            </div>
            <Link to="/admin" className="text-primary-600 hover:text-primary-700">
              Zurück zum Dashboard
            </Link>
          </div>

          {error && (
            <div className="bg-red-50 text-red-700 p-3 rounded mb-4">
              {error}
            </div>
          )}

          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Benutzername
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    E-Mail
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Registriert am
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Admin
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Aktionen
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {users.length > 0 ? (
                  users.map((user) => (
                    <tr key={user.id}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{user.username}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">{user.email}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">
                          {new Date(user.createdAt).toLocaleDateString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          user.isAdmin 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-gray-100 text-gray-800'
                        }`}>
                          {user.isAdmin ? 'Ja' : 'Nein'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex space-x-2">
                          <Button
                            onClick={() => handleToggleAdminStatus(user.id, user.isAdmin)}
                            variant={user.isAdmin ? 'secondary' : 'primary'}
                            className="text-xs"
                          >
                            {user.isAdmin ? 'Admin-Rechte entziehen' : 'Zum Admin machen'}
                          </Button>
                          <Button
                            onClick={() => openPasswordModal(user.id)}
                            variant="secondary"
                            className="text-xs"
                          >
                            Passwort ändern
                          </Button>
                          <Button
                            onClick={() => handleDeleteUser(user.id)}
                            variant="danger"
                            className="text-xs"
                          >
                            Löschen
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="5" className="px-6 py-4 text-center text-gray-500">
                      Keine Benutzer gefunden
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex justify-between items-center mt-4">
              <Button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                variant="secondary"
              >
                Zurück
              </Button>
              <span className="text-sm text-gray-700">
                Seite {currentPage} von {totalPages}
              </span>
              <Button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                variant="secondary"
              >
                Weiter
              </Button>
            </div>
          )}
        </div>
      </div>

      {/* Password Change Modal */}
      {showPasswordModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Passwort ändern</h3>
            
            {passwordUpdateSuccess ? (
              <div className="bg-green-50 text-green-700 p-3 rounded mb-4">
                Passwort wurde erfolgreich geändert!
              </div>
            ) : (
              <form onSubmit={handlePasswordChange}>
                <Input
                  label="Neues Passwort"
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  className="mb-4"
                />
                
                <div className="flex justify-end space-x-2">
                  <Button 
                    type="button" 
                    variant="secondary" 
                    onClick={closePasswordModal}
                  >
                    Abbrechen
                  </Button>
                  <Button 
                    type="submit" 
                    variant="primary"
                  >
                    Passwort ändern
                  </Button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminUsers;