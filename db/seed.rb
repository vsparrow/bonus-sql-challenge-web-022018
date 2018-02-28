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
# require_relative "../config/environment.rb"


# QUICKTIME **********************************
#mpg to gif
# DB = SQLite3::Database.new ":memory:"
DB = {:conn => SQLite3::Database.new(":memory")}
DB[:conn].execute("DROP TABLE IF EXISTS guests")

sql = <<-SQL
  create table guests(
    year integer,
    profession text,
    show_date datetime,
    genre text,
    name text
    -- id INTEGER PRIMARY KEY
  )
SQL
DB[:conn].execute(sql)
# puts "#{db.execute('.tables')}"  #not work
# puts "#{db.execute('.schema')}"  #not work
# puts "#{db.execute('select * from guests')}"  #currently empty
# sql = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"  #show tables  ie .tables
# puts "#{db.execute(sql)}" #[["guests"]]


CSV.foreach("./daily_show_guests.csv") do |row|  #./relative to where you run the file. ERRORNO file from ../ but ./ was ok
  # puts "#{row}"
  DB[:conn].execute "insert into guests values ( ?, ? ,?,?,?)", row[0],row[1],row[2],row[3],row[4] #MAKE EXPLICIT
end #foreach

# puts "#{db.execute('select * from guests Limit 2    ')}"
# [["YEAR", "GoogleKnowlege_Occupation", "Show", "Group", "Raw_Guest_List"], [1999, "actor", "1/11/99", "Acting", "Michael J. Fox"]]
DB[:conn].execute('delete from guests where profession="GoogleKnowlege_Occupation"') #removes the first row that we dont want
# puts "#{DB[:conn].execute('select * from guests Limit 2 ')}"

# **********************************************************************place in queries

class Show# < ActiveRecord::Base
  def guest_with_most_appearances #******************************************************COMPLETED
    sql = <<-SQL
      select name, count(name) from guests GROUP by name having count(name) > 0
      order by count(name) DESC LIMIT 1
      SQL
    returnval=DB[:conn].execute(sql)
    returnval[0][0]
  end #guest_with_most_appearances

  def popular_column_of_all_time(column) # ***************************************************
    all_years = self.years_show_hosted
    puts "#{all_years}" # [[1999], [2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008], [2009], [2010], [2011], [2012], [2013], [2014], [2015]]
    popular_column_array = self.popular_profession_of_each_year(column)
    puts "#{popular_column_array}"
  end

  def popular_column_of_year(column,year) # *********************************************COMPLETED
    sql = <<-SQL
    select #{column},count(#{column}) from guests
    WHERE year = #{year}
    GROUP by #{column} having count(#{column}) > 0
    order by count(#{column}) DESC LIMIT 1
    SQL
    returnval=DB[:conn].execute(sql)
    returnval[0] # [column_value,count]
  end #popular_profession_of_year

  def popular_profession_of_each_year
    puts "METHOD: popular_profession_of_each_year"
    years = years_show_hosted
    # puts "#{years}" #[[1999], [2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008], [2009], [2010], [2011], [2012], [2013], [2014], [2015]]
    profession_array = []
    years.each do |year|
      popular = popular_column_of_year("profession",year[0])
      profession_array << [popular,year]
      puts "The most popular profession of #{year} is #{popular[0][0]}" #[[1999], [2000], [2001], [2002], [2003], [2004], [2005], [2006], [2007], [2008], [2009], [2010], [2011], [2012], [2013], [2014], [2015]]
    end #each
    # puts "****#{profession_array}" #[[[["actor", 53]], [1999]], [[["actor", 61]], [2000]], [[["actor", 62]], [2001]], [[["actor", 64]], [2002]], [[["actor", 47]], [2003]], [[["actor", 31]], [2004]], [[["actor", 25]], [2005]], [[["actor", 33]], [2006]], [[["actor", 15]], [2007]], [[["actor", 20]], [2008]], [[["actor", 19]], [2009]], [[["actor", 30]], [2010]], [[["actor", 29]], [2011]], [[["actor", 20]], [2012]], [[["actor", 37]], [2013]], [[["actor", 31]], [2014]], [[["actor", 19]], [2015]]]
    profession_array
  end #end popular_profession_of_each_year
  def years_show_hosted
    sql = "Select distinct year from guests"
    returnval=DB[:conn].execute(sql)
  end #years_show_hosted

  def count_people_with_the_first_name_bill #***************************************COMPLETED
    sql = <<-SQL
      select count(name) from guests
      where name Like 'Bill%'
      SQL
    count = DB[:conn].execute(sql)[0][0]
    # puts "*********count_people_with_the_first_name_bill #{count}"
    count
  end #people_with_the_first_name_bill

end #class


# *****************
show=Show.new

puts "show.guest_with_most_appearances : #{show.guest_with_most_appearances}"
puts "helper show.years_show_hosted : #{show.years_show_hosted}"
puts "helper show.popular_column_of_year(column,YEAR_integer) : #{show.popular_column_of_year("profession",1999)}"
puts "show.count_people_with_the_first_name_bill : #{show.count_people_with_the_first_name_bill}"
# show.popular_profession_of_each_year
# show.popular_column_of_all_time("profession")
