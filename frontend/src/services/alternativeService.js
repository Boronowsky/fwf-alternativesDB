import apiClient from './apiService';

export const getAlternatives = async (params = {}) => {
  return await apiClient.get('/alternatives', { params });
};

export const getLatestAlternatives = async (limit = 6) => {
  return await apiClient.get('/alternatives/latest', { params: { limit } });
};

export const getAlternativeById = async (id) => {
  return await apiClient.get(`/alternatives/${id}`);
};

export const createAlternative = async (alternativeData) => {
  return await apiClient.post('/alternatives', alternativeData);
};

export const updateAlternative = async (id, alternativeData) => {
  return await apiClient.put(`/alternatives/${id}`, alternativeData);
};

export const deleteAlternative = async (id) => {
  return await apiClient.delete(`/alternatives/${id}`);
};

export const upvoteAlternative = async (id) => {
  return await apiClient.post(`/alternatives/${id}/upvote`);
};

export const downvoteAlternative = async (id) => {
  return await apiClient.post(`/alternatives/${id}/downvote`);
};

export const addComment = async (id, content) => {
  return await apiClient.post(`/alternatives/${id}/comments`, { content });
};

export const getComments = async (id) => {
  return await apiClient.get(`/alternatives/${id}/comments`);
};

export const checkIfAlternativeExists = async (name) => {
  return await apiClient.get('/alternatives/check', { params: { name } });
};
