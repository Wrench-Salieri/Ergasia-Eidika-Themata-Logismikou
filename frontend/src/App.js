
import React, { useState, useEffect } from 'react';
import './App.css';
import Login from './components/Login';
import ManagerPortal from './components/ManagerPortal';
import AdminPortal from './components/AdminPortal';
import CustomerPortal from './components/CustomerPortal';
import PaymentPortal from './components/PaymentManagement';

function App() {
  const [user, setUser] = useState(null);
  const [showLogin, setShowLogin] = useState(false);
  const [currentPortal, setCurrentPortal] = useState('customer'); // default portal

  useEffect(() => {
    const savedUser = localStorage.getItem('user');
    const savedPortal = localStorage.getItem('currentPortal');
    if (savedUser) setUser(JSON.parse(savedUser));
    if (savedPortal) setCurrentPortal(savedPortal);
  }, []);

  useEffect(() => {
    if (user) localStorage.setItem('user', JSON.stringify(user));
    else localStorage.removeItem('user');
  }, [user]);

  useEffect(() => {
    localStorage.setItem('currentPortal', currentPortal);
  }, [currentPortal]);

  const handleLogout = () => {
    setUser(null);
    setCurrentPortal('customer');
    localStorage.removeItem('user');
    localStorage.removeItem('currentPortal');
  };

  const handlePortalSwitch = (portal) => {
    setCurrentPortal(portal);
  };

  return (
    <div className="App">
      {showLogin ? (
        <Login onLogin={setUser} onCancel={() => setShowLogin(false)} />
      ) : user ? (
        <>
          {currentPortal === 'admin' && (
            <AdminPortal user={user} onLogout={handleLogout} onSwitchPortal={handlePortalSwitch} />
          )}
          {currentPortal === 'payment' && (
            <PaymentPortal user={user} onLogout={handleLogout} />
          )}
          {currentPortal === 'customer' && (
            <CustomerPortal 
              user={user} 
              onLogout={handleLogout} 
              onShowLogin={() => setShowLogin(true)}
            />
          )}
        </>
      ) : (
        <CustomerPortal onShowLogin={() => setShowLogin(true)} />
      )}
    </div>
  );
}


export default App;
