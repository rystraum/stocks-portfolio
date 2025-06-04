import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["tableRow", "checkbox", "cryptoSum", "fiatSum", "forexAverage", "pnl", "testPrice", "testPnl"];

  connect() {
    this.updateSums();
  }

  tableRowClick(event) {
    const checkbox = event.target.closest("tr").querySelector("[data-crypto-activity-selection-target='checkbox']");
    if (checkbox) checkbox.checked = !checkbox.checked;
    this.updateSums();
  }

  inputChange(event) {
    const testPrice = parseFloat(event.target.value.replace(/,/g, ''));
    this.setTargetPricePnl(testPrice);
  }

  toggleAll(event) {
    const checked = event.target.checked;
    this.tableRowTargets.forEach(row => {
      const checkbox = row.querySelector("[data-crypto-activity-selection-target='checkbox']");
      if (checkbox) checkbox.checked = checked;
    });
    this.updateSums();
  }

  updateSums() {
    const { cryptoSum, fiatSum, lastPrice, buyCryptoSum, buyFiatSum } = this.getSums();
    const { pnlAmount, pnlPercentage } = this.computePnlWithFee(cryptoSum, lastPrice, fiatSum);

    const testPrice = parseFloat(this.testPriceTarget.value.replace(/,/g, ''));
    this.setTargetPricePnl(testPrice);

    this.cryptoSumTarget.textContent = this.formatLocale(cryptoSum, 10);
    this.fiatSumTarget.textContent = this.formatLocale(fiatSum);
    this.forexAverageTarget.textContent = buyCryptoSum !== 0 ? this.formatLocale(buyFiatSum / buyCryptoSum) : 0;
    this.pnlTarget.textContent = `${this.formatLocale(pnlAmount)} (${this.formatLocale(pnlPercentage)}%)`;
  }

  setTargetPricePnl(testPrice) {
    const { cryptoSum, fiatSum } = this.getSums();
    const { pnlAmount, pnlPercentage } = this.computePnlWithFee(cryptoSum, testPrice, fiatSum);
    this.testPnlTarget.textContent = `${this.formatLocale(pnlAmount)} (${this.formatLocale(pnlPercentage)}%)`;
  }

  formatLocale(number, maximumFractionDigits = 2, useGrouping = true) {
    return Number(number).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits, useGrouping });
  }

  computePnlWithFee(cryptoSum, lastPrice, fiatSum) {
    // hardcoded 0.3% fee
    const pnlAmount = (cryptoSum * lastPrice * 0.997) - fiatSum;
    const pnlPercentage = pnlAmount / fiatSum * 100;

    return {
      pnlAmount,
      pnlPercentage
    }
  }

  getSums() {
    let lastPrice = 0;

    let buyCryptoSum = 0;
    let sellCryptoSum = 0;
    let buyFiatSum = 0;
    let sellFiatSum = 0;
    
    this.checkboxTargets.forEach((cb) => {
      if (cb.checked) {
        const isSell = cb.dataset.activityType === "sell";
        const cryptoAmount = parseFloat(cb.dataset.cryptoAmount);
        const cryptoFee = parseFloat(cb.dataset.feeCrypto);
        const fiatAmount = parseFloat(cb.dataset.fiatAmount);
        const fiatFee = parseFloat(cb.dataset.feeFiat);
        const crypto = isSell ? cryptoAmount : cryptoAmount - cryptoFee;
        const fiat = isSell ? fiatAmount - fiatFee : fiatAmount;
        isSell ? sellCryptoSum += crypto : buyCryptoSum += crypto;
        isSell ? sellFiatSum += fiat : buyFiatSum += fiat;

        lastPrice = parseFloat(cb.dataset.lastPrice);
      }
    });

    return {
      cryptoSum: buyCryptoSum - sellCryptoSum,
      fiatSum: buyFiatSum - sellFiatSum,
      buyCryptoSum,
      sellCryptoSum,
      buyFiatSum,
      sellFiatSum,
      lastPrice
    }
  }
}
