import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "companyRow",
    "inactiveCompaniesSwitch",
    "liquidatedCompaniesSwitch"
  ];

  connect() {
    this.hideInactiveCompanies();
    this.hideLiquidatedCompanies();
  }

  hideInactiveCompanies() {
    this.companyRowTargets.forEach(company => {
      if (company.dataset.companyStatus === "inactive") {
        company.style.display = 'none';
      }
    });
  }

  hideLiquidatedCompanies() {
    this.companyRowTargets.forEach(company => {
      if (company.dataset.companyStatus === "liquidated") {
        company.style.display = 'none';
      }
    });
  }

  toggleInactiveCompanies() {
    console.log("toggleInactiveCompanies")
    this.companyRowTargets.forEach(company => {
      if (company.dataset.companyStatus === "inactive") {
        company.style.display = company.style.display === 'none' ? 'table-row' : 'none';
      }
    });
  }

  toggleLiquidatedCompanies() {
    this.companyRowTargets.forEach(company => {
      if (company.dataset.companyStatus === "liquidated") {
        company.style.display = company.style.display === 'none' ? 'table-row' : 'none';
      }
    });
  }
}
