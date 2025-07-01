import React from 'react';

const ProductForm = ({ data, onChange, onNext }) => {
  const handleChange = (field, value) => {
    onChange({ [field]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onNext();
  };

  return (
    <form onSubmit={handleSubmit} className="form-section">
      <h2>Product Information</h2>
      
      <div className="form-group">
        <label htmlFor="productName">Product Name *</label>
        <input
          id="productName"
          type="text"
          value={data.productName}
          onChange={(e) => handleChange('productName', e.target.value)}
          placeholder="Enter your product name"
          required
        />
      </div>

      <div className="form-group">
        <label htmlFor="category">Category</label>
        <select
          id="category"
          value={data.category}
          onChange={(e) => handleChange('category', e.target.value)}
        >
          <option value="saas">SaaS</option>
          <option value="ecommerce">E-commerce</option>
          <option value="mobile-app">Mobile App</option>
          <option value="hardware">Hardware</option>
          <option value="service">Service</option>
          <option value="fintech">FinTech</option>
          <option value="healthtech">HealthTech</option>
          <option value="edtech">EdTech</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="targetMarket">Target Market</label>
        <input
          id="targetMarket"
          type="text"
          value={data.targetMarket}
          onChange={(e) => handleChange('targetMarket', e.target.value)}
          placeholder="e.g., SMB, Enterprise, B2C consumers"
        />
      </div>

      <div className="form-group">
        <label htmlFor="pricePoint">Price Point ($)</label>
        <input
          id="pricePoint"
          type="number"
          value={data.pricePoint}
          onChange={(e) => handleChange('pricePoint', parseFloat(e.target.value) || 0)}
          placeholder="Monthly/Annual pricing"
        />
      </div>

      <div className="form-group">
        <label htmlFor="uniqueValueProp">Unique Value Proposition</label>
        <textarea
          id="uniqueValueProp"
          value={data.uniqueValueProp}
          onChange={(e) => handleChange('uniqueValueProp', e.target.value)}
          placeholder="What makes your product unique?"
          rows="3"
        />
      </div>

      <div className="form-group">
        <label htmlFor="developmentStage">Development Stage</label>
        <select
          id="developmentStage"
          value={data.developmentStage}
          onChange={(e) => handleChange('developmentStage', e.target.value)}
        >
          <option value="concept">Concept</option>
          <option value="prototype">Prototype</option>
          <option value="mvp">MVP</option>
          <option value="beta">Beta</option>
          <option value="launched">Launched</option>
        </select>
      </div>

      <div className="form-actions">
        <div></div>
        <button type="submit" className="btn btn-primary">
          Next: Market Data →
        </button>
      </div>
    </form>
  );
};

export default ProductForm