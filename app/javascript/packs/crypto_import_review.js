import React from 'react';
import ReactDOM from 'react-dom';
import CryptoImportReview from '../components/CryptoImportReview';

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('crypto-import-review-root');
  if (container) {
    const importId = container.dataset.importId;
    ReactDOM.render(<CryptoImportReview importId={importId} />, container);
  }
});
