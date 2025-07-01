import React, { useState, useEffect } from 'react';
import './PerformancePredictor.css'; // Import the new CSS file

const API_BASE_URL = "http://localhost:5001";

const PerformancePredictor = () => {
  const [productId, setProductId] = useState('');
  const [products, setProducts] = useState([]);
  const [prediction, setPrediction] = useState(null);
  const [analytics, setAnalytics] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [apiStatus, setApiStatus] = useState(null);

  // Load products and check API health on component mount
  useEffect(() => {
    checkApiHealth();
    loadProducts();
  }, []);

  const checkApiHealth = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/health`);
      const data = await response.json();
      setApiStatus(data);
    } catch (err) {
      console.error('API health check failed:', err);
      setError('Unable to connect to API. Please ensure the Flask server is running on port 5001.');
    }
  };

  const loadProducts = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/products`);
      if (!response.ok) throw new Error('Failed to fetch products');
      
      const data = await response.json();
      setProducts(data.products || []);
    } catch (err) {
      console.error('Failed to load products:', err);
      // Don't set error here as it's not critical for the main functionality
    }
  };

  const loadAnalytics = async (productId) => {
    try {
      const response = await fetch(`${API_BASE_URL}/product_analytics/${productId}`);
      if (!response.ok) throw new Error('Failed to fetch analytics');
      
      const data = await response.json();
      setAnalytics(data);
    } catch (err) {
      console.error('Failed to load analytics:', err);
      // Analytics is optional, don't show error to user
    }
  };

  const handlePredict = async () => {
    if (!productId) {
      setError('Please enter a Product ID.');
      return;
    }
    
    setIsLoading(true);
    setError('');
    setPrediction(null);
    setAnalytics(null);

    try {
      const response = await fetch(`${API_BASE_URL}/predict_performance`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ product_id: parseInt(productId) }),
      });

      if (!response.ok) {
        // Try to parse error message from backend
        let errMsg = `API Error: ${response.statusText}`;
        try {
          const errData = await response.json();
          if (errData.error) errMsg = errData.error;
        } catch {}
        throw new Error(errMsg);
      }

      const result = await response.json();
      setPrediction(result);

      // Load additional analytics if prediction is successful
      await loadAnalytics(productId);

    } catch (err) {
      setError(err.message || "Failed to fetch prediction.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleProductSelect = (selectedProductId) => {
    setProductId(selectedProductId);
    if (selectedProductId) {
      // Auto-predict when product is selected from dropdown
      setTimeout(() => {
        const currentProductId = selectedProductId;
        setProductId(currentProductId);
        // Trigger prediction
        setIsLoading(true);
        setError('');
        setPrediction(null);
        setAnalytics(null);

        fetch(`${API_BASE_URL}/predict_performance`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ product_id: parseInt(currentProductId) }),
        })
        .then(response => {
          if (!response.ok) {
            return response.json().then(errData => {
              throw new Error(errData.error || `API Error: ${response.statusText}`);
            });
          }
          return response.json();
        })
        .then(result => {
          setPrediction(result);
          return loadAnalytics(currentProductId);
        })
        .catch(err => {
          setError(err.message || "Failed to fetch prediction.");
        })
        .finally(() => {
          setIsLoading(false);
        });
      }, 100);
    }
  };

  const reloadPredictions = async () => {
    try {
      setIsLoading(true);
      const response = await fetch(`${API_BASE_URL}/reload_predictions`, {
        method: 'POST'
      });
      
      if (!response.ok) throw new Error('Failed to reload predictions');
      
      // Reload products list
      await loadProducts();
      setError('');
      
      // Show success message briefly
      setError('Predictions reloaded successfully!');
      setTimeout(() => setError(''), 3000);
      
    } catch (err) {
      setError('Failed to reload predictions: ' + err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="performance-predictor-container">
      <div className="predictor-header">
        <h2>Product Performance Predictor</h2>
        <p>Enter a Product ID or select from the dropdown to forecast sales for the next month.</p>
        
        {/* API Status Indicator */}
        {apiStatus && (
          <div className={`api-status ${apiStatus.status === 'healthy' ? 'healthy' : 'unhealthy'}`}>
            <span className="status-dot"></span>
            API Status: {apiStatus.status}
            {apiStatus.predictions_loaded && <span className="predictions-badge">CSV Loaded</span>}
          </div>
        )}
      </div>

      <div className="predictor-form">
        {/* Product Dropdown */}
        {products.length > 0 && (
          <div className="product-selector">
            <select
              value={productId}
              onChange={(e) => handleProductSelect(e.target.value)}
              className="predictor-select"
              disabled={isLoading}
            >
              <option value="">Select a product...</option>
              {products.map((product) => (
                <option key={product.product_id} value={product.product_id}>
                  {product.product_name} (ID: {product.product_id})
                  {product.has_prediction_data ? ' ⭐' : ''}
                </option>
              ))}
            </select>
            <small className="helper-text">⭐ = Has prediction data available</small>
          </div>
        )}

        {/* Manual Input */}
        <div className="manual-input">
          <input
            id="productId"
            className="predictor-input"
            type="number"
            value={productId}
            onChange={(e) => setProductId(e.target.value)}
            placeholder="Or enter Product ID manually (e.g., 123)"
            onKeyDown={(e) => e.key === 'Enter' && handlePredict()}
            disabled={isLoading}
          />
          <button className="predictor-button" onClick={handlePredict} disabled={isLoading || !productId}>
            {isLoading ? 'Loading...' : 'Predict'}
          </button>
        </div>

        {/* Reload Button */}
        <button className="reload-button" onClick={reloadPredictions} disabled={isLoading}>
          🔄 Reload Predictions
        </button>
      </div>

      <div className="predictor-feedback">
        {isLoading && (
          <div className="loading-container">
            <div className="loading-spinner"></div>
            <p>Fetching prediction...</p>
          </div>
        )}
        
        {error && (
          <p className={`error-message ${error.includes('successfully') ? 'success-message' : ''}`}>
            {error}
          </p>
        )}
        
        {prediction && (
          <div className="prediction-result-card">
            <div className="prediction-header">
              <h3>Predicted Next Month Sales</h3>
              {prediction.prediction_source && (
                <span className="prediction-source">Source: {prediction.prediction_source}</span>
              )}
            </div>
            
            <div className="prediction-main">
              <span className="prediction-value">
                {Math.round(prediction.predicted_next_month_sales).toLocaleString()}
              </span>
              <div className="prediction-label">Units</div>
              <div className="confidence-score">
                Confidence: {Math.round(prediction.confidence_score * 100)}%
                <div className="confidence-bar">
                  <div 
                    className="confidence-fill" 
                    style={{ width: `${prediction.confidence_score * 100}%` }}
                  ></div>
                </div>
              </div>
            </div>

            {prediction.historical_data && Object.keys(prediction.historical_data).length > 0 && (
              <div className="historical-info">
                <strong>Historical Performance:</strong>
                <div className="historical-grid">
                  <div className="historical-item">
                    <span className="historical-label">Total Sales:</span>
                    <span className="historical-value">{prediction.historical_data.total_sales || 'N/A'}</span>
                  </div>
                  <div className="historical-item">
                    <span className="historical-label">Units Sold:</span>
                    <span className="historical-value">{prediction.historical_data.total_units_sold?.toLocaleString() || 'N/A'}</span>
                  </div>
                  <div className="historical-item">
                    <span className="historical-label">Revenue:</span>
                    <span className="historical-value">${prediction.historical_data.total_revenue?.toLocaleString() || 'N/A'}</span>
                  </div>
                  <div className="historical-item">
                    <span className="historical-label">Shop Diversity:</span>
                    <span className="historical-value">{prediction.historical_data.shop_diversity || 'N/A'}</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Additional Analytics */}
        {analytics && analytics.monthly_breakdown && (
          <div className="analytics-card">
            <h3>Monthly Sales Breakdown</h3>
            <div className="monthly-chart">
              {Object.entries(analytics.monthly_breakdown).map(([month, data]) => (
                <div key={month} className="month-bar">
                  <div className="month-label">M{month}</div>
                  <div className="bar-container">
                    <div 
                      className="bar" 
                      style={{ 
                        height: `${Math.min((data.units / Math.max(...Object.values(analytics.monthly_breakdown).map(d => d.units))) * 100, 100)}%` 
                      }}
                      title={`Month ${month}: ${data.units} units, $${data.revenue}`}
                    ></div>
                  </div>
                  <div className="month-value">{data.units}</div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Product Info */}
        {analytics && (
          <div className="product-info-card">
            <h3>Product Information</h3>
            <div className="product-details">
              <div className="detail-item">
                <span className="detail-label">Product Name:</span>
                <span className="detail-value">{analytics.product_name}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Category:</span>
                <span className="detail-value">{analytics.category}</span>
              </div>
              {analytics.avg_unit_price && (
                <div className="detail-item">
                  <span className="detail-label">Avg Price:</span>
                  <span className="detail-value">${analytics.avg_unit_price}</span>
                </div>
              )}
              {analytics.shops_selling && (
                <div className="detail-item">
                  <span className="detail-label">Shops Selling:</span>
                  <span className="detail-value">{analytics.shops_selling}</span>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default PerformancePredictor;