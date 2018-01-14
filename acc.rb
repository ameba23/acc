require 'httparty'
require 'pry'
require 'csv'


# manage assets from csv
# todo -destinguish between spent and holding?

def bittrex_rates
  HTTParty.get("https://bittrex.com/api/v1.1/public/getmarketsummaries").parsed_response
end
def coins_by_bittrex
  bittrex_rates["result"].compact.map do |market|
    market["MarketName"].split("-").last
  end
end

def fiat_btc_rate(coinbase_rates, iso_currency = nil)

   1.0 / coinbase_rates["data"]["rates"][iso_currency || code].to_f
end

def displayrow(curr,btc_amount)
  puts " #{curr[0]} #{curr[1]} = BTC %.5f #{curr[2]}" % btc_amount
end

total = 0.0
data = CSV.read('figs.csv')

rates_got = {}

coinbase_rates = HTTParty.get("https://api.coinbase.com/v2/exchange-rates?currency=BTC").parsed_response

data.each do |row|
  if ['GBP','EUR','USD'].include?(row[0])
    if !rates_got.key?(row[0])
       rates_got[row[0]] = fiat_btc_rate(coinbase_rates, row[0])
    end
    the_rate = rates_got[row[0]]
    btc_amount = row[1].to_f * the_rate
    displayrow(row, btc_amount)
    total += btc_amount
  else
    if row[0] == 'BTC' 
      displayrow(row, row[1].to_f)
      total += row[1].to_f
    else
      if !rates_got.key?(row[0])
         rates_got[row[0]] = fiat_btc_rate(coinbase_rates, row[0])
      end
      the_rate = rates_got[row[0]]
      btc_amount = row[1].to_f * the_rate
      displayrow(row, btc_amount)
      total += btc_amount
    end
  end
end
puts "-----------------------------------"
puts "total gain in btc: %.5f " % total
eurrate = fiat_btc_rate(coinbase_rates, "EUR")
puts "btc to euro rate: %.2f" % eurrate
totaleur = total / eurrate
#puts "total in eur: #{totaleur.truncate(2).to_s('F')}"
puts "total gain in eur: %.2f" % totaleur

binding.pry
