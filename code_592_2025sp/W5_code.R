# Outline: 1. Tidyverse, 2. Data cleaning tasks

# 1. Tidyverse

library(tidyverse)
# Tidyverse itself does not have many functions;
# Instead, most of the functions are taken from other tidyverse packages being attached.
# The demonstration of tidyverse will be integrated with the second part.

# Remember that for everything that you can do in Tidyverse, there are alternative approaches using the Base or other packages.
# So you don't have to use Tidyverse.

# But there are many useful materials for you to learn more about Tidyverse, which could be important for beginners.
# Chapter 5 of our text book offers a good summary of Tidyverse.
# Or search Google: [do something] in Tidyverse

# 2. Data cleaning

# To repeat what we did in Week 3:
# We will use the airquality dataset for the first part of demonstration.
?airquality # Again, it is always helpful to read the documentation in the beginning.
data = datasets::airquality

# 2.0 Let's run some basic description
hist(data$Temp) # for numeric variables 
table(data$Month) # for categorical variables

library(psych)
describe(data)
# Remember that we can use basic descriptive analysis to detect many things:
# outliers, NA values, and errors.

# 2.1 NA values
# We can very easily see that there are many NA values

# One very useful function to detect NA values
is.na(data$Ozone) # to test is a value (or a list of values) is NA
is.na(data$Ozone[1])
# if we calculate mean or median, removing NA is also an option that we can have (the default value is FALSE though)
?mean # na.rm parameter
# If we apply the function to a variable with NA value, we will get NA; 
# So instead, we should set the parameter to TRUE (or T)
mean(data$Ozone)
mean(data$Ozone, na.rm = T)

# There are more advanced ways to visualize missing values
library(visdat)
visdat::vis_dat(data) # vis_dat function in the visdata package is a pretty decent tool to visualize missing data
visdat::vis_miss(data)
# Another package
library(naniar)
naniar::gg_miss_var(data)
# Remember that as cool as these functions are, they are still showing some very basic facts in the first step of data processing.
# Knowing how many observations have missing value is definitely not a good enough RQ, as it is too simple!

# Sometimes, as part of the exploration, we may want to understand if missing value is correlated with other factors. 
# We will not talk about ggplot2 (as this is the main topic in the visualization weeks), 
# ... but we can use the geom_miss_point function from the naniar package (being used with ggplot2 functions).
# It is a very cool function to visualize things that have no values in a scatterplot.
library(ggplot2)
ggplot(data, aes(x = Ozone, y = Solar.R)) + geom_miss_point(alpha = 0.5)
# Missing points are relatively distributed across the two variables.
# Compare the previous graph with a regular scatterplot:
ggplot(data, aes(x = Ozone, y = Solar.R)) + geom_point()
# We can further understand if missing values are more centerred in certain groups.
ggplot(data, aes(x = Ozone, y = Solar.R)) + geom_miss_point(alpha = 0.5) + 
  facet_wrap(.~Month) # facet_wrap breaks the graphs based on the Month variable, also called "small multiple graph"
# There seems to be more missing points in June: maybe too much to analyze Ozone value if we want to examine different categories.
# Rule of thumb: if more than 50% of values are missing values, then we probably have to drop the whole variable.

# In this case, I think we can use both removal or imputation (it could also depend on what we are going to do with the data next).
# Say, we will use Ozone in a statistical model, then the imputation of 1/3 of missing values can create biases.
# I recommend this blog post for more discussion on this point: https://medium.com/@danberdov/dealing-with-missing-data-8b71cd819501
# In the case of removing, we can only choose to drop rows with NA values in columns that we will focus on.

# example of imputation
data$Ozone_new = data$Ozone # it is always a good practice to create a new column if we want to change anything in the old one
data$Ozone_new[is.na(data$Ozone_new)] = mean(data$Ozone_new, na.rm = T)
# The logical of the previous function is that to assign the mean value to all values in Ozone_new that is NA

# example of removal
# again, let's create a separate file to not mess up with the original data
data1 = data[is.na(data$Solar.R) == F,] # we only retain all rows in the dataset where the Solar.R column is not NA
# After removal, we have 146 rows
# Or in Tidyverse, doing the same thing.
data1 <- data %>%
  filter(is.na(Solar.R) == F)
# We can still use most of the tidyverse functions separately as follows.
filter(data, is.na(data$Ozone) == F)

# 2.2 Duplicated records

# We can use the Base function duplicated() to see if any record or value in a column are duplicated.
sum(duplicated(data)) # We can use sum() to see if any row in the whole data object is duplicated
# If we have an ID column, we can also use the column name in duplicated() to see if there is any duplicated ID
# Removing duplicated record using the Based function.
data = data[duplicated(data)== F,]

# We can also use Tidyverse pipeline to do it differently.
data2 = data %>% distinct(.keep_all = TRUE)

# 2.3 Date format
# While we probably don't need super complex for this dataset because it is not covering the whole year.
# But let's try the following things: 
# (1) transform month and date into an actual Date column
# (2) some minor transformation (i.e., numerical to textual month names)

