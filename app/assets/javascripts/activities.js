const formatCurrency = (number) => {
  return Number(number).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const computePrice = (companyId, numberOfShares) => {
  $.get(`/companies/${companyId}/last_price`, { format: "json" }, (data, status, xhr) => {
    $(".js-last-price-container").html(`
      <p>
        Per Share Price: ${formatCurrency(data.lastPrice)}<br />
        Total: ${formatCurrency(Number(numberOfShares) * Number(data.lastPrice))}
      </p>
    `);
  });
}

$(document).ready(() => {
  $(".js-activity-form").on("change", ".js-activity-company, .js-activity-shares", (e) => {
    const companyId = $(".js-activity-company").val();
    const numberOfShares = $(".js-activity-shares").val();

    computePrice(companyId, numberOfShares);

    const link = $("<a></a>");
    link.attr("href",`/companies/${companyId}`);
    link.attr("target", "_blank");
    link.text("LINK");
    $(".js-company-link").html(link);
  });
})
