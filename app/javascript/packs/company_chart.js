import React from 'react';
import ReactDOM from 'react-dom';
import CompanyChart from '../components/CompanyChart';

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('company-chart-root');
  if (container) {
    const ticker = container.dataset.ticker;
    const targetBuyPrice = container.dataset.targetBuyPrice;
    ReactDOM.render(<CompanyChart ticker={ticker} targetBuyPrice={targetBuyPrice} />, container);
  }
});
