export const calculateMarketFitScore = (productData, marketData, customerData) => {
  let score = 0;
  let recommendations = [];

  // Market Size Analysis
  const marketSize = parseFloat(marketData.marketSize) || 0;
  const growthRate = parseFloat(marketData.growthRate) || 0;
  
  if (marketSize > 1000000000) score += 25; // $1B+
  else if (marketSize > 100000000) score += 20; // $100M+
  else if (marketSize > 10000000) score += 15; // $10M+
  else if (marketSize > 1000000) score += 10; // $1M+
  else score += 5;

  if (growthRate > 20) score += 15;
  else if (growthRate > 10) score += 10;
  else if (growthRate > 5) score += 5;

  // Competition Analysis
  const competitionMultiplier = {
    'low': 1.2,
    'medium': 1.0,
    'high': 0.8,
    'saturated': 0.6
  };
  score *= competitionMultiplier[marketData.competitionLevel];

  // Financial Viability
  const cac = parseFloat(marketData.customerAcquisitionCost) || 0;
  const arpu = parseFloat(marketData.averageRevenuePerUser) || 0;
  const churn = parseFloat(marketData.churnRate) || 0;

  if (cac > 0 && arpu > 0) {
    if (arpu > cac * 3) score += 20;
    else if (arpu > cac * 2) score += 15;
    else if (arpu > cac) score += 10;
    else score += 5;
  }

  if (churn < 5) score += 10;
  else if (churn < 10) score += 5;
  else if (churn > 20) score -= 10;

  // Customer Fit Analysis
  const painPointScore = customerData.painPointIntensity * 2;
  score += painPointScore;

  // Development Stage Impact
  const stageMultiplier = {
    'concept': 0.7,
    'prototype': 0.8,
    'mvp': 1.0,
    'beta': 1.1,
    'launched': 1.2
  };
  score *= stageMultiplier[productData.developmentStage];

  // Generate Recommendations
  if (marketSize < 50000000) {
    recommendations.push("Consider expanding to adjacent markets to increase addressable market size");
  }

  if (marketData.competitionLevel === 'high' || marketData.competitionLevel === 'saturated') {
    recommendations.push("Focus on unique differentiation and niche positioning");
  }

  if (cac > 0 && arpu > 0 && cac >= arpu) {
    recommendations.push("Optimize customer acquisition channels to reduce CAC");
    recommendations.push("Consider pricing strategy adjustments to improve unit economics");
  }

  if (churn > 15) {
    recommendations.push("Implement customer success programs to reduce churn");
    recommendations.push("Analyze user onboarding and engagement patterns");
  }

  if (customerData.painPointIntensity < 6) {
    recommendations.push("Validate that you're solving a critical customer problem");
  }

  // Calculate component scores
  const marketOpportunity = Math.min(100, (marketSize / 10000000) + (growthRate * 2));
  const competitiveThreat = {
    'low': 20,
    'medium': 50,
    'high': 75,
    'saturated': 90
  }[marketData.competitionLevel];

  const financialViability = cac > 0 && arpu > 0 ? 
    Math.min(100, Math.max(0, ((arpu - cac) / arpu) * 100)) : 50;

  // Determine prediction and risk level
  let prediction = '';
  let riskLevel = 'medium';

  if (score >= 80) {
    prediction = 'Strong Market Fit - High probability of success with current strategy';
    riskLevel = 'low';
  } else if (score >= 60) {
    prediction = 'Good Market Potential - Moderate success probability with optimization';
    riskLevel = 'medium';
  } else if (score >= 40) {
    prediction = 'Challenging Market Fit - Requires significant pivoting or repositioning';
    riskLevel = 'high';
  } else {
    prediction = 'Poor Market Fit - High risk of failure, consider major strategic changes';
    riskLevel = 'critical';
  }

  return {
    fitScore: Math.round(Math.max(0, Math.min(100, score))),
    prediction,
    riskLevel,
    recommendations,
    marketOpportunity: Math.round(marketOpportunity),
    competitiveThreat,
    financialViability: Math.round(financialViability)
  };
};