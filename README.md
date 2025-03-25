# TODOs

```
[x] Add button to convert Planned Acitivity into Actual Activity
[x] Add "Update all from PSE" button
[x] Add background job that will update company info from PSE daily
[x] Scope Activity History to current user
[x] Add logout button

# Portfolio
[ ] Sort Portfolio by P/L percent
[ ] Sort Portfolio by Divs %
[ ] Sort Portfolio by P/L + Divs %
[ ] Pie graph of top 5 + others by cost
[ ] Pie graph of top 5 + others by value

# Company View
[ ] Price Graph
[ ] Breakdown Activities & Dividends by Year
[ ] Activities - end of year holdings and end of year cost per share
[ ] Dividends - end of year totals and % return relative to end of year cost per share

# Upload SOA
[ ] Upload BPI Trade SOA & prepare activities & dividends from the file
[ ] Approve activities & dividends
[ ] Detect possible duplicates

# Dividend Ladder
[ ] Compute Portfolio Change Per Year
[ ] Compute Total Dividends % Relative to Portfolio Change

# Dividend Announcements
[x] Scrape dividend announcements
[x] Display dividend announcements
[ ] In company view: compute expected dividends based on dividend announcements
[x] Handle announcements for preferred shares (example: https://edge.pse.com.ph/companyPage/dividends_and_rights_form.do?cmpy_id=154)
[ ] Also handle stock announcements

# Strategies
[x] Add Target Buy Price
[ ] Refactor Target Buy Price to be set per user, instead of global to company
[ ] Add Target Sell Price, per user per company
[ ] Add Target Expense Milestone, per user per company
```

# Cron

```
# every 8pm
0 20 * * * bash -lc 'cd /Users/rystraum/Code/personal/stocks-portfolio; rails runner "PriceUpdateCompanies.new.run_from_console"'
```

# Disable Backup

```
STOCKS_BACKUP=false rails c
```