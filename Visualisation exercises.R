#Data visualisation exercises - reading for week 6 class

#intro

library("tidyverse")

######### first steps #########

ggplot(data = mpg)

nrow(mtcars)
ncol(mtcars)

glimpse(mtcars)

?mpg

#Make a scatter plot of hwy vs cyl

ggplot(mpg, aes(x = hwy, y = cyl)) +
  geom_point()

#What happens if you make a scatter plot of class vs drv. Why is the plot not useful?

ggplot(mpg, aes(x = class, y = drv)) +
  geom_point()

#A scatter plot is not a useful way to plot these variables, 
#since both drv and class are factor variables taking a limited number of values.

count(mpg, drv, class)

######### Aesthetic mappings  #########

#1. What's wrong with this plot?

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))

  #Since color = "blue" was included within the mapping argument, it was treated as an aesthetic (a mapping between a variable and a value). 
  #The expression, color="blue", treats "blue" as a variable with only one value: "blue". 
  #If this is confusing, consider how color = 1:234 or color = 1 would be interpreted by aes().

#2. Which variables in mpg are categorical? Which variables are continuous?
  #How can you see this information when you run mpg?

mpg
glimpse(mpg)

#3. Map a continuous variable to color, size, and shape. 
  #How do these aesthetics behave differently for categorical vs. continuous variables?
  
  #The variable cty, city highway miles per gallon, is a continuous variable:
  
ggplot(mpg, aes(x = displ, y = hwy, color = cty)) +
  geom_point()

  #Instead of using discrete colors, the continuous variable uses a scale that varies from a light to dark blue color.

ggplot(mpg, aes(x = displ, y = hwy, size = cty)) +
  geom_point()

#When mapped to size, the sizes of the points vary continuously with respect to the size (although the legend shows a few representative values)

ggplot(mpg, aes(x = displ, y = hwy, shape = cty)) +
  geom_point()

  #When a continuous value is mapped to shape, it gives an error. 
  #Though we could split a continuous variable into discrete categories and use a shape aesthetic, this would conceptually not make sense. 
  #A continuous numeric variable is ordered, but shapes have no natural order. 
  #It is clear that smaller points correspond to smaller values, or once the color scale is given, which colors correspond to larger or smaller values. 
  #But it is not clear whether a square is greater or less than a circle.

#4. What happens if you map the same variable to multiple aesthetics?

ggplot(mpg, aes(x = displ, y = hwy, color = hwy, size = displ)) +
  geom_point()

  #In the above plot, hwy is mapped to both location on the y-axis and color, and displ is mapped to both location on the x-axis and size. 
  #The code works and produces a plot, even if it is a bad one. 
  #Mapping a single variable to multiple aesthetics is redundant. 
  #Because it is redundant information, in most cases avoid mapping a single variable to multiple aesthetics.

#5. What does the stroke aesthetic do? What shapes does it work with? 
#The following example is given in ?geom_point:
  
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 5)

#Stroke changes the color of the border for shapes (22-24).

#6. What happens if you map an aesthetic to something other than a variable name, like aes(colour = displ < 5)?

ggplot(mpg, aes(x = displ, y = hwy, colour = displ < 5)) + 
  geom_point()

  #Aesthetics can also be mapped to expressions (code like displ < 5). 
  #It will create a temporary variable which takes values from the result of the expression. 
  #In this case, it is logical variable which is TRUE or FALSE. 
  #This also explains exercise 1, color = "blue" created a categorical variable that only had one category: “blue”.

######### Facets  #########

#1. What happens if you facet on a continuous variable?

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() + 
  facet_grid(. ~ cty)

  #It converts the continuous variable to a factor and creates facets for all unique values of it.

#2. What do the empty cells in plot with facet_grid(drv ~ cyl) mean? How do they relate to this plot?
#They are cells in which there are no values of the combination of drv and cyl.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl))

  #The locations in the above plot without points are the same cells in facet_grid(drv ~ cyl) that have no points.

