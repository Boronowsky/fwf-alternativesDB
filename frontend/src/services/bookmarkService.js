import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8100/api';

const getAuthHeader = () => {
  const token = localStorage.getItem('token');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

export const getUserBookmarks = async () => {
  const response = await axios.get(`${API_URL}/bookmarks`, {
    headers: getAuthHeader()
  });
  return response.data;
};

export const addBookmark = async (alternativeId) => {
  const response = await axios.post(
    `${API_URL}/bookmarks`,
    { alternativeId },
    { headers: getAuthHeader() }
  );
  return response.data;
};

export const removeBookmark = async (alternativeId) => {
  const response = await axios.delete(`${API_URL}/bookmarks/${alternativeId}`, {
    headers: getAuthHeader()
  });
  return response.data;
};

export const checkBookmark = async (alternativeId) => {
  const response = await axios.get(`${API_URL}/bookmarks/check/${alternativeId}`, {
    headers: getAuthHeader()
  });
  return response.data;
};
