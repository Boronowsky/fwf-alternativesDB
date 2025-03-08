import axios from 'axios';

const API_URL = window.location.hostname === 'localhost' 
  ? `http://localhost:8181/api`
  : `http://${window.location.hostname}:8181/api`;
  
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request-Interceptor für das Hinzufügen des Auth-Tokens
apiClient.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// Response-Interceptor für einheitliche Fehlerbehandlung
apiClient.interceptors.response.use(
  response => response.data,
  error => {
    // Wenn Token abgelaufen oder ungültig ist
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
