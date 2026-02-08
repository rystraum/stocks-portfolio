# frozen_string_literal: true

require "test_helper"

class CoinsphMock
  def self.prices(_tickers)
    [
      {
        "symbol": "BTCPHP",
        "price": "5382856.9"
      },
      {
        "symbol": "ETHPHP",
        "price": "101906.4"
      },
      {
        "symbol": "SUIPHP",
        "price": "189"
      },
    ]
  end

  def self.account
    {
      "canTrade" => true,
      "canDeposit" => true,
      "canWithdraw" => true,
      "accountType" => "SPOT",
      "updateTime" => 1_701_790_415_739,
      "balances" =>
  [{ "asset" => "AIR", "free" => "0.53673664", "locked" => "0" },
   { "asset" => "BTC", "free" => "0", "locked" => "0" },
   { "asset" => "ETH", "free" => "0.00000098", "locked" => "0" },
   { "asset" => "HIPPO", "free" => "938.04548872", "locked" => "0" },
   { "asset" => "IOST", "free" => "501.58762862", "locked" => "0" },
   { "asset" => "LAT", "free" => "4.74383301", "locked" => "0" },
   { "asset" => "MATIC", "free" => "0", "locked" => "0" },
   { "asset" => "NPC", "free" => "207.79756853", "locked" => "0" },
   { "asset" => "PHP", "free" => "0.23", "locked" => "0" },
   { "asset" => "PHPC", "free" => "0", "locked" => "0" },
   { "asset" => "POL", "free" => "0", "locked" => "0" },
   { "asset" => "SUI", "free" => "0", "locked" => "0" },
   { "asset" => "SUNDOG", "free" => "56.78464308", "locked" => "0" },
   { "asset" => "USDT", "free" => "108.00901091", "locked" => "0" },
   { "asset" => "XRP", "free" => "0.002223", "locked" => "0" },],
      "token" => "PHP",
      "daily" => { "cashInLimit" => "1000000", "cashInRemaining" => "1000000", "cashOutLimit" => "1000000",
                   "cashOutRemaining" => "1000000", "totalWithdrawLimit" => "1000000", "totalWithdrawRemaining" => "1000000" },
      "monthly" => { "cashInLimit" => "30000000", "cashInRemaining" => "29992500", "cashOutLimit" => "30000000",
                     "cashOutRemaining" => "30000000", "totalWithdrawLimit" => "30000000", "totalWithdrawRemaining" => "29810144.77" },
      "annually" => { "cashInLimit" => "360000000", "cashInRemaining" => "359925509.54", "cashOutLimit" => "360000000",
                      "cashOutRemaining" => "360000000", "totalWithdrawLimit" => "360000000", "totalWithdrawRemaining" => "359696437.16" }
    }
  end
end
