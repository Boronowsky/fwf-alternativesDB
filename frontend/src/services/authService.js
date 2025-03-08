import apiClient from './apiService';

export const login = async (email, password) => {
  return await apiClient.post('/auth/login', { email, password });
};

export const register = async (username, email, password) => {
  return await apiClient.post('/auth/register', { username, email, password });
};

export const getProfile = async () => {
  return await apiClient.get('/auth/profile');
};

export const updateProfile = async (userData) => {
  return await apiClient.put('/auth/profile', userData);
};

export const changePassword = async (oldPassword, newPassword) => {
  return await apiClient.put('/auth/password', { oldPassword, newPassword });
};
