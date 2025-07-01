import React, { useState } from 'react';
import ProductForm from './ProductForm';
import MarketForm from './MarketForm';
import CustomerForm from './CustomerForm';
import AnalysisResults from './AnalysisResults';
import Visualizations from './Visualizations';
import { useMarketFitAnalysis } from '../hooks/useMarketFitAnalysis';
import { getSuggestedData } from '../utils/suggestionEngine'; // Import the new engine
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
    calculateAnalysis,
    setMarketData, // Expose setters for direct manipulation
    setCustomerData,
  } = useMarketFitAnalysis();

  const [uiState, setUiState] = useState('product_entry'); // States: product_entry, editing, results

  // --- Event Handlers ---

  const handleSuggestAndAnalyze = () => {
    // 1. Get suggestions based on product category
    const suggestions = getSuggestedData(productData.category);
    
    // 2. Update state with suggestions
    setMarketData(suggestions.marketData);
    setCustomerData(suggestions.customerData);
    
    // 3. Move to the editing/review state
    setUiState('editing');
  };

  const handleFinalAnalysis = () => {
    // 1. Calculate the final analysis with potentially edited data
    calculateAnalysis();
    
    // 2. Move to the results state
    setUiState('results');
  };
  
  const handleStartOver = () => {
    // A full reset would be better handled inside the useMarketFitAnalysis hook,
    // but for now, we just reset the UI state.
    setUiState('product_entry'); 
  };
  
  const handleEdit = () => {
      setUiState('editing');
  }

  // --- Render Logic ---

  return (
    <div className="market-fit-analyzer">
      <header className="analyzer-header">
        <h1>Market Fit Analysis Tool</h1>
        <p>Predict product-market fit and identify optimization opportunities.</p>
      </header>

      <main className="analyzer-content">
        {/* State 1: Initial Product Info Entry */}
        {uiState === 'product_entry' && (
          <div className="entry-step">
            <ProductForm data={productData} onChange={updateProductData} />
            <div className="form-actions">
              <button 
                className="btn btn-primary btn-full"
                onClick={handleSuggestAndAnalyze}
                disabled={!productData.productName || !productData.category}
              >
                Suggest Market Data & Continue →
              </button>
            </div>
          </div>
        )}

        {/* State 2: Review and Edit Suggested Data */}
        {uiState === 'editing' && (
          <div className="editing-step">
            <h2>Review & Edit Data</h2>
            <p>We've suggested data based on your product category. Feel free to adjust these values.</p>
            <div className="forms-container">
                <MarketForm data={marketData} onChange={updateMarketData} />
                <CustomerForm data={customerData} onChange={updateCustomerData} />
            </div>
            <div className="form-actions">
                <button className="btn btn-secondary" onClick={() => setUiState('product_entry')}>
                    ← Back to Product
                </button>
                <button className="btn btn-primary" onClick={handleFinalAnalysis}>
                    Analyze Now 🚀
                </button>
            </div>
          </div>
        )}

        {/* State 3: Display Final Results */}
        {uiState === 'results' && analysis && (
          <div className="results-step">
            <AnalysisResults analysis={analysis} />
            <Visualizations 
              productData={productData}
              marketData={marketData}
              customerData={customerData}
              analysis={analysis}
            />
            <div className="form-actions">
                <button className="btn btn-secondary" onClick={handleEdit}>
                    ← Edit Data
                </button>
                <button className="btn btn-primary" onClick={handleStartOver}>
                    Start New Analysis
                </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default MarketFitAnalyzer; 