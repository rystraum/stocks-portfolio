# TODOs

```
[x] Add button to convert Planned Acitivity into Actual Activity
[x] Add "Update all from PSE" button
[ ] Add graphs in Company view
[x] Add background job that will update company info from PSE daily
[ ] Sort Portfolio by P/L percent
[ ] Sort Portfolio by Divs %
[ ] Sort Portfolio by P/L + Divs %
[x] Scope Activity History to current user
[x] Add logout button
```

# Cron

# every 8pm
0 20 * * * bash -lc 'cd /Users/rystraum/Code/personal/stocks-portfolio; rails runner "PriceUpdateCompanies.new.run_from_console"'
