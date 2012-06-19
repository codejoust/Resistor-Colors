require 'rubygems'
require 'sinatra'
require 'json'
require './values.rb'

$hostname = 'resistor.heroku.com'


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
  (10..900).step(10) do |num|
    @common.push([num, num_2_color(num)])
  end
  (1..10).each do |num|
    @common.push([num.to_s + 'k', num_2_color(num * 1000)])
    @common.push([num.to_s + 'm', num_2_color(num * 1000000)])
  end
  @title = 'More resistor values'
  erb :list_codes
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

get '/get_color' do
  input = params[:color_val]
  if input.match(/^([A-Za-z]+)(?: |,|\||\-)([A-Za-z]+)(?: |,|\||\-)([A-Za-z]+)$/)
    redirect '/' + input
  else
    @color = input
    erb :index
  end
end

get '/partial_color' do
  redirect '/' + [params[:color1], params[:color2], params[:multiplier]].join('-')
end

get /^\/([0-9]+)(\.[0-9]+)?(k|m|K|M)?(.*)/ do 
  url_h = params[:captures]
  num = url_h[0].to_i
  num += url_h[1].to_f unless url_h[1].nil?
  num *= 1000 if (url_h[2] and url_h[2].downcase == 'k')
  num *= 1000000 if (url_h[2] and url_h[2].downcase == 'm')
  dec = calc_dec(num)
  @colors = val_2_color(*dec)
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

get /^\/([A-Za-z]+)(?:\ |,|\||\-)([A-Za-z]+)(?:\ |,|\||\-)([A-Za-z]+)$/ do
  colors = params[:captures]
  num1, num2, multi = COLORS[colors[0]], COLORS[colors[1]], MULTIPLIERS[colors[2]]
  if (num1 && num2 && multi)
    @colors = [colors[0], colors[1], colors[2]]
    @num = ((num1 + (num2 * 0.1)) * 10**multi).to_i.to_s.sub(/000000$/,'m').sub(/000$/, 'k')
    erb :resistor
  else
    raise Sinatra::NotFound
    "Invalid Colors"
  end
end

def num_2_color(num)
  val_2_color(*calc_dec(num))
end

def val_2_color(dec, digit1, digit2)
  [COLOR_VALS[digit1], COLOR_VALS[digit2], MULTIPLIER_VALS[dec - 1] || 'Invalid!']
end

def calc_dec(num_in)
  out = sprintf('%e',num_in).match(/([0-9])\.([0-9])[0-9]+e((\+|\-)[0-9]+)/)
  return [out[3].to_i, out[1].to_i, out[2].to_i]
end

not_found do
  erb :not_found
end
