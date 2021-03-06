#Relational data (Chapter 13) - exercises 

##Intro

library("tidyverse")
library("nycflights13")

install.packages('datamodelr')
library("datamodelr")

########### nycflights13 ###########

#1. Imagine you wanted to draw (approximately) the route each plane flies from its origin to its destination. 
#What variables would you need? 
#What tables would you need to combine?

  #flights table: origin and destination 
  #airports table: longitude and latitude variables
  #We would merge the flights with airports twice: once to get the location of the origin airport, and once to get the location of the destination airport.

#2. I forgot to draw the relationship between weather and airports. 
#What is the relationship and how should it appear in the diagram?

  #The variable origin in weather is matched with faa in airports.

#3. weather only contains information for the origin (NYC) airports. 
#If it contained weather records for all airports in the USA, what additional relation would it define with flights?

  #year, month, day, hour, origin in weather would be matched to year, month, day, hour, dest in flight (though it should use the arrival date-time values for dest if possible).

#4. We know that some days of the year are “special”, and fewer people than usual fly on them. 
#How might you represent that data as a data frame? 
#What would be the primary keys of that table? 
#How would it connect to the existing tables?

  #I would add a table of special dates. 
  #The primary key would be date. 
  #It would match to the year, month, day columns of `flights'.

########### Keys ###########

#1. Add a surrogate key to flights.

#If a table lacks a primary key (unique ID numbers), it’s sometimes useful to add one with mutate() and row_number(). 
#That makes it easier to match observations if you’ve done some filtering and want to check back in with the original data. 
#This is called a surrogate key

  #Add the column flight_id as a surrogate key. 
  #I sort the data prior to making the key, even though it is not strictly necessary, so the order of the rows has some meaning.

flights %>% 
  arrange(year, month, day, sched_dep_time, carrier, flight) %>%
  mutate(flight_id = row_number()) %>%
  glimpse()

#2. Identify the keys in the following datasets

#Lahman::Batting,
#babynames::babynames
#nasaweather::atmos
#fueleconomy::vehicles
#ggplot2::diamonds

  #The primary key for Lahman::Batting is playerID, yearID, stint. 
  #It is not simply playerID, yearID because players can have different stints in different leagues within the same year.

install.packages('Lahman')
library('Lahman')

Lahman::Batting %>%
  group_by(playerID, yearID, stint) %>%
  filter(n() > 1) %>%
  nrow()

  #The primary key for babynames::babynames is year, sex, name. 
  #It is no simply year, name since names can appear for both sexes with different counts.

install.packages('babynames')
library('babynames')

babynames::babynames %>%
  group_by(year, sex, name) %>%
  filter(n() > 1) %>%
  nrow()

  #The primary key for nasaweather::atmos is the location and time of the measurement: lat, long, year, month.

install.packages('nasaweather')
library('nasaweather')

nasaweather::atmos %>%
  group_by(lat, long, year, month) %>%
  filter(n() > 1) %>%
  nrow()

  #The column id (unique EPA identifier) is the primary key for fueleconomy::vehicles:

install.packages('fueleconomy')
library('fueleconomy')

fueleconomy::vehicles %>%
  group_by(id) %>%
  filter(n() > 1) %>%
  nrow()

  #There is no primary key for ggplot2::diamonds. 
  #Using all variables in the data frame, the number of distinct rows is less than the total number of rows, meaning no combination of variables uniquely identifies the observations.

ggplot2::diamonds %>%
  distinct() %>% 
  nrow()
nrow(ggplot2::diamonds)

#4. Draw a diagram illustrating the connections between the Batting, Master, and Salaries tables in the Lahman package. 
#Draw another diagram that shows the relationship between Master, Managers, AwardsManagers.

#Most flowchart or diagramming software can be used used to create database schema diagrams. 
#For example, the diagrams in R for Data Science were created with Gliffy.

#You can use anything to create these diagrams, but I’ll use an R-centric solution. 
#The package datamodelr can programmatically create data models from R.

#For the Batting, Master, and Salaries tables:
  
    ##Master
  #Primary keys: playerID
  #Batting
  #Primary keys: yearID, yearID, stint
  #Foreign Keys:
    #playerID = Master$playerID (many-to-1)
  #Salaries:
    #Primary keys: yearID, teamID, playerID
  #Foreign Keys
  #playerID = Master$playerID (many-to-1)

install.packages('datamodelr')

dm1 <- dm_from_data_frames(list(Batting = Lahman::Batting, 
                                Master = Lahman::Master, 
                                Salaries = Lahman::Salaries)) %>%
  dm_set_key("Batting", c("playerID", "yearID", "stint")) %>%
  dm_set_key("Master", "playerID") %>%
  dm_set_key("Salaries", c("yearID", "teamID", "playerID")) %>%
  dm_add_references(
    Batting$playerID == Master$playerID,
    Salaries$playerID == Master$playerID
  )

dm_create_graph(dm1, rankdir = "LR", columnArrows = TRUE)

##datamodelr is not available for the latest version of R ://

########### Mutating Joins ###########

library('dplyr')
install.packages('flights')
install.packages('nycflights13')
library('flights')

flights2 <- nycflights13::flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier)

#1. Compute the average delay by destination, then join on the airports data frame so you can show the spatial distribution of delays. 

