import React, { useState } from 'react';
import ProductForm from './ProductForm';
import MarketForm from './MarketForm';
import CustomerForm from './CustomerForm';
import AnalysisResults from './AnalysisResults';
import Visualizations from './Visualizations';
import { useMarketFitAnalysis } from '../../hooks/useMarketFitAnalysis';
import './MarketFitAnalyzer.css';

const MarketFitAnalyzer = () => {
  const {
    productData,
    marketData,
    customerData,
    analysis,
    updateProductData,
    updateMarketData,
    updateCustomerData,
    calculateAnalysis
  } = useMarketFitAnalysis();

  const [activeTab, setActiveTab] = useState('product');
  const [isAnalysisComplete, setIsAnalysisComplete] = useState(false);

  const handleAnalyze = () => {
    calculateAnalysis();
    setIsAnalysisComplete(true);
    setActiveTab('results');
  };

  const tabs = [
    { id: 'product', label: 'Product Info', icon: '🎯' },
    { id: 'market', label: 'Market Data', icon: '📊' },
    { id: 'customer', label: 'Customer Data', icon: '👥' },
    { id: 'results', label: 'Analysis', icon: '📈' }
  ];

  return (
    <div className="market-fit-analyzer">
      <header className="analyzer-header">
        <h1>Market Fit Analysis Tool</h1>
        <p>Predict product-market fit and identify optimization opportunities</p>
      </header>

      <nav className="analyzer-nav">
        {tabs.map(tab => (
          <button
            key={tab.id}
            className={`nav-tab ${activeTab === tab.id ? 'active' : ''}`}
            onClick={() => setActiveTab(tab.id)}
            disabled={tab.id === 'results' && !isAnalysisComplete}
          >
            <span className="tab-icon">{tab.icon}</span>
            {tab.label}
          </button>
        ))}
      </nav>

      <main className="analyzer-content">
        {activeTab === 'product' && (
          <ProductForm 
            data={productData} 
            onChange={updateProductData}
            onNext={() => setActiveTab('market')}
          />
        )}
        
        {activeTab === 'market' && (
          <MarketForm 
            data={marketData} 
            onChange={updateMarketData}
            onNext={() => setActiveTab('customer')}
            onPrev={() => setActiveTab('product')}
          />
        )}
        
        {activeTab === 'customer' && (
          <CustomerForm 
            data={customerData} 
            onChange={updateCustomerData}
            onAnalyze={handleAnalyze}
            onPrev={() => setActiveTab('market')}
          />
        )}
        
        {activeTab === 'results' && isAnalysisComplete && (
          <>
            <AnalysisResults analysis={analysis} />
            <Visualizations 
              productData={productData}
              marketData={marketData}
              customerData={customerData}
              analysis={analysis}
            />
          </>
        )}
      </main>
    </div>
  );
};

export default MarketFitAnalyzer;