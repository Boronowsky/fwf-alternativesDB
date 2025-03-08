import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import Alternatives from './pages/Alternatives';
import AlternativeDetail from './pages/AlternativeDetail';
import NewAlternative from './pages/NewAlternative';
import AdminDashboard from './pages/AdminDashboard';
import AdminAlternatives from './pages/AdminAlternatives';
import AdminUsers from './pages/AdminUsers'; 

function App() {
 return (
   <AuthProvider>
     <Router>
       <div className="flex flex-col min-h-screen">
         <Navbar />
         <main className="flex-grow">
           <Routes>
             <Route path="/" element={<Home />} />
             <Route path="/login" element={<Login />} />
             <Route path="/register" element={<Register />} />
             <Route path="/alternatives" element={<Alternatives />} />
             <Route path="/alternatives/:id" element={<AlternativeDetail />} />
             <Route path="/alternatives/new" element={<NewAlternative />} />
             <Route path="/admin" element={<AdminDashboard />} />
             <Route path="/admin/alternatives" element={<AdminAlternatives />} />
             <Route path="/admin/users" element={<AdminUsers />} />
           </Routes>
         </main>
         <Footer />
       </div>
     </Router>
   </AuthProvider>
 );
}

export default App;
