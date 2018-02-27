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




db = SQLite3::Database.new ":memory:"
sql = <<-SQL
  create table guests(
    year integer,
    occupation text,
    show_date datetime,
    genre text,
    name texts
  )
SQL
db.execute(sql)
# puts "#{db.execute('.tables')}"  #not work
# puts "#{db.execute('.schema')}"  #not work
# puts "#{db.execute('select * from guests')}"  #currently empty
# sql = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"  #show tables  ie .tables
# puts "#{db.execute(sql)}" #[["guests"]]


CSV.foreach("./daily_show_guests.csv") do |row|  #./relative to where you run the file. ERRORNO file from ../ but ./ was ok
  puts "#{row}"
  db.execute "insert into guests values ( ?, ? ,?,?,?)", row[0],row[1],row[2],row[3],row[4]
end #foreach

puts "#{db.execute('select * from guests Limit 2    ')}"
# [["YEAR", "GoogleKnowlege_Occupation", "Show", "Group", "Raw_Guest_List"], [1999, "actor", "1/11/99", "Acting", "Michael J. Fox"]]
