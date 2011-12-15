require 'rubygems'
require 'sinatra'
COLORS = {'black'=> 0, 'brown'=> 1, 'red'=> 2, 'orange'=> 3, 'yellow'=> 4, 'green'=> 5, 'blue'=> 6, 'violet'=> 7, 'grey'=> 8, 'white'=> 9}
COLOR_VALS = {}
MULTIPLIERS = {'silver'=> 0.01, 'gold'=> 0.1, 'black'=> 1, 'brown'=> 10, 'red'=> 100, 'orange'=> 1000, 'yellow'=> 10000, 'green'=> 100000, 'blue'=> 1000000, 'violet'=> 10000000}
MULTIS = {-2 => 'silver', -1 => 'gold', 'black' => 0, 'brown' => 1, 'red' => 2, 'orange' => 3, 'yellow' => 4, 'green' => 5, 'blue' => 6, 'violet' => 7}

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
  dec, val = calc_dec(num_in)
  print "\n- dec: #{dec},val: #{val}\n"
  val = val.to_s
  digit_1 = 0; digit_2 = 0
  if val.length == 1
    digit_1 = val
  else
    digit_1 = val.to_s[0]
    digit_2 = val.to_s[1]
  end
  [COLOR_VALS[digit_1], COLOR_VALS[digit_2], MULTIS[dec]]
end

def calc_dec(num_in)
  num_in = num_in
  dec = 0
  if (dec < 10)
    while ((num_in * 10) % 10 != 0)
      num_in *= 10
      dec -= 1
    end
  else
    while ((num_in % 10) == 0)
      num_in /= 10
      dec += 1
    end
  end
  return [dec, num_in]
end

post '/' do
  
end
