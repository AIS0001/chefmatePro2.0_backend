/**
 * SUPER ADMIN DASHBOARD - REACT COMPONENT
 * Main dashboard for managing all shops
 */

import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './SuperAdminDashboard.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:4402/api';

const SuperAdminDashboard = () => {
  const [stats, setStats] = useState(null);
  const [shops, setShops] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedShop, setSelectedShop] = useState(null);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [page, setPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');

  const token = localStorage.getItem('token');

  // Fetch dashboard statistics
  useEffect(() => {
    fetchDashboardStats();
  }, []);

  // Fetch shops list
  useEffect(() => {
    fetchShops();
  }, [page, searchTerm]);

  const fetchDashboardStats = async () => {
    try {
      const response = await axios.get(`${API_URL}/super-admin/dashboard/stats`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setStats(response.data.data);
    } catch (err) {
      console.error('Failed to fetch stats:', err);
      setError('Failed to load dashboard statistics');
    }
  };

  const fetchShops = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/super-admin/shops`, {
        params: { page, limit: 10, search: searchTerm },
        headers: { Authorization: `Bearer ${token}` }
      });
      setShops(response.data.data);
      setError(null);
    } catch (err) {
      console.error('Failed to fetch shops:', err);
      setError('Failed to load shops');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateShop = async (formData) => {
    try {
      const response = await axios.post(`${API_URL}/super-admin/shops`, formData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert('Shop created successfully!');
      setShowCreateForm(false);
      fetchShops();
      fetchDashboardStats();
    } catch (err) {
      console.error('Failed to create shop:', err);
      alert('Failed to create shop: ' + (err.response?.data?.error || err.message));
    }
  };

  const handleToggleShopStatus = async (shopId, isActive) => {
    try {
      await axios.patch(`${API_URL}/super-admin/shops/${shopId}/status`, 
        { is_active: !isActive },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      alert(`Shop ${!isActive ? 'activated' : 'deactivated'} successfully!`);
      fetchShops();
    } catch (err) {
      console.error('Failed to toggle status:', err);
      alert('Failed to update shop status');
    }
  };

  const handleViewShopDetails = async (shopId) => {
    try {
      const response = await axios.get(`${API_URL}/super-admin/shops/${shopId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setSelectedShop(response.data.data);
    } catch (err) {
      console.error('Failed to fetch shop details:', err);
      alert('Failed to load shop details');
    }
  };

  return (
    <div className="super-admin-dashboard">
      <header className="dashboard-header">
        <h1>🏪 ChefMate SaaS - Super Admin Dashboard</h1>
        <p>Manage all shops, subscriptions, and platform analytics</p>
      </header>

      {error && <div className="error-message">{error}</div>}

      {/* Statistics Cards */}
      {stats && (
        <section className="stats-section">
          <div className="stats-grid">
            <div className="stat-card">
              <div className="stat-icon">🏢</div>
              <div className="stat-content">
                <h3>Total Shops</h3>
                <p className="stat-value">{stats.totalShops.count}</p>
              </div>
            </div>

            <div className="stat-card">
              <div className="stat-icon">✅</div>
              <div className="stat-content">
                <h3>Active Subscriptions</h3>
                <p className="stat-value">{stats.activeSubscriptions.count}</p>
              </div>
            </div>

            <div className="stat-card">
              <div className="stat-icon">💰</div>
              <div className="stat-content">
                <h3>Total Revenue</h3>
                <p className="stat-value">
                  ₹{stats.totalRevenue.total ? stats.totalRevenue.total.toLocaleString() : '0'}
                </p>
              </div>
            </div>

            <div className="stat-card">
              <div className="stat-icon">⏰</div>
              <div className="stat-content">
                <h3>Pending Payments</h3>
                <p className="stat-value">{stats.pendingPayments.count}</p>
              </div>
            </div>
          </div>
        </section>
      )}

      {/* Shops Management Section */}
      <section className="shops-section">
        <div className="section-header">
          <h2>All Shops</h2>
          <button 
            className="btn btn-primary"
            onClick={() => setShowCreateForm(true)}
          >
            + Create New Shop
          </button>
        </div>

        {/* Search Bar */}
        <div className="search-bar">
          <input
            type="text"
            placeholder="Search by shop name or code..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setPage(1);
            }}
          />
        </div>

        {/* Create Shop Form Modal */}
        {showCreateForm && (
          <CreateShopForm 
            onSubmit={handleCreateShop}
            onCancel={() => setShowCreateForm(false)}
          />
        )}

        {/* Shops Table */}
        {loading ? (
          <div className="loader">Loading shops...</div>
        ) : shops.length === 0 ? (
          <div className="no-data">No shops found</div>
        ) : (
          <div className="table-responsive">
            <table className="shops-table">
              <thead>
                <tr>
                  <th>Shop Name</th>
                  <th>Code</th>
                  <th>Status</th>
                  <th>Subscription</th>
                  <th>Plan</th>
                  <th>Users</th>
                  <th>Created</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {shops.map(shop => (
                  <tr key={shop.id} className={`row-${shop.subscription_status}`}>
                    <td className="shop-name">{shop.name}</td>
                    <td>{shop.shop_code}</td>
                    <td>
                      <span className={`badge status-${shop.is_active ? 'active' : 'inactive'}`}>
                        {shop.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td>
                      <span className={`badge subscription-${shop.subscription_status}`}>
                        {shop.subscription_status.charAt(0).toUpperCase() + shop.subscription_status.slice(1)}
                      </span>
                    </td>
                    <td>{shop.plan_name || 'N/A'}</td>
                    <td>{shop.total_users}</td>
                    <td>{new Date(shop.created_at).toLocaleDateString()}</td>
                    <td className="actions">
                      <button 
                        className="btn btn-sm btn-info"
                        onClick={() => handleViewShopDetails(shop.id)}
                      >
                        View
                      </button>
                      <button 
                        className="btn btn-sm btn-warning"
                        onClick={() => handleToggleShopStatus(shop.id, shop.is_active)}
                      >
                        {shop.is_active ? 'Deactivate' : 'Activate'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Shop Details Modal */}
        {selectedShop && (
          <ShopDetailsModal 
            shop={selectedShop}
            onClose={() => setSelectedShop(null)}
          />
        )}
      </section>
    </div>
  );
};

// Create Shop Form Component
const CreateShopForm = ({ onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    shop_code: '',
    tax_id: '',
    phone_number: '',
    email: '',
    address: '',
    city: '',
    state: '',
    zip_code: '',
    country: '',
    website: '',
    contact_person: '',
    contact_person_phone: '',
    subscription_plan_id: 1,
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.name || !formData.shop_code || !formData.tax_id || !formData.email) {
      alert('Please fill in all required fields');
      return;
    }
    onSubmit(formData);
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content create-shop-modal">
        <h2>Create New Shop</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label>Shop Name *</label>
              <input type="text" name="name" value={formData.name} onChange={handleChange} required />
            </div>
            <div className="form-group">
              <label>Shop Code *</label>
              <input type="text" name="shop_code" value={formData.shop_code} onChange={handleChange} required />
            </div>
            <div className="form-group">
              <label>Tax ID *</label>
              <input type="text" name="tax_id" value={formData.tax_id} onChange={handleChange} required />
            </div>
            <div className="form-group">
              <label>Email *</label>
              <input type="email" name="email" value={formData.email} onChange={handleChange} required />
            </div>
            <div className="form-group">
              <label>Phone Number *</label>
              <input type="tel" name="phone_number" value={formData.phone_number} onChange={handleChange} required />
            </div>
            <div className="form-group">
              <label>Address *</label>
              <input type="text" name="address" value={formData.address} onChange={handleChange} required />
            </div>
            <div className="form-group">
              <label>City</label>
              <input type="text" name="city" value={formData.city} onChange={handleChange} />
            </div>
            <div className="form-group">
              <label>State</label>
              <input type="text" name="state" value={formData.state} onChange={handleChange} />
            </div>
            <div className="form-group">
              <label>Zip Code</label>
              <input type="text" name="zip_code" value={formData.zip_code} onChange={handleChange} />
            </div>
            <div className="form-group">
              <label>Country</label>
              <input type="text" name="country" value={formData.country} onChange={handleChange} />
            </div>
            <div className="form-group">
              <label>Website</label>
              <input type="url" name="website" value={formData.website} onChange={handleChange} />
            </div>
            <div className="form-group">
              <label>Subscription Plan</label>
              <select name="subscription_plan_id" value={formData.subscription_plan_id} onChange={handleChange}>
                <option value={1}>Starter</option>
                <option value={2}>Professional</option>
                <option value={3}>Enterprise</option>
              </select>
            </div>
          </div>

          <div className="form-actions">
            <button type="button" className="btn btn-secondary" onClick={onCancel}>Cancel</button>
            <button type="submit" className="btn btn-primary">Create Shop</button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Shop Details Modal Component
const ShopDetailsModal = ({ shop, onClose }) => {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content shop-details-modal" onClick={(e) => e.stopPropagation()}>
        <button className="close-btn" onClick={onClose}>×</button>
        <h2>Shop Details</h2>
        
        <div className="details-grid">
          <div className="detail-item">
            <label>Shop Name</label>
            <p>{shop.name}</p>
          </div>
          <div className="detail-item">
            <label>Shop Code</label>
            <p>{shop.shop_code}</p>
          </div>
          <div className="detail-item">
            <label>Tax ID</label>
            <p>{shop.tax_id}</p>
          </div>
          <div className="detail-item">
            <label>Email</label>
            <p>{shop.email}</p>
          </div>
          <div className="detail-item">
            <label>Phone</label>
            <p>{shop.phone_number}</p>
          </div>
          <div className="detail-item">
            <label>Location</label>
            <p>{shop.city}, {shop.state}, {shop.country}</p>
          </div>
          <div className="detail-item">
            <label>Subscription Status</label>
            <p><span className={`badge subscription-${shop.subscription_status}`}>{shop.subscription_status}</span></p>
          </div>
          <div className="detail-item">
            <label>Plan</label>
            <p>{shop.plan_name}</p>
          </div>
          <div className="detail-item">
            <label>Total Users</label>
            <p>{shop.total_users}</p>
          </div>
          <div className="detail-item">
            <label>Created At</label>
            <p>{new Date(shop.created_at).toLocaleString()}</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SuperAdminDashboard;
