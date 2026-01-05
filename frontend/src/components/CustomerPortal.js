import React, { useState, useEffect } from 'react';
import './CustomerPortal.css';


const CustomerPortal = ({ onLogout, onShowLogin, user }) => {
  const [cars, setCars] = useState([]);
  
  const [searchFilters, setSearchFilters] = useState({
    minPrice: '',
    maxPrice: '',
    fuel: '',
    brand: ''
  });
  
  const [showPurchaseModal, setShowPurchaseModal] = useState(false);
  const [selectedCar, setSelectedCar] = useState(null);

  // Fetch car statuses dynamically
  useEffect(() => {
    fetch("http://localhost:3001/cars")
      .then(res => res.json())
      .then(data => {
        if (Array.isArray(data)) {
          setCars(data);
        } else {
          console.error("Expected array from /cars, got:", data);
          setCars([]); // fallback
        }
      })
      .catch(err => {
        console.error(err);
        setCars([]); // fallback
      });
  }, []);

  const [showSuccessMessage, setShowSuccessMessage] = useState(false);

  const handlePurchaseSubmit = (purchaseData) => {
    console.log('Purchase submitted:', purchaseData);
    setShowPurchaseModal(false);
    setShowSuccessMessage(true);
    
    // Auto hide after 4 seconds
    setTimeout(() => {
      setShowSuccessMessage(false);
    }, 4000);
  };

  const handleBuyCar = (car) => {
    setSelectedCar(car);
    setShowPurchaseModal(true);
  };

  const filteredCars = cars.filter(car => {
    if (searchFilters.minPrice && car.price < Number(searchFilters.minPrice)) return false;
    if (searchFilters.maxPrice && car.price > Number(searchFilters.maxPrice)) return false;
    if (searchFilters.fuel && car.fuel !== searchFilters.fuel) return false;

    if (
      searchFilters.brand &&
      (!car.brand || !car.brand.toLowerCase().includes(searchFilters.brand.toLowerCase()))
    ) return false;

    return true; // backend already filters available
  });


  return (
    <div className="car-eshop-app">
      {/* Header */}
      <header className="eshop-header">
        <div className="header-content">
          <div className="logo-section">
            <div className="logo-container">
              <img src="/eshop_logo.png" alt="Uniwa e-Shop Logo" className="eshop-logo" />
              <h1>UNIWA Car e-Shop</h1>
            </div>
            <p>Καλώς ήρθατε στην αντιπροσωπεία μας</p>
          </div>
          <div className="header-actions">
            {user ? (
              <div className="user-info">
                <span>Καλώς ήρθατε, {user.role}</span>
                <button className="btn-secondary" onClick={onLogout}>Αποσύνδεση</button>
                <button className="btn-secondary cart-btn">🛒 Καλάθι</button>
              </div>
            ) : (
              <div className="auth-actions">
                <button className="btn-primary" onClick={onShowLogin}>Σύνδεση</button>
                <button className="btn-secondary cart-btn">🛒 Καλάθι</button>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Search Section */}
      <section className="search-section">
        <div className="search-container">
          <h2>Βρείτε το ιδανικό Αυτοκίνητο για εσάς</h2>
          <div className="search-form">
            <div className="search-field">
              <label>Min Price</label>
              <input 
                type="number" 
                value={searchFilters.minPrice}
                onChange={(e) => setSearchFilters({...searchFilters, minPrice: e.target.value})}
              />
            </div>
            <div className="search-field">
              <label>Max Price</label>
              <input 
                type="number" 
                value={searchFilters.maxPrice}
                onChange={(e) => setSearchFilters({...searchFilters, maxPrice: e.target.value})}
              />
            </div>
            <div className="search-field">
              <label>Fuel Type</label>
              <select 
                value={searchFilters.fuel}
                onChange={(e) => setSearchFilters({...searchFilters, fuel: e.target.value})}
              >
                <option value="">All Fuels</option>
                <option value="petrol">Petrol</option>
                <option value="diesel">Diesel</option>
                <option value="hybrid">Hybrid</option>
                <option value="electric">Electric</option>
              </select>
            </div>
            <div className="search-field">
              <label>Brand</label>
              <input 
                type="text" 
                value={searchFilters.brand}
                onChange={(e) => setSearchFilters({...searchFilters, brand: e.target.value})}
              />
            </div>
            <button className="btn-primary search-btn">Αναζήτηση</button>
          </div>
        </div>
      </section>

      {/* Cars Section */}
      <section className="cars-section">
        <div className="cars-container">
          <h2>Διαθέσιμα Αυτοκίνητα</h2>
          <div className="cars-list">
            {filteredCars.map(car => (
              <div key={car.id} className="car-card">
                <img 
                  src={car.image ?? '/placeholder.png'} 
                  alt={`${car.brand ?? ''} ${car.model ?? ''}`} 
                />
                <div>Status: {car.status}</div>
                <div>Price: €{car.price}</div>
                <button 
                  className="btn-primary"
                  onClick={() => handleBuyCar(car)}
                >
                  Buy Now
                </button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Purchase Modal */}
      {showPurchaseModal && selectedCar && (
        <PurchaseModal 
          car={selectedCar}
          onClose={() => setShowPurchaseModal(false)}
          onSubmit={handlePurchaseSubmit}
        />
      )}

      {/* Success Message */}
      {showSuccessMessage && (
        <div className="success-notification">
          <div className="success-content">
            <div className="success-icon">✓</div>
            <div className="success-text">
              <h3>Αγορά Επιτυχής!</h3>
              <p>Θα λάβετε email επιβεβαίωσης σύντομα.</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

// Purchase Modal Component
const PurchaseModal = ({ car, onClose, onSubmit }) => {
  const [purchaseData, setPurchaseData] = useState({
    name: '',
    email: '',
    phone: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit({ ...purchaseData, car });
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content purchase-modal">
        <div className="modal-header">
          <h3>Αγορά Αυτοκινήτου {car.brand} {car.model}</h3>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>
        <form onSubmit={handleSubmit} className="purchase-form">
          <div className="form-row">
            <div className="form-group">
              <label>Ποσότητα</label>
              <input 
                type="number" 
                min="1" 
                value={purchaseData.quantity || 1}
                onChange={(e) => setPurchaseData({...purchaseData, quantity: e.target.value})}
              />
            </div>
          </div>
          <div className="form-group">
            <label>Όνομα</label>
            <input 
              type="text" 
              required
              value={purchaseData.name}
              onChange={(e) => setPurchaseData({...purchaseData, name: e.target.value})}
            />
          </div>
          <div className="form-group">
            <label>Email</label>
            <input 
              type="email" 
              required
              value={purchaseData.email}
              onChange={(e) => setPurchaseData({...purchaseData, email: e.target.value})}
            />
          </div>
          <div className="form-group">
            <label>Τηλέφωνο</label>
            <input 
              type="tel" 
              required
              value={purchaseData.phone}
              onChange={(e) => setPurchaseData({...purchaseData, phone: e.target.value})}
            />
          </div>
          <div className="purchase-summary">
            <h4>Σύνοψη Αγοράς</h4>
            <div className="summary-total">
              <span>Σύνολο</span>
              <span>€{car.price}</span>
            </div>
          </div>
          <div className="modal-actions">
            <button type="button" className="btn-secondary" onClick={onClose}>
              Ακύρωση
            </button>
            <button type="submit" className="btn-primary">
              Επιβεβαίωση Κράτησης
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CustomerPortal;