#3. What plots does the following code make? What does . do?
  
  #The symbol . ignores that dimension for faceting.

#This plot facets by values of drv on the y-axis:
  
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

#This plot facets by values of cyl on the x-axis:
  
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

#4. Read ?facet_wrap. What does nrow do? What does ncol do? What other options control the layout of the individual panels? Why doesn’t facet_grid() have nrow and ncol variables?
  
  #The arguments nrow (ncol) determines the number of rows (columns) to use when laying out the facets. 
  #It is necessary since facet_wrap only facets on one variable. 
  #These arguments are unnecessary for facet_grid since the number of rows and columns are determined by the number of unique values of the variables specified.

#5. When using facet_grid() you should usually put the variable with more unique levels in the columns. Why?
  
  #You should put the variable with more unique levels in the columns if the plot is laid out landscape. 
  #It is easier to compare relative levels of y by scanning horizontally, so it may be easier to visually compare these levels. 
  #I’m actually not sure about the correct answer to this.

######### Geometric objects  #########

#1. What geom would you use to draw a line chart? A boxplot? A histogram? An area chart?
  #line chart: geom_line
  #boxplot: geom_boxplot
  #histogram: geom_hist

#2. Run this code in your head and predict what the output will look like. Then, run the code in R and check your predictions.

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

#This will produce a scatter plot with displ on the x-axis, hwy on the y-axis. The points will be colored by drv. 
#There will be a smooth line, without standard errors, fit through each drv group.

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)


#3. What does show.legend = FALSE do? What happens if you remove it? 
#Why do you think I used it earlier in the chapter?

#Show legend hides the legend box. In this code, without show legend, there is a legend.

ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
  )

#But there is no legend in this code:
  
ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = FALSE
  )

#In the example earlier in the chapter,

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = FALSE
  )

  #the legend is suppressed because there are three plots, and adding a legend that only appears in the last one would make the presentation asymmetric. 
  #Additionally, the purpose of this plot is to illustrate the difference between not grouping, using a group aesthetic, and using a color aesthetic (with implicit grouping). 
  #In that example, the legend isn’t necessary since looking up the values associated with each color isn’t necessary to make that point.

#4. What does the se argument to geom_smooth() do?

#It adds standard error bands to the lines.

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = TRUE)

#By default se = TRUE:
  
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth()

#5. Will these two graphs look different? Why/why not?

  #No. Because both geom_point and geom_smooth use the same data and mappings. 
  #They will inherit those options from the ggplot object, and thus don’t need to specified again (or twice).

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))

#6. Recreate the R code necessary to generate the following graphs.

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(mapping = aes(group = drv), se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy, colour = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(colour = drv)) +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(colour = drv)) +
  geom_smooth(aes(linetype = drv), se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy, fill = drv)) +
  geom_point(color = "white", shape = 21)

######### Statistical transformations  #########

#What is the default geom associated with stat_summary()? How could you rewrite the previous plot to use that geom function instead of the stat function?
  #The default geom for stat_summary is geom_pointrange (see the stat) argument.

#But, the default stat for geom_pointrange is identity, so use geom_pointrange(stat = "summary").

ggplot(data = diamonds) + 
  geom_pointrange(
    mapping = aes(x = cut, y = depth),
    stat = "summary",
  )
#> No summary function supplied, defaulting to `mean_se()

#The default message says that stat_summary uses the mean and sd to calculate the point, and range of the line. 
#So lets use the previous values of fun.ymin, fun.ymax, and fun.y:

