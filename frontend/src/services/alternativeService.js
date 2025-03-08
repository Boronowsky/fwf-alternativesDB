import apiClient from './apiService';

export const getAlternatives = async (params = {}) => {
  try {
    return await apiClient.get('/alternatives', { params });
  } catch (error) {
    console.error('Error fetching alternatives:', error);
    throw error;
  }
};

export const getLatestAlternatives = async (limit = 6) => {
  try {
    return await apiClient.get('/alternatives/latest', { params: { limit } });
  } catch (error) {
    console.error('Error fetching latest alternatives:', error);
    throw error;
  }
};

export const getAlternativeById = async (id) => {
  try {
    console.log('Fetching alternative with ID:', id);
    const response = await apiClient.get(`/alternatives/${id}`);
    console.log('API response:', response);
    return response;
  } catch (error) {
    console.error(`Error fetching alternative with ID ${id}:`, error);
    throw error;
  }
};

export const createAlternative = async (alternativeData) => {
  try {
    return await apiClient.post('/alternatives', alternativeData);
  } catch (error) {
    console.error('Error creating alternative:', error);
    throw error;
  }
};

export const updateAlternative = async (id, alternativeData) => {
  try {
    return await apiClient.put(`/alternatives/${id}`, alternativeData);
  } catch (error) {
    console.error('Error updating alternative:', error);
    throw error;
  }
};

export const deleteAlternative = async (id) => {
  try {
    return await apiClient.delete(`/alternatives/${id}`);
  } catch (error) {
    console.error('Error deleting alternative:', error);
    throw error;
  }
};

export const upvoteAlternative = async (id) => {
  try {
    return await apiClient.post(`/alternatives/${id}/vote`, { type: 'upvote' });
  } catch (error) {
    console.error('Error upvoting alternative:', error);
    throw error;
  }
};

export const downvoteAlternative = async (id) => {
  try {
    return await apiClient.post(`/alternatives/${id}/vote`, { type: 'downvote' });
  } catch (error) {
    console.error('Error downvoting alternative:', error);
    throw error;
  }
};

export const addComment = async (id, content) => {
  try {
    return await apiClient.post(`/alternatives/${id}/comments`, { content });
  } catch (error) {
    console.error('Error adding comment:', error);
    throw error;
  }
};

export const getComments = async (id) => {
  try {
    return await apiClient.get(`/alternatives/${id}/comments`);
  } catch (error) {
    console.error('Error fetching comments:', error);
    throw error;
  }
};

export const checkIfAlternativeExists = async (params) => {
  try {
    return await apiClient.get('/alternatives/check', { params });
  } catch (error) {
    console.error('Error checking if alternative exists:', error);
    throw error;
  }
};
