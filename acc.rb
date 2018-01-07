require 'httparty'
require 'pry'
require 'csv'

def bittrex_rates
  HTTParty.get("https://bittrex.com/api/v1.1/public/getmarketsummaries").parsed_response
end
def coins_by_bittrex
  bittrex_rates["result"].compact.map do |market|
    market["MarketName"].split("-").last
  end
end

def fiat_btc_rate(iso_currency = nil)

   1.0 / coinbase_rates["data"]["rates"][iso_currency || code].to_f
end

def coinbase_rates
  HTTParty.get("https://api.coinbase.com/v2/exchange-rates?currency=BTC").parsed_response
end

total = 0.0
data = CSV.read('figs.csv')

data.each do |row|
  if ['GBP','EUR','USD'].include?(row[0])
    btc_amount = row[1].to_f * fiat_btc_rate(row[0])
    puts " #{row[0]} #{row[1]} = BTC #{btc_amount}"
    total += btc_amount
  else
    if row[0] == 'BTC' 
      puts " #{row[0]} #{row[1]} = BTC #{row[1].to_f}"
      total += row[1].to_f
    else
      btc_amount = row[1].to_f * fiat_btc_rate(row[0])
      puts " #{row[0]} #{row[1]} = BTC #{btc_amount}"
      total += btc_amount
    end
  end
end
puts "total gain in btc: #{total}"
eurrate = fiat_btc_rate("EUR")
puts "btc to euro rate: %.2f" % eurrate
totaleur = total / eurrate
#puts "total in eur: #{totaleur.truncate(2).to_s('F')}"
puts "total gain in eur: %.2f" % totaleur

binding.pry
