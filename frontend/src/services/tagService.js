import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8100/api';

const getAuthHeader = () => {
  const token = localStorage.getItem('token');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

export const getAllTags = async () => {
  const response = await axios.get(`${API_URL}/tags`);
  return response.data;
};

export const createTag = async (tagData) => {
  const response = await axios.post(`${API_URL}/tags`, tagData, {
    headers: getAuthHeader()
  });
  return response.data;
};

export const updateTag = async (id, tagData) => {
  const response = await axios.put(`${API_URL}/tags/${id}`, tagData, {
    headers: getAuthHeader()
  });
  return response.data;
};

export const deleteTag = async (id) => {
  const response = await axios.delete(`${API_URL}/tags/${id}`, {
    headers: getAuthHeader()
  });
  return response.data;
};
