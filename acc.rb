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
   BigDecimal('1.0') / BigDecimal.new(
    coinbase_rates["data"]["rates"][iso_currency || code]
   )
end

def coinbase_rates
  HTTParty.get("https://api.coinbase.com/v2/exchange-rates?currency=BTC").parsed_response
end

total = BigDecimal('0')
data = CSV.read('figs.csv')
data.each do |row|
  puts "#{row}"
  if ['GBP','EUR','USD'].include?(row[0])
    puts "is fiat"
    btc_amount = BigDecimal(row[1]) * fiat_btc_rate(row[0])
    puts "#{btc_amount}"
    total += btc_amount
  else
    if row[0] == 'BTC' 
      puts "adding #{row[1].to_f}"
      total += row[1].to_f
    else
      btc_amount = BigDecimal(row[1]) * fiat_btc_rate(row[0])
      puts "non fiat: #{btc_amount}"
      total += btc_amount
    end
  end
end
puts "total in btc: #{total}"
eurrate = fiat_btc_rate("EUR")
puts "euro rate #{eurrate}"
totaleur = total * eurrate
#puts "total in eur: #{totaleur.truncate(2).to_s('F')}"
puts "total in eur: %.2f" % totaleur
binding.pry
