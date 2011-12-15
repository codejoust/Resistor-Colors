require 'rubygems'
require 'sinatra'
COLORS = {'black'=> 0, 'brown'=> 1, 'red'=> 2, 'orange'=> 3, 'yellow'=> 4, 'green'=> 5, 'blue'=> 6, 'violet'=> 7, 'grey'=> 8, 'white'=> 9}
COLOR_VALS = {}
MULTIPLIERS = {'silver'=> 0.01, 'gold'=> 0.1, 'black'=> 1, 'brown'=> 10, 'red'=> 100, 'orange'=> 1000, 'yellow'=> 10000, 'green'=> 100000, 'blue'=> 1000000, 'violet'=> 10000000}
MULTIS = {-2 => 'silver', -1 => 'gold', 0 => 'black', 1=> 'brown', 2=> 'red', 3=> 'orange', 4=>'yellow', 5=>'green', 6=>'blue', 7=>'violet'}

COLORS.each_pair do |k,v|
  COLOR_VALS[v] = k
end

get '/' do
  return 'hello'
  erb :index
end

get '/color/:color' do |color|
  colors = color.split(/^[A-Za-z]+/)
  colors.inspect
end

get /([0-9]+)(\.[0-9]+)?(k|m|K|M)?/ do 
  url_h = params[:captures]
  num = url_h[0].to_i
  num += url_h[1].to_f unless url_h[1].nil?
  num *= 1000 if (url_h[2] and url_h[2].downcase == 'k')
  num *= 1000000 if (url_h[2] and url_h[2].downcase == 'm')
  return "finding resistor #{num}, #{url_h.inspect}, #{num_2_color(num).inspect}"
end

def num_2_color(num_in)
  dec, digit1, digit2 = calc_dec(num_in)
  [COLOR_VALS[digit1], COLOR_VALS[digit2], MULTIS[dec]]
end

def calc_dec(num_in)
  out = sprintf('%e',num_in).match(/([0-9])\.([0-9])[0-9]+e((\+|\-)[0-9]+)/)
  return [out[3].to_i, out[1].to_i, out[2].to_i]
end

post '/' do
  
end
