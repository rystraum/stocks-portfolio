import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "shares", "pricePerShare", "charges", "totalPrice", "effectivePriceInfo", "activityType"
  ];

  connect() {
    this.calculatePricePerShare();
    this.updateEffectivePriceInfo();
  }

  calculateTotalPrice() {
    const shares = parseFloat(this.sharesTarget.value);
    const pricePerShare = parseFloat(this.pricePerShareTarget.value);
    const charges = parseFloat(this.chargesTarget.value);
    const activityType = this.activityTypeTarget.value;
    if (!isNaN(shares) && !isNaN(pricePerShare) && !isNaN(charges) && activityType !== "") {
      const subtotal = shares * pricePerShare;
      const total = activityType === "BUY" ? subtotal + charges : subtotal - charges;
      this.totalPriceTarget.value = total.toFixed(2);
      this.updateEffectivePriceInfo();
    }
  }

  calculatePricePerShare() {
    const shares = parseFloat(this.sharesTarget.value);
    const totalPrice = parseFloat(this.totalPriceTarget.value);
    const charges = parseFloat(this.chargesTarget.value);
    const activityType = this.activityTypeTarget.value;
    if (!isNaN(shares) && !isNaN(totalPrice) && !isNaN(charges) && shares !== 0 && activityType !== "") {
      const subtotal = activityType === "BUY" ? totalPrice - charges : totalPrice + charges;
      const pricePerShare = subtotal / shares;
      this.pricePerShareTarget.value = pricePerShare.toFixed(4);
      this.updateEffectivePriceInfo();
    }
  }

  updateEffectivePriceInfo() {
    const shares = parseFloat(this.sharesTarget.value);
    const totalPrice = parseFloat(this.totalPriceTarget.value);
    if (!isNaN(shares) && shares !== 0 && !isNaN(totalPrice)) {
      const effective = totalPrice / shares;
      this.effectivePriceInfoTarget.textContent = `Effective price per share: ${effective.toFixed(4)}`;
    } else {
      this.effectivePriceInfoTarget.textContent = '';
    }
  }

  onInput(event) {
    // Determine which fields are filled and which to calculate
    const shares = this.sharesTarget.value;
    const pricePerShare = this.pricePerShareTarget.value;
    const charges = this.chargesTarget.value;
    const totalPrice = this.totalPriceTarget.value;

    if (shares && pricePerShare && charges) {
      this.calculateTotalPrice();
    } else if (shares && charges && totalPrice) {
      this.calculatePricePerShare();
    } else {
      this.updateEffectivePriceInfo();
    }
  }
}
