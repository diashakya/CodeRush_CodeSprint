import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import MarketFitAnalyzer from './components/MarketFitAnalyzer';
import PerformancePredictor from './components/PerformancePredictor';
import './App.css';

function App() {
  return (
    <Router>
      <nav style={{ padding: '1rem', background: '#111' }}>
        <Link to="/" style={{ color: '#fff', marginRight: '2rem' }}>Market Fit Analyzer</Link>
        <Link to="/predictor" style={{ color: '#fff' }}>Performance Predictor</Link>
      </nav>
      <Routes>
        <Route path="/" element={<MarketFitAnalyzer />} />
        <Route path="/predictor" element={<PerformancePredictor />} />
      </Routes>
    </Router>
  );
}

export default App;
