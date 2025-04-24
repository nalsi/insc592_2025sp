# Some major topics we are going to discuss here.

# 1. The basic interface and components of RStudio.
# 2. File formats supported by RStudio (not so much data file, which will be discussed in W4)
# 3. Markdown format
# 5. Getting help from ChatGPT

# First of all, this is a raw R code file (saved as .r file).
# In this file, all code are displayed in black.
# And all comments (begins with "#") are printed in green.

# The base package is loaded with R, so there is not need to load it again.
?base
a = 123
class(a)
?class
b = as.character(a)
class(b)
print(a)
print(b)
a + 1
b + 1 # error message
# We will come back with more examples of data value types in Week 3 and 4.

# We can use install.packages() function to install packages.
install.packages("ggplot2")
# Each package contains functions that are the basic unit of code.
# After the package is installed, we can load the package and then use its functions.
library(ggplot2)
# cars is a dataset automatically loaded with the ggplot2 package.
# We will talk more about loading and saving data files in Week 4.
ggplot(cars, aes(speed)) + geom_histogram()
# We can get help for a package or function
?ggplot2
?ggplot
# What is in a documentation file?
# But it may be easier to visit the website: https://ggplot2.tidyverse.org/

# ngramr example
# use the install.packages() function to install the package first
library(ngramr)
?ngram
ng  <- ngram(c("hacker", "programmer"), year_start = 1950)
ggplot(ng, aes(x = Year, y = Frequency, colour = Phrase)) +
  geom_line()

citation("ngramr")

# Question:
# using the above examples,
# can you write the code to install the "psych" package and learn about describe() function?
# try the describe() function using the cars dataset.
# describe(cars)
