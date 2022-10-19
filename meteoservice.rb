if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'net/http'
require 'rexml/document'
require_relative 'lib/meteoservice_forecast'

CITIES = {
    10556 => 'Польша: Гданьск',
    11056 => 'Португалия: Порту',
    917 => 'Испания: Аликанте'
}.invert.freeze

city_names = CITIES.keys

puts "Погоду какого города вы хотите узнать?"
city_names.each.with_index { | city, index| puts "#{index + 1}: #{city}" }
city_index = STDIN.gets.to_i
unless city_index.between?(1, city_names.size)
  city_index = STDIN.gets.to_i
  puts "Enter number from 1 to #{city_names.size}"
end
city_id = CITIES[city_names[city_index -1]]

URL = "https://www.meteoservice.ru/export/gismeteo/point/#{city_id}.xml".freeze

response = Net::HTTP.get_response(URI.parse(URL))
doc = REXML::Document.new(response.body)

city_name = URI.decode_www_form_component(doc.root.elements['REPORT/TOWN'].attributes['sname'])

forecast_nodes = doc.root.elements['REPORT/TOWN'].elements.to_a

puts
puts city_name

forecast_nodes.each do |node|
  puts MeteoserviceForecast.from_xml(node)
  puts
end
