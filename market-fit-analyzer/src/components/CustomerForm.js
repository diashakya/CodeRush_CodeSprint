import React from 'react';

const CustomerForm = ({ data, onChange, onAnalyze, onPrev }) => {
  const handleChange = (field, value) => {
    onChange({ [field]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onAnalyze();
  };

  return (
    <form onSubmit={handleSubmit} className="form-section">
      <h2>Customer Analysis</h2>
      
      <div className="form-group">
        <label htmlFor="targetAge">Target Age Group</label>
        <select
          id="targetAge"
          value={data.targetAge}
          onChange={(e) => handleChange('targetAge', e.target.value)}
        >
          <option value="">Select age group</option>
          <option value="18-25">18-25</option>
          <option value="26-35">26-35</option>
          <option value="36-45">36-45</option>
          <option value="46-55">46-55</option>
          <option value="55+">55+</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="incomeLevel">Income Level</label>
        <select
          id="incomeLevel"
          value={data.incomeLevel}
          onChange={(e) => handleChange('incomeLevel', e.target.value)}
        >
          <option value="low">Low Income ($0-30k)</option>
          <option value="medium">Medium Income ($30k-100k)</option>
          <option value="high">High Income ($100k+)</option>
          <option value="enterprise">Enterprise Budget</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="painPointIntensity">
          Pain Point Intensity: {data.painPointIntensity}/10
        </label>
        <input
          id="painPointIntensity"
          type="range"
          min="1"
          max="10"
          value={data.painPointIntensity}
          onChange={(e) => handleChange('painPointIntensity', parseInt(e.target.value))}
          className="slider"
        />
        <div className="slider-labels">
          <span>Mild</span>
          <span>Critical</span>
        </div>
      </div>

      <div className="form-group">
        <label htmlFor="buyingBehavior">Buying Behavior</label>
        <select
          id="buyingBehavior"
          value={data.buyingBehavior}
          onChange={(e) => handleChange('buyingBehavior', e.target.value)}
        >
          <option value="impulsive">Impulsive Buyer</option>
          <option value="researched">Research-Driven</option>
          <option value="conservative">Conservative</option>
          <option value="early-adopter">Early Adopter</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="technicalSavviness">Technical Savviness</label>
        <select
          id="technicalSavviness"
          value={data.technicalSavviness}
          onChange={(e) => handleChange('technicalSavviness', e.target.value)}
        >
          <option value="low">Low Tech</option>
          <option value="medium">Medium Tech</option>
          <option value="high">High Tech</option>
          <option value="expert">Tech Expert</option>
        </select>
      </div>

      <div className="form-actions">
        <button type="button" className="btn btn-secondary" onClick={onPrev}>
          ← Previous
        </button>
        <button type="submit" className="btn btn-primary btn-analyze">
          🔍 Analyze Market Fit
        </button>
      </div>
    </form>
  );
};

export default CustomerForm;