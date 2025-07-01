import React from 'react';

const MarketForm = ({ data, onChange, onNext, onPrev }) => {
  const handleChange = (field, value) => {
    onChange({ [field]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onNext();
  };

  return (
    <form onSubmit={handleSubmit} className="form-section">
      <h2>Market Analysis</h2>
      
      <div className="form-group">
        <label htmlFor="marketSize">Total Addressable Market (TAM) $</label>
        <input
          id="marketSize"
          type="number"
          value={data.marketSize}
          onChange={(e) => handleChange('marketSize', parseFloat(e.target.value) || 0)}
          placeholder="e.g., 1000000000 for $1B market"
        />
        <small>Enter the total market size in dollars</small>
      </div>

      <div className="form-group">
        <label htmlFor="growthRate">Market Growth Rate (%)</label>
        <input
          id="growthRate"
          type="number"
          value={data.growthRate}
          onChange={(e) => handleChange('growthRate', parseFloat(e.target.value) || 0)}
          placeholder="Annual growth percentage"
        />
      </div>

      <div className="form-group">
        <label htmlFor="competitionLevel">Competition Level</label>
        <select
          id="competitionLevel"
          value={data.competitionLevel}
          onChange={(e) => handleChange('competitionLevel', e.target.value)}
        >
          <option value="low">Low Competition</option>
          <option value="medium">Medium Competition</option>
          <option value="high">High Competition</option>
          <option value="saturated">Saturated Market</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="customerAcquisitionCost">Customer Acquisition Cost (CAC) $</label>
        <input
          id="customerAcquisitionCost"
          type="number"
          value={data.customerAcquisitionCost}
          onChange={(e) => handleChange('customerAcquisitionCost', parseFloat(e.target.value) || 0)}
          placeholder="Cost to acquire one customer"
        />
      </div>

      <div className="form-group">
        <label htmlFor="averageRevenuePerUser">Average Revenue Per User (ARPU) $</label>
        <input
          id="averageRevenuePerUser"
          type="number"
          value={data.averageRevenuePerUser}
          onChange={(e) => handleChange('averageRevenuePerUser', parseFloat(e.target.value) || 0)}
          placeholder="Monthly or annual revenue per user"
        />
      </div>

      <div className="form-group">
        <label htmlFor="churnRate">Churn Rate (%)</label>
        <input
          id="churnRate"
          type="number"
          value={data.churnRate}
          onChange={(e) => handleChange('churnRate', parseFloat(e.target.value) || 0)}
          placeholder="Monthly customer churn percentage"
        />
      </div>

      <div className="form-actions">
        <button type="button" className="btn btn-secondary" onClick={onPrev}>
          ← Previous
        </button>
        <button type="submit" className="btn btn-primary">
          Next: Customer Data →
        </button>
      </div>
    </form>
  );
};

export default MarketForm;