import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["tableRow", "checkbox", "cryptoSum", "fiatSum", "forexAverage", "pnl"];

  connect() {
    this.updateSums();
  }

  tableRowClick(event) {
    const checkbox = event.target.closest("tr").querySelector("[data-crypto-activity-selection-target='checkbox']");
    if (checkbox) checkbox.checked = !checkbox.checked;
    this.updateSums();
  }

  updateSums() {
    let cryptoSum = 0;
    let fiatSum = 0;
    let lastPrice = 0;
    this.checkboxTargets.forEach((cb) => {
      if (cb.checked) {
        // activity_type: 0 = buy, 1 = sell
        const sign = cb.dataset.activityType === "1" ? -1 : 1;
        const crypto = parseFloat(cb.dataset.cryptoAmount) - parseFloat(cb.dataset.feeCrypto);
        const fiat = parseFloat(cb.dataset.fiatAmount) - parseFloat(cb.dataset.feeFiat);
        cryptoSum += sign * crypto;
        fiatSum += sign * fiat;
        lastPrice = parseFloat(cb.dataset.lastPrice);
      }
    });
    this.cryptoSumTarget.textContent = cryptoSum.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 10 });
    this.fiatSumTarget.textContent = fiatSum.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    this.forexAverageTarget.textContent = cryptoSum !== 0 ? (fiatSum / cryptoSum).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2, useGrouping: true }) : 0;

    // hardcoded 0.3% fee
    const pnlAmount = (cryptoSum * lastPrice * 0.997) - fiatSum;
    const pnlPercentage = pnlAmount / fiatSum * 100;
    this.pnlTarget.textContent = `${pnlAmount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2, useGrouping: true })} (${pnlPercentage.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2, useGrouping: true })}%)`;
  }
}
