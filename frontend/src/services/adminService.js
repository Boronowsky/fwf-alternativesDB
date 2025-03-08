import apiClient from './apiService';

export const getDashboardStats = async () => {
  return await apiClient.get('/admin/dashboard');
};

export const getUsers = async (params = {}) => {
  return await apiClient.get('/admin/users', { params });
};

export const updateUserAdminStatus = async (userId, isAdmin) => {
  return await apiClient.put(`/admin/users/${userId}`, { isAdmin });
};

export const approveAlternative = async (alternativeId, approved) => {
  return await apiClient.put(`/admin/alternatives/${alternativeId}/approve`, { approved });
};

export const deleteAlternative = async (alternativeId) => {
  return await apiClient.delete(`/alternatives/${alternativeId}`);
};

// Zu adminService.js hinzufügen
export const resetUserPassword = async (userId, newPassword) => {
    return await apiClient.post(`/admin/users/${userId}/reset-password`, { 
      newPassword 
    });
  };
  
  export const deleteUser = async (userId) => {
    return await apiClient.delete(`/admin/users/${userId}`);
  };