import { useState } from 'react';
import { calculateMarketFitScore } from '../utils/marketFitCalculator';
import { useLocalStorage } from './useLocalStorage';

export const useMarketFitAnalysis = () => {
  const [productData, setProductData] = useLocalStorage('productData', {
    productName: '',
    category: 'saas',
    targetMarket: '',
    pricePoint: 0,
    uniqueValueProp: '',
    developmentStage: 'concept'
  });

  const [marketData, setMarketData] = useLocalStorage('marketData', {
    marketSize: 0,
    growthRate: 0,
    competitionLevel: 'medium',
    customerAcquisitionCost: 0,
    averageRevenuePerUser: 0,
    churnRate: 0
  });

  const [customerData, setCustomerData] = useLocalStorage('customerData', {
    targetAge: '',
    incomeLevel: 'medium',
    painPointIntensity: 5,
    buyingBehavior: 'researched',
    technicalSavviness: 'medium'
  });

  const [analysis, setAnalysis] = useState(null); // Initialize as null

  const updateProductData = (updates) => {
    setProductData(prev => ({ ...prev, ...updates }));
  };

  const updateMarketData = (updates) => {
    setMarketData(prev => ({ ...prev, ...updates }));
  };

  const updateCustomerData = (updates) => {
    setCustomerData(prev => ({ ...prev, ...updates }));
  };

  const calculateAnalysis = () => {
    const result = calculateMarketFitScore(productData, marketData, customerData);
    setAnalysis(result);
  };

  return {
    productData,
    marketData,
    customerData,
    analysis,
    updateProductData,
    updateMarketData,
    updateCustomerData,
    calculateAnalysis,
    setProductData, // Expose full setters
    setMarketData,
    setCustomerData,
  };
}; 