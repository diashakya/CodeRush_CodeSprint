import React from 'react';

const AnalysisResults = ({ analysis }) => {
  const getRiskColor = (level) => {
    switch (level) {
      case 'low': return 'risk-low';
      case 'medium': return 'risk-medium';
      case 'high': return 'risk-high';
      case 'critical': return 'risk-critical';
      default: return 'risk-medium';
    }
  };

  const getScoreColor = (score) => {
    if (score >= 80) return 'score-excellent';
    if (score >= 60) return 'score-good';
    if (score >= 40) return 'score-fair';
    return 'score-poor';
  };

  return (
    <div className="analysis-section">
      <h2>Market Fit Analysis Results</h2>
      
      <div className="results-grid">
        <div className="score-card main-score">
          <h3>Market Fit Score</h3>
          <div className={`score-value ${getScoreColor(analysis.fitScore)}`}>
            {analysis.fitScore}/100
          </div>
          <div className={`risk-badge ${getRiskColor(analysis.riskLevel)}`}>
            {analysis.riskLevel.toUpperCase()} RISK
          </div>
        </div>

        <div className="prediction-card">
          <h3>Prediction</h3>
          <p className="prediction-text">{analysis.prediction}</p>
        </div>
      </div>

      <div className="metrics-grid">
        <div className="metric-card">
          <h4>Market Opportunity</h4>
          <div className="metric-value opportunity">
            {analysis.marketOpportunity}%
          </div>
        </div>
        
        <div className="metric-card">
          <h4>Competitive Threat</h4>
          <div className="metric-value threat">
            {analysis.competitiveThreat}%
          </div>
        </div>
        
        <div className="metric-card">
          <h4>Financial Viability</h4>
          <div className="metric-value viability">
            {analysis.financialViability}%
          </div>
        </div>
      </div>

      {analysis.recommendations && analysis.recommendations.length > 0 && (
        <div className="recommendations-section">
          <h3>Recommendations</h3>
          <div className="recommendations-list">
            {analysis.recommendations.map((rec, index) => (
              <div key={index} className="recommendation-item">
                <span className="recommendation-icon">💡</span>
                <span className="recommendation-text">{rec}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default AnalysisResults;