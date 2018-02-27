# Parse the CSV and seed the database here! Run 'ruby db/seed' to execute this code.
# First, in the seed.rb file, write a script to convert the rows of this CSV into a SQL database
# that we can run queries against.
# How you model the domain is up to you - think about what will make this easy.
# You will need to create a connection to your database in the config/environment.rb file.


# Write methods to return SQL queries in the 'lib/queries.rb' file. Test them out by running rake console


# First, in the seed.rb file,
# write a script to convert the rows of this CSV into a SQL database that we can run queries against.
#  How you model the domain is up to you - think about what will make this easy.
#  You will need to create a connection to your database in the config/environment.rb file.

# 1999,rock band,11/29/99,Musician,Goo Goo Dolls
# 1999,television personality,10/5/99,Media,Maury Povich

require "sqlite3"
require 'csv'

#FILE READ COMPLETED
db = SQLite3::Database.new ":memory:"
CSV.foreach("./daily_show_guests.csv") do |row|  #./relative to where you run the file. ERRORNO file from ../ but ./ was ok
  puts "#{row}"
end #foreach