ggplot(data = diamonds) + 
  geom_pointrange(
    mapping = aes(x = cut, y = depth),
    stat = "summary",
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

#2. What does geom_col() do? How is it different to geom_bar()?
  
  #geom_col differs from geom_bar in its default stat. 
  #geom_col has uses the identity stat. So it expects that a variable already exists for the height of the bars. 
  #geom_bar uses the count stat, and so will count observations in groups in order to generate the variable to use for the height of the bars.

#3. Most geoms and stats come in pairs that are almost always used in concert. 
  #Read through the documentation and make a list of all the pairs. What do they have in common?
  
  #See the ggplot2 documentation (http://ggplot2.tidyverse.org/reference/)

#4. What variables does stat_smooth() compute? What parameters control its behavior?

#stat_smooth calculates

  #y: predicted value
  #ymin: lower value of the confidence interval
  #ymax: upper value of the confidence interval
  #se: standard error

#There’s parameters such as method which determines which method is used to calculate the predictions and confidence interval, and some other arguments that are passed to that.

#5. In our proportion bar chart, we need to set group = 1 Why? 
#In other words what is the problem with these two graphs?

  #If group is not set to 1, then all the bars have prop == 1. 
  #The function geom_bar assumes that the groups are equal to the x values, since the stat computes the counts within the group.

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop..))

  #The problem with these two plots is that the proportions are calculated within the groups.

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop..))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop..))

#this is what was intended

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop.., group = color))

######### Position adjustments  #########

#1. What is the problem with this plot? How could you improve it?
  
  #There is overplotting because there are multiple observations for each combination of cty and hwy.

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point()

#fix it by using a jitter position adjustment.

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = "jitter")

#2. What parameters to geom_jitter() control the amount of jittering?
  
#From the position_jitter documentation, there are two arguments to jitter: width and height, which control the amount of vertical and horizontal jitter.

  #No horizontal jitter

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = position_jitter(width = 0))

#Way too much vertical jitter

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = position_jitter(width = 0, height = 15))

#Only horizontal jitter:
  
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = position_jitter(height = 0))

#Way too much horizontal jitter:
  
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = position_jitter(height = 0, width = 20))

#3. Compare and contrast geom_jitter() with geom_count().

#4. What’s the default position adjustment for geom_boxplot()? 
#Create a visualization of the mpg dataset that demonstrates it.

#The default position for geom_boxplot is position_dodge (see its docs).
#When we add color = class to the box plot, the different classes within drv are placed side by side, i.e. dodged. If it was position_identity, they would be overlapping.

ggplot(data = mpg, aes(x = drv, y = hwy, color = class)) +
  geom_boxplot()

ggplot(data = mpg, aes(x = drv, y = hwy, color = class)) +
  geom_boxplot(position = "identity")

######### Coordinate systems  #########

#1. Turn a stacked bar chart into a pie chart using coord_polar().
  #This is a stacked bar chart with a single category

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar()

#See the documentation for coord_polar for an example of making a pie chart. In particular, theta = "y", meaning that the angle of the chart is the y variable has to be specified.

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y")

#If theta = "y" is not specified, then you get a bull’s-eye chart

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar(width = 1) +
  coord_polar()

#If you had a multiple stacked bar chart, like,

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

#you end up with a multi-doughnut chart

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill") +
  coord_polar(theta = "y")

#2. What does labs() do? Read the documentation.

#The labs function adds labels for different scales and the title of the plot.

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip() +
  labs(y = "Highway MPG", x = "", title = "Highway MPG by car class")

#3. What’s the difference between coord_quickmap() and coord_map()?
  
  #coord_map uses a 2D projection: by default the Mercator project of the sphere to the plot. 
    #But this requires transforming all geoms.
  #coord_quickmap uses a approximate, but faster, map projection using the lat/long ratio as an approximation. 
    #This is “quick” because the shapes don’t need to be transformed.

#What does the plot below tell you about the relationship between city and highway mpg? 
  #Why is coord_fixed() important? 
  #What does geom_abline() do?

#The coordinates coord_fixed ensures that the abline is at a 45 degree angle, which makes it easy to compare the highway and city mileage against what it would be if they were exactly the same.

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()

#If we didn’t include geom_point, then the line is no longer at 45 degrees:
  
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline()







