import React from 'react';
import { Bar, Pie } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, ArcElement, Tooltip, Legend } from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, ArcElement, Tooltip, Legend);

const chartFontFamily = 'Segoe UI, Roboto, Arial, sans-serif';

const Visualizations = ({ productData, marketData, customerData, analysis }) => {
  // Example Bar Chart: Market Opportunity, Competitive Threat, Financial Viability
  const barData = {
    labels: ['Market Opportunity', 'Competitive Threat', 'Financial Viability'],
    datasets: [
      {
        label: 'Score (%)',
        data: [
          analysis.marketOpportunity,
          analysis.competitiveThreat,
          analysis.financialViability
        ],
        backgroundColor: ['#4F8EF7', '#F76E6E', '#43D9A3'], // blue, coral, green
        borderRadius: 8,
      },
    ],
  };

  const barOptions = {
    plugins: {
      legend: {
        labels: {
          font: { family: chartFontFamily, size: 14 },
        },
      },
      tooltip: {
        bodyFont: { family: chartFontFamily },
        titleFont: { family: chartFontFamily },
      },
    },
    scales: {
      x: {
        ticks: { font: { family: chartFontFamily, size: 13 } },
      },
      y: {
        beginAtZero: true,
        ticks: { font: { family: chartFontFamily, size: 13 } },
      },
    },
  };

  // Example Pie Chart: Pain Point Intensity
  const pieData = {
    labels: ['Pain Point Intensity', 'Remaining'],
    datasets: [
      {
        data: [customerData.painPointIntensity, 10 - customerData.painPointIntensity],
        backgroundColor: ['#FFD166', '#A9DEF9'], // yellow, light blue
        borderWidth: 2,
        borderColor: ['#FFF', '#FFF'],
      },
    ],
  };

  const pieOptions = {
    plugins: {
      legend: {
        labels: {
          font: { family: chartFontFamily, size: 14 },
        },
      },
      tooltip: {
        bodyFont: { family: chartFontFamily },
        titleFont: { family: chartFontFamily },
      },
    },
  };

  return (
    <div>
      <h2 style={{ fontFamily: chartFontFamily }}>Visualizations</h2>
      <div style={{ maxWidth: 500, margin: '0 auto' }}>
        <Bar data={barData} options={barOptions} />
      </div>
      <div style={{ maxWidth: 300, margin: '2rem auto' }}>
        <Pie data={pieData} options={pieOptions} />
      </div>
    </div>
  );
};

export default Visualizations;
