import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "companyRow",
    "portfolioHeader",
    "inactiveCompaniesSwitch",
    "liquidatedCompaniesSwitch",
    "actualValuesSwitch",
  ];

  toggleDisplayTableCell(element) {
    element.style.display = element.style.display === 'none' ? 'table-cell' : 'none';
  }

  toggleColspan(element) {
    console.log(element);
    element.colSpan = element.colSpan === 2 ? 1 : 2;
  }

  toggleActualValues() {
    this.toggleDisplayTableCell(this.portfolioHeaderTarget.querySelector('th.tables-shares'));
    this.toggleDisplayTableCell(this.portfolioHeaderTarget.querySelector('th.tables-total-cost'));
    this.toggleDisplayTableCell(this.portfolioHeaderTarget.querySelector('th.tables-cps'));
    this.toggleDisplayTableCell(this.portfolioHeaderTarget.querySelector('th.tables-last-value'));
    this.toggleColspan(this.portfolioHeaderTarget.querySelector('th.tables-pnl'));
    this.toggleColspan(this.portfolioHeaderTarget.querySelector('th.tables-divs'));
    this.toggleColspan(this.portfolioHeaderTarget.querySelector('th.tables-final-pnl'));
    this.companyRowTargets.forEach(company => {
      this.toggleDisplayTableCell(company.querySelector('td.tables-shares'))
      this.toggleDisplayTableCell(company.querySelector('td.tables-total-cost'));
      this.toggleDisplayTableCell(company.querySelector('td.tables-cps'));
      this.toggleDisplayTableCell(company.querySelector('td.tables-last-value'));
      this.toggleDisplayTableCell(company.querySelector('td.tables-pnl'));
      this.toggleDisplayTableCell(company.querySelector('td.tables-divs-total'));
      this.toggleDisplayTableCell(company.querySelector('td.tables-final-pnl'));
    });
  }

  toggleInactiveCompanies() {
    this.companyRowTargets.forEach(company => {
      console.log(company.dataset);
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
