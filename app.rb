require 'rubygems'
require 'sinatra'
require 'json'

$hostname = 'resistor.heroku.com'

COLORS = {'black'=> 0, 'brown'=> 1, 'red'=> 2, 'orange'=> 3, 'yellow'=> 4, 'green'=> 5, 'blue'=> 6, 'violet'=> 7, 'grey'=> 8, 'white'=> 9}
COLOR_VALS = {}
MULTIPLIERS = {'silver'=> 0.01, 'gold'=> 0.1, 'black'=> 1, 'brown'=> 10, 'red'=> 100, 'orange'=> 1000, 'yellow'=> 10000, 'green'=> 100000, 'blue'=> 1000000, 'violet'=> 10000000}
MULTIS = {-2 => 'silver', -1 => 'gold', 0 => 'black', 1=> 'brown', 2=> 'red', 3=> 'orange', 4=>'yellow', 5=>'green', 6=>'blue', 7=>'violet'}

COLORS.each_pair do |k,v|
  COLOR_VALS[v] = k
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :index
end

get '/common' do
  common_ary = '2k 2.3k 200 100 120 5k 150 70 200 240 220 2k 330 4.7k 300 100 470k 1m 10k 22 22k 3.3k'
  @common = common_ary.split(' ').map do |value|
    [value, num_2_color(value.sub('k', '000').sub('m', '000000'))]
  end
  erb :list_codes
end

get '/common/more' do
  @common = []
  @more = true
  (0..900).step(10) do |num|
    @common.push([num, num_2_color(num)])
  end
  (0..10).each do |num|
    @common.push([num.to_s + 'k', num_2_color(num * 1000)])
    @common.push([num.to_s + 'm', num_2_color(num * 1000000)])
  end
  @title = 'More resistor values'
  erb :list_codes
end

get '/color/:color' do |color|
  colors = color.split(/^[A-Za-z]+/)
  colors.inspect
end

get '/get_resistor' do
  input = params[:resistor_val]
  if input.match(/([0-9]+)(\.[0-9]+)?(k|m|K|M)?/)
    redirect '/' + input
  else
    @query = input
    erb :index
  end
end

get /^\/([0-9]+)(\.[0-9]+)?(k|m|K|M)?(.*)/ do 
  url_h = params[:captures]
  num = url_h[0].to_i
  num += url_h[1].to_f unless url_h[1].nil?
  num *= 1000 if (url_h[2] and url_h[2].downcase == 'k')
  num *= 1000000 if (url_h[2] and url_h[2].downcase == 'm')
  @colors = num_2_color(num)
  dec = calc_dec(num)
  #@num = num#"#{dec[1]}#{dec[2]} x 10^#{dec[0]}"
  @num = ((dec[1] + (dec[2] * 0.1)) * 10**dec[0]).to_i.to_s.sub(/000000$/,'m').sub(/000$/, 'k')
  if @num != request.path_info[1..-1]
    redirect '/' + @num
    return
  end
  @title = 'Color code for ' + @num
  if url_h[-1] == '.json'
    content_type :json
    return {:text => @num, :colors => @colors, :num => dec}.to_json
  else
    erb :resistor
  end
  #return "finding resistor #{num}, #{url_h.inspect}, #{num_2_color(num).inspect}"
end

def num_2_color(num_in)
  dec, digit1, digit2 = calc_dec(num_in)
  [COLOR_VALS[digit1], COLOR_VALS[digit2], MULTIS[dec] || 'Invalid!']
end

def calc_dec(num_in)
  out = sprintf('%e',num_in).match(/([0-9])\.([0-9])[0-9]+e((\+|\-)[0-9]+)/)
  return [out[3].to_i, out[1].to_i, out[2].to_i]
end

post '/' do
  
end
