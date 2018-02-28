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

  def popular_column_of_all_time(column) # *********************************************COMPLETED
    sql = <<-SQL
    select #{column},count(#{column}) from guests
    GROUP by #{column} having count(#{column}) > 0
    order by count(#{column}) DESC LIMIT 1
    SQL
    returnval=DB[:conn].execute(sql)
    returnval[0] # [column_value,count]
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

  def popular_profession_of_each_year # **************************************************COMPLETED
    # puts "METHOD: popular_profession_of_each_year"
    years = self.years_show_hosted
    profession_array = []
    years.each do |year|
      profession = popular_column_of_year("profession",year[0])
      profession_array << [profession[0],year[0]]
    end #each
    profession_array
  end #end popular_profession_of_each_year
  def years_show_hosted
    sql = "Select distinct year from guests"
    returnval=DB[:conn].execute(sql)
  end #years_show_hosted

  def count_people_with_the_first_name_bill #***************************************COMPLETED
    sql = <<-SQL
      select count(name) from guests
      where name Like '%Bill%'
      SQL
    count = DB[:conn].execute(sql)[0][0]
    # puts "*********count_people_with_the_first_name_bill #{count}"
    count
  end #people_with_the_first_name_bill

  # What dates did Patrick Stewart appear on the show?
  def dates_guest_appeared_on_show(findguest)
    sql = <<-SQL
      select show_date from guests
      where name = "#{findguest}"
    SQL
    dates = DB[:conn].execute(sql) # [["4/12/00"], ["4/21/03"], ["11/7/13"]]
  end

  # Which year had the most guests?
  def year_with_the_most_guests # *********************************************** COMPLETED
    # "inside year_with_the_most_guests"
    years = self.years_show_hosted
    sql = <<-SQL
      select count(name) from guests
      where year = ?
    SQL
    guest_count = []
    years.each do |year|
      count = DB[:conn].execute(sql,year)[0][0]
      # puts "#{count}, #{year[0]}"
      guest_count << [count,year[0]]
    end
    # puts "#{guest_count}"
    highest_guest = 0
    highest_year = 0
    guest_count.each do |count_and_year|
      if count_and_year[0] > highest_guest
        highest_guest = count_and_year[0]
        highest_year = count_and_year[1]
      end
    end
    highest_year
    # some dates had more than one guest
    # if and then add 1
    # if also add 1
    # if band minus 1 (for the 1 added)
  end

  # What was the most popular "Group" for each year Jon Stewart hosted?
  def most_popular_group_each_year
    # x =DB[:conn].execute("PRAGMA table_info(guests) ")
    # puts x
    years = self.years_show_hosted
    # puts "#{years}"
    group_and_year = []
    years.each do |year|
      popular_genre = [popular_column_of_year("genre",year[0])[0],year[0]]
      # puts "#{popular_genre}"
      # puts popular_genre
      # grou
      group_and_year << popular_genre
    end #each
    group_and_year
  end #most_popular_group_each_year

end #class


# *****************
show=Show.new

puts "show.guest_with_most_appearances : #{show.guest_with_most_appearances}"
puts "***********************************************"
puts "helper show.years_show_hosted : #{show.years_show_hosted}"
puts "***********************************************"
puts "helper show.popular_column_of_year(column,YEAR_integer) : #{show.popular_column_of_year("profession",1999)}"
puts "***********************************************"
puts "show.count_people_with_the_first_name_bill : #{show.count_people_with_the_first_name_bill}"
puts "***********************************************"
puts "show.popular_profession_of_each_year : #{show.popular_profession_of_each_year}"
puts "***********************************************"
puts "show.popular_column_of_all_time(column) : profession : #{show.popular_column_of_all_time('profession')}"
puts "***********************************************"
  puts "show.dates_guest_appeared_on_show(guest) : Patrick Stewart : #{show.dates_guest_appeared_on_show('Patrick Stewart')}"
puts "***********************************************"
puts "show.year_with_the_most_guests : #{show.year_with_the_most_guests}"
puts "***********************************************"
puts "  # What was the most popular group for each year Jon Stewart hosted?"
puts "show.most_popular_group_each_year : #{show.most_popular_group_each_year}"
