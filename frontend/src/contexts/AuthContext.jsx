import React, { createContext, useState, useEffect } from 'react';
import jwt_decode from 'jwt-decode';
import { login as apiLogin, register as apiRegister } from '../services/authService';

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Beim Laden der App prüfen, ob ein Token im localStorage existiert
    const token = localStorage.getItem('token');
    if (token) {
      try {
        // Token dekodieren und überprüfen
        const decoded = jwt_decode(token);
        const currentTime = Date.now() / 1000;
        
        if (decoded.exp > currentTime) {
          setUser({
            id: decoded.id,
            username: decoded.username,
            email: decoded.email,
            isAdmin: decoded.isAdmin || false
          });
        } else {
          // Token ist abgelaufen
          localStorage.removeItem('token');
        }
      } catch (err) {
        localStorage.removeItem('token');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    const response = await apiLogin(email, password);
    const { token } = response;
    
    localStorage.setItem('token', token);
    const decoded = jwt_decode(token);
    
    setUser({
      id: decoded.id,
      username: decoded.username,
      email: decoded.email,
      isAdmin: decoded.isAdmin || false
    });
    
    return response;
  };

  const register = async (username, email, password) => {
    const response = await apiRegister(username, email, password);
    const { token } = response;
    
    localStorage.setItem('token', token);
    const decoded = jwt_decode(token);
    
    setUser({
      id: decoded.id,
      username: decoded.username,
      email: decoded.email,
      isAdmin: decoded.isAdmin || false
    });
    
    return response;
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider 
      value={{ 
        user, 
        login, 
        register, 
        logout,
        isAuthenticated: !!user,
        isLoading: loading
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
