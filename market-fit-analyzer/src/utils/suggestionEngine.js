/**
 * A simple "engine" to suggest market and customer data based on product category.
 * This provides a baseline for users to start from.
 */
export const getSuggestedData = (category) => {
    const profiles = {
      saas: {
        marketData: { marketSize: 50000000, growthRate: 15, competitionLevel: 'high', customerAcquisitionCost: 500, averageRevenuePerUser: 1200, churnRate: 5 },
        customerData: { targetAge: '26-35', incomeLevel: 'medium', painPointIntensity: 8, buyingBehavior: 'researched', technicalSavviness: 'high' }
      },
      'e-commerce': {
        marketData: { marketSize: 100000000, growthRate: 12, competitionLevel: 'saturated', customerAcquisitionCost: 50, averageRevenuePerUser: 150, churnRate: 10 },
        customerData: { targetAge: '18-25', incomeLevel: 'low', painPointIntensity: 6, buyingBehavior: 'impulsive', technicalSavviness: 'medium' }
      },
      'mobile-app': {
        marketData: { marketSize: 200000000, growthRate: 20, competitionLevel: 'high', customerAcquisitionCost: 5, averageRevenuePerUser: 20, churnRate: 15 },
        customerData: { targetAge: '18-25', incomeLevel: 'low', painPointIntensity: 7, buyingBehavior: 'early-adopter', technicalSavviness: 'high' }
      },
      'hardware': {
        marketData: { marketSize: 80000000, growthRate: 8, competitionLevel: 'medium', customerAcquisitionCost: 1000, averageRevenuePerUser: 2500, churnRate: 3 },
        customerData: { targetAge: '36-45', incomeLevel: 'high', painPointIntensity: 9, buyingBehavior: 'researched', technicalSavviness: 'medium' }
      },
      'service': {
          marketData: { marketSize: 30000000, growthRate: 6, competitionLevel: 'low', customerAcquisitionCost: 200, averageRevenuePerUser: 500, churnRate: 7 },
          customerData: { targetAge: '46-55', incomeLevel: 'medium', painPointIntensity: 8, buyingBehavior: 'conservative', technicalSavviness: 'low' }
      },
      'fintech': {
          marketData: { marketSize: 150000000, growthRate: 18, competitionLevel: 'high', customerAcquisitionCost: 300, averageRevenuePerUser: 800, churnRate: 6 },
          customerData: { targetAge: '26-35', incomeLevel: 'medium', painPointIntensity: 9, buyingBehavior: 'researched', technicalSavviness: 'high' }
      },
      'healthtech': {
          marketData: { marketSize: 120000000, growthRate: 16, competitionLevel: 'medium', customerAcquisitionCost: 400, averageRevenuePerUser: 1000, churnRate: 4 },
          customerData: { targetAge: '36-45', incomeLevel: 'high', painPointIntensity: 10, buyingBehavior: 'conservative', technicalSavviness: 'medium' }
      },
      'edtech': {
          marketData: { marketSize: 90000000, growthRate: 14, competitionLevel: 'high', customerAcquisitionCost: 150, averageRevenuePerUser: 400, churnRate: 9 },
          customerData: { targetAge: '18-25', incomeLevel: 'low', painPointIntensity: 7, buyingBehavior: 'researched', technicalSavviness: 'high' }
      },
      // A default profile for categories not listed above
      default: {
        marketData: { marketSize: 10000000, growthRate: 5, competitionLevel: 'medium', customerAcquisitionCost: 100, averageRevenuePerUser: 300, churnRate: 8 },
        customerData: { targetAge: '36-45', incomeLevel: 'medium', painPointIntensity: 5, buyingBehavior: 'conservative', technicalSavviness: 'medium' }
      }
    };
  
    return profiles[category] || profiles.default;
  }; 