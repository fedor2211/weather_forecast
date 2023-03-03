require 'uri'
require 'net/http'
require 'rexml/document'
require_relative 'lib/forecast'

if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

CITIES = [
  { name: 'Москва', id: 32277 },
  { name: 'Пермь', id: 59 },
  { name: 'Санкт-Петербург', id: 69 },
  { name: 'Новосибирск', id: 99 },
  { name: 'Орел', id: 115 },
  { name: 'Чита', id: 121 },
  { name: 'Братск', id: 141 },
  { name: 'Краснодар', id: 34356 }
].freeze

puts 'Погоду для какого города Вы хотите узнать?'
CITIES.each.with_index(1) do |city, index|
  puts "#{index}: #{city[:name]}"
end

city = gets.chomp
unless ('1'..CITIES.size.to_s).include?(city)
  abort 'Неправильный ввод. Попробуйте ещё раз.' 
end

city_id = CITIES[city.to_i - 1][:id]

uri = URI.parse("https://www.meteoservice.ru/en/export/gismeteo?point=#{city_id}")

response = Net::HTTP.get_response(uri)

unless response.code[0] == '2'
  abort "Error #{response.code}. Exiting program."
end

doc = REXML::Document.new(response.body)

city_name = URI.decode_www_form_component(
  doc.root.elements['REPORT/TOWN'].attributes['sname']
)

forecasts = []
doc.root.elements.each('REPORT/TOWN/FORECAST') do |elem|
  forecasts << Forecast.from_xml_node(elem)
end

puts city_name
forecasts.each do |forecast|
  puts
  puts forecast
end