#Here’s an easy way to draw a map of the United States:

airports %>%
  semi_join(flights2, c("faa" = "dest")) %>%
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point() +
  coord_quickmap()

avg_dest_delays <-
  flights %>%
  group_by(dest) %>%
  # arrival delay NA's are cancelled flights
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  inner_join(airports, by = c(dest = "faa"))

avg_dest_delays %>%
  ggplot(aes(lon, lat, colour = delay)) +
  borders("state") +
  geom_point() +
  coord_quickmap()

#2. Add the location of the origin and destination (i.e. the lat and lon) to flights.

flights %>%
  left_join(airports, by = c(dest = "faa")) %>%
  left_join(airports, by = c(origin = "faa")) %>%
  head()

#3. Is there a relationship between the age of a plane and its delays?
  
  #Surprisingly not. 
  #If anything (departure) delay seems to decrease slightly with the age of the plane. 
  #This could be due to choices about how airlines allocate planes to airports.

#4. What weather conditions make it more likely to see a delay?
  
  #Almost any amount or precipitation is associated with a delay, though not as strong a trend after 0.02 in as one would expect

flight_weather <-
  flights %>%
  inner_join(weather, by = c("origin" = "origin",
                             "year" = "year",
                             "month" = "month",
                             "day" = "day",
                             "hour" = "hour"))

flight_weather %>%
  group_by(precip) %>%
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = precip, y = delay)) +
  geom_line() + geom_point()

#5. What happened on June 13 2013? 
#Display the spatial pattern of delays, and then use Google to cross-reference with the weather.

  #There was a large series of storms (derechos) in the southeastern US (see June 12-13, 2013 derecho series)
  #The largest delays are in Tennessee (Nashville), the Southeast, and the Midwest, which were the locations of the derechos:

library(viridis)

flights %>%
  filter(year == 2013, month == 6, day == 13) %>%
  group_by(dest) %>%
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  inner_join(airports, by = c("dest" = "faa")) %>%
  ggplot(aes(y = lat, x = lon, size = delay, colour = delay)) +
  borders("state") +
  geom_point() +
  coord_quickmap() + 
  scale_color_viridis()

########### Filtering Joins ###########

#1. What does it mean for a flight to have a missing tailnum? 
#What do the tail numbers that don’t have a matching record in planes have in common? (Hint: one variable explains ~90% of the problems.)

#American Airlines (AA) and Envoy Airlines (MQ) don’t report tail numbers.

flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(carrier, sort = TRUE)

#2. Filter flights to only show flights with planes that have flown at least 100 flights.

planes_gt100 <- 
  filter(flights) %>%
  group_by(tailnum) %>%
  count() %>%
  filter(n > 100)

flights %>%
  semi_join(planes_gt100, by = "tailnum")

#3. Combine fueleconomy::vehicles and fueleconomy::common to find only the records for the most common models.

  #The table fueleconomy::common identifies vehicles by make and model:

glimpse(fueleconomy::vehicles)
glimpse(fueleconomy::common)

fueleconomy::vehicles %>%
  semi_join(fueleconomy::common, by = c("make", "model"))

#3. Find the 48 hours (over the course of the whole year) that have the worst delays. 
#Cross-reference it with the weather data. Can you see any patterns?

flights %>%
  group_by(year, month, day) %>%
  summarise(total_24 = sum(dep_delay, na.rm = TRUE)+ sum(arr_delay, na.rm = TRUE)) %>%
  mutate(total_48 = total_24 + lag(total_24)) %>%
  arrange(desc(total_48))
  
#4. What does anti_join(flights, airports, by = c("dest" = "faa")) tell you? 
#What does anti_join(airports, flights, by = c("faa" = "dest")) tell you?
  
  #anti_join(flights, airports, by = c("dest" = "faa")) are flights that go to an airport that is not in FAA list of destinations, likely foreign airports.
  #anti_join(airports, flights, by = c("faa" = "dest")) are US airports that don’t have a flight in the data, meaning that there were no flights to that airport from New York in 2013.

#5. You might expect that there’s an implicit relationship between plane and airline, because each plane is flown by a single airline. 
#Confirm or reject this hypothesis using the tools you’ve learned above.

  #There isn’t such a relationship over the lifetime of an airplane since planes can be sold or leased and airlines can merge. 
  #It should be the case that an airplane is associated with only airline at a given time, though may However, even thogh that’s a possibility, it doesn’t necessarily mean that plane associated with more than one appear in this data. 

#Let’s check:

airplane_multi_carrier <- 
  flights %>%
  group_by(tailnum, carrier) %>%
  count() %>%
  filter(n() > 1) %>%
  select(tailnum) %>%
  distinct()

airplane_multi_carrier

#There are 0 airplanes in this dataset that have had more than one carrier. 
#Even if there were none, the substantive reasons why an airplane could have more than one carrier would hold.

#It is quite possible that we could have looked at the data, seen that each airplane only has one carrier, not thought much about it, and proceeded with some analysis that implicitly or explicitly relies on that one-to-one relationship. 
#Then we apply our analysis to a larger set of data where that one-to-one relationship no longer holds, and it breaks. 
#There is rarely a substitute for understanding the data which you are using as an analyst.