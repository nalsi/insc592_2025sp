# 1. Data types

# R does not have the categories of nominal, ordinal, interval, and ratio.
# Instead:
# nominal -- > categorical / character
# interval and ratio --> numeric (or integer, which we will large disregard)
# ordinal --> both ways (so we need to pay attention to this scenario in statistical analysis)
# There are differences between integer and numeric. But we can represent all numbers as numeric.

# numeric value that covers both interval and ratio
a = 123 # we assign a number to the name a 
class(a) # get the data value
is.numeric(a) # test if the value is numeric

a1 = 123L # we can add "L" to make the number an integer
class(a1)
is.integer(a1)
is.integer(a) # 123 is NOT an integer but numeric
print(a)

# but we can change the value to a string
b = as.character(a)
is.character(b)
class(b)
print(b) # strings and numbers are printed differently

a2 = as.numeric(b) # we can only change a text string back to numbers if the string represents a number
a3 = as.integer(b)

# another related data value is factor
# factors are the categorical data with levels
# it is easier to be processed by R
# A very useful instruction on this data type: https://www.stat.berkeley.edu/%7Es133/factors.html
b1 = as.factor(a)
print(b1)
is.factor(b)
is.factor(b1)
a4 = as.numeric(b1) # Even if a factor value is a number, we cannot directly transform it back to numbers.
a5 = as.numeric(as.character(b1)) # instead, we have to first transform it to character, and then to numbers
# In many R tasks, characters will be automatically regarded as factors (even though it will make the processing slower sometimes).

a + 1 # numbers can be used in calculation
b + 1 # error message

# 
b = "LIS"
as.numeric(b) # we cannot transform a text string back to number if it does not take a numeric form
paste(b, "def") # instead, we can concatenate strings together

# There are more class() values that we will see later!

# 2. descriptive analysis
# If you want to learn more, this is a pretty comprehensive document: 
# https://statsandr.com/blog/descriptive-statistics-in-r/
# We will use the iris dataset in the system

?iris
data(iris) # load the dataset to Environment
# Because the iris dataset is in the Base package, we don't need to load any package.
# we can click the dataset in the Environment bar

# We can use the following methods to call the column to run the descriptive analysis
iris$Sepal.Length # we can print one column by using $ sign followed by the colume name
iris[, "Sepal.Length"] # another way to call the column
iris[, 1] # or just use the number

# BTW, we can also call the single value
iris$Sepal.Length[1]
iris[1, "Sepal.Length"]
iris[1, 1]

dim(iris) # for all dataframes, we can get the number of columns and rows
nrow(iris) # or just the row number
ncol(iris) # column number

# We can again, look at the class of each column.
class(iris$Sepal.Length)
class(iris$Species)
# R has the apply function that could automatically apply a function to all rows and columns, et al.
lapply(iris, class)

# a series of descriptive analyses we can do on numeric variables: 
min(iris$Sepal.Length)
max(iris$Sepal.Length)
mean(iris$Sepal.Length)
median(iris$Sepal.Length)
range(iris$Sepal.Length)
sd(iris$Sepal.Length)
?sd

# psych package to describe all variables
library(psych)
describe(iris)
# describe by groups
describeBy(iris, group = "Species")

# Let create some graphs using the Base visualization functions in R
# The Base package offers one of the three visualization systems in R.
# We will talk about ggplot2, the most useful system later in this class!
# These functions are helpful for preliminary exploration but not very useful for creating the final products.

# Let's create the distribution for a numeric variable.
hist(iris$Sepal.Length) # for example, creasing a histogram
?hist # we can play with the parameters of the function to get better graphs
hist(iris$Sepal.Length, 
     prob = TRUE, # instead of using the raw number, we will use probability in the y-axis
     breaks = 20, # instead of having just 8 bins, we want to have 20
     main = "Histogram of Patal Length", # set the title
     xlim = c(4, 8), # set the boundary of x-axis,
     xlab = "Sepal Length") # set the x-axis label
lines(density(iris$Sepal.Length)) # We can add a trend line after running an extra function

# Next, a box plot
boxplot(iris$Sepal.Length)
# A single box plot is not very helpful; now, we can use separate box plots using the Species categories
boxplot(iris$Sepal.Length ~ iris$Species) # We are feeding a statistical model to the function to use the second variable in the x-axis
# remember that we can still use most of the parameters in the previous example in this Base function.

# The Base package does not have a violin chart function.
# But you can find some examples of using another package here: https://r-charts.com/distribution/violin-plot-group/.
# The idea is very similar!

# Summarize categorical variables
# The table() function is able to count of the frequencies of values in a variable.
table(iris$Species)
sum_table = table(iris$Species) # save it to the object named sum_table
sum_table = data.frame(sum_table) # transform the object into a two-dimensional dataframe using data.frame() function.9l8

# 3. File system

# Each code file is part of a project that has a position in your computer (i.e., folder).
# When we load and save data in the code, we need to find the data file.
# The best way to organize is to save everything related to the same project in the same main folder.
# And separate: code, raw data, and derived data (for example, create separate sub-folders for them or use different names).
# Reasons: (1) easy to find, and 
# (2) when we save an edited dataset, we won't mess up with the original data.
# To name the file: (1) avoid using empty space in the file name (also column name)
# (2) distinguish different versions of the same file (code, data...)

# When we open a code file, we need to pay attention to the working directory...
# ... which is displayed under the Console tab
# If it is not the correct folder, we can set it up by clicking Sessions -- Set Working Directory
# After which, we can load and save data in the same folder by using easy relative path.
# Some examples: https://www.w3schools.com/html/html_filepaths.asp

# for example, to save the sum_table object
# while "./" in the path is not needed, I like to use it as a personal memory device
# so the following path says: 
# I want to save the file to the "dataset" sub-folder (/dataset) in the same folder of this current code file (.)
write.csv(sum_table, "./dataset/sum_table.csv")

# similarly, we can load data saved in the folder
# You can analyze the read.csv() function (one the most heavily functions used in R)
# stringsAsFactors parameter indicates if a text string should be loaded as factor or text.
new_table = read.csv("./dataset/sum_table.csv", stringsAsFactors = F)


# 4.  An additional activity:
# Install and load the MASS package
# Play with the Boston dataset in this package
?MASS::Boston
# (For the above steps, you may need to use examples above or in the previous week.)

# Run some descriptive analyses and then propose one or multiple RQs that we can answer using the data.
# If you want, feel free to create and share a notebook to include both the analyses and RQs.
# But you can also just share your RQs to the discussion board.
# You don't need to overthink about the RQs. It does not have to be super complex!
