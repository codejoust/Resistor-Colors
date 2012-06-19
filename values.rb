# Values.rb

# Resistor color lookup tables

COLORS = {
  'black'=> 0, 'brown'=> 1, 'red'=> 2,
  'orange'=> 3, 'yellow'=> 4, 'green'=> 5,
  'blue'=> 6, 'purple'=>7, 'violet'=> 7,
  'grey'=> 8, 'white'=> 9
}


MULTIPLIERS = {
  'silver'=> -2, 'gold'=> -1, 'black'=> 0,
  'brown'=> 1, 'red'=> 2, 'orange'=> 3,
  'yellow'=> 4, 'green'=> 5, 'blue'=> 6,
  'violet'=> 7
}

# Parse inverses

COLOR_VALS = {}
MULTIPLIER_VALS = {}

COLORS.each_pair do |k,v|
  COLOR_VALS[v] = k
end
MULTIPLIERS.each_pair do |k,v|
  MULTIPLIER_VALS[v] = k
end