# A relatively each change we can make is to transform the month from number to character/factor...
# because it is supposed to be [What data type?]
# We can again use as.character() or as.factor() to do this in the Base framework.
# I also recommend always use a new column to contain processed data based on an existing column: 
# so that we won't overwrite existing data.
data$Month_CH = as.character(data$Month)
class(data$Month_CH)
data$Month_FA = as.factor(data$Month)
class(data$Month_FA)

# We are doing the same thing in Tidyverse.
# In Tidyverse: mutate() is a very useful function to change data in this framework!
# So we create a new Month_CH variable to have the character format of the Month data. 
data <- data %>% mutate(Month_CH = as.character(Month)) 
class(data$Month_CH)

# But we can also transform the month into the textual names, for display purposes.
data <- data %>% mutate(Month_text = case_when(Month==5~ "May",
                                               Month==6~ "June", 
                                               Month==7~ "July", 
                                               Month==8~ "August", 
                                               Month==9~ "September"))
# within case_when(), we need to provide all the conditions for us to create new value in the new Month_text column.
class(data$Month_text)
# The text month names are more meaningful for display.
# Compare this to our example in line 59.
ggplot(data, aes(x = Ozone, y = Solar.R)) + geom_miss_point(alpha = 0.5) + 
  facet_wrap(.~Month_text)

# A similar example would be to create a categorical variable for Temp: anything above 79 will be counted as "high" vs. "low"
# This adds more possibilities for next steps: so you don't have to do this, but should keep this possibility in mind!
data <- data %>% mutate(Temp_group = case_when(Temp>= 79~ "High",
                                               Month< 79~ "Low"))
table(data$Temp_group)


# In Tidyverse, there is also a very simple way to create Date class.
data = data %>% mutate(date_num = make_date("1973", Month, Day))
class(data$date_num)
# Date is a very useful data class when we create visualization.
# There are many interesting things we can do to date, such as calculating the week of the day.
data <- data %>% mutate(WeekDay = weekdays(date_num))
# We are basically creating a new categorical variable to understand the data from a new perspective!

# One thing we can use data for is to create a line chart.
# Dates will be displayed very neatly by ggplot2. 
ggplot(data, aes(x = date_num, y = Temp)) + geom_line()
# Bar vs. line: we can use bar chart to show the same information but it's less useful and appealing.
ggplot(data, aes(x = date_num, y = Temp)) + geom_bar(stat = "identity") 
# 'stat = "identity"' means we will use the value in the y variable as the y-axis.

# 2.4 Reshaping data
# we will need to rely on pivot_longer() and pivot_wider() to create the long and wide tables in the Tidyverse pipeline.
# For this dataset, it is not very useful to create a long table (because the values variables are very different from each other).
# In our slides, the value variables are much more parallel to each other!
# But we can still do it as a demonstration.

# In the example below, we are "folding" the data in the four numeric variables to move them into a single variable.
# We are moving all names of the variable into "variable" and all values into "value".
data_long = data %>% 
  pivot_longer(
    cols = c("Ozone", "Solar.R", "Wind", "Temp"),
    names_to = "variable", 
    values_to = "value"
  )

# The opposite example: from long to wide
data_wide = data_long %>%
  pivot_wider(
    names_from = "variable",
    values_from = "value"
  )

# 2.5 Merging tables

# We first talk about the basic idea of merging tables by using the Base function merge().

# First, let's first create two tables with ID number ranging from 1 to 50 and an extra "Value" column with random values.
df1 <- data.frame(ID = 1:50, Value = rnorm(50))
df2 <- data.frame(ID = 1:50, Value = rnorm(50))
# feel free to play with the rnorm() function. This is a function to get a random list of values.
# We can further create a larger dataset with 60 IDs for fun.
df3 <- data.frame(ID = 1:60, Value = rnorm(60))
# And lastly, we can have a data frame with 100 rows with repeated ID of 1 to 50.
df4 <- data.frame(ID = rep(1:50, 2), Value = rnorm(100))

# To merge the table, we need to define: (1) the key to connect (i.e., ID) and (2) the type of join (i.e., left, right, outer, inner...)

# Let's take a look at merge() first.
# We can define the keys in by, by.x, and by.y parameters.
### By is used when both data frames have the same key variable, otherwise, we have to define the two variables independently.
### Similarly, we can define if we want to include all observations in both data frames by "all" or separately by "all.x" and "all.y".
?merge
# If we are using two tables with the same set of IDs, it really does not matter what type of join we use.
df = merge(df1, df2, by = "ID", all = T) # outer join
df = merge(df1, df2, by = "ID", all = F) # inner join
# But it will matter if we merge df1 with df3 or df4.
# Let's try df1 and df3:
df = merge(df1, df3, by = "ID", all = T) # if we use outer join, we will get 60 rows.
print(nrow(df))
df = merge(df1, df3, by = "ID", all = F) # inner join: 50 rows, with only the overlap
print(nrow(df))

##
## Your job here is to try left, right, outer and inner join between df1 and df4: what do you get?

# There are some other functions to support merging
# But the original merge() is still very heavily used even in the Tidyverse pipeline -- as an independent step.

# 2.6 Some other operation in tidyverse

# select(): select columns
# filter(): select rows
# arrange(): change the order of rows
# summarize(): column summary based on other function

# You can use the material in the beginning of the document to learn more about it!

