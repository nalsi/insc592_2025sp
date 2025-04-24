### Overview: 
#### 1. data standardization
#### 2. correlation
#### 3. t-test
#### 4. anova


### 1. data standardization / normalization
### We will again use the iris dataset as an example.

library(tidyverse)
data = iris

# Let's first take a look at Petal.Width column
hist(iris$Petal.Width[iris$Species == "setosa"])
# It's not normally distributed.
# But in this case, we should expect non-normal distribution... 
# because the data is multi-modal, i.e., each of the group has a very different distribution.
# Since all numbers in this variable are positive numbers, there are many options we can use to standardize the variable.

# We created three new variables by transforming Petal.Width, using:
# (1) square root, (2) log, and (3) z-score.
# Feel free to read of documentation these functions if you are uncertain about them.
data = data %>% 
  mutate(pw.sqrt = sqrt(Petal.Width)) %>% 
  mutate(pw.log = log(Petal.Width)) %>% 
  mutate(pw.zscore = scale(Petal.Width))

# We can compare the results by visualizing them in the same panel.
# This is a strategy used in the Base visualization system.
# In ggplot2, there is a better solution than this!
par(mfrow = c(2, 2))  ## set the layout to be 2 by 2
sapply(c(4, 6:8), function(i) hist(data[iris$Species == "setosa" ,i])) 
# In the second line, for each part of the layout, we create a historgram using the i column of information.

# But one benefit is that if we can apply each of the methods to all variables,
# and we can transform all the variables to the same scale!

### 2. Correlation

#### 2.1 regular approach

# Remember, the first step would be to check the assumption of the method.
# For Pearson regression, our variables are numeric.
boxplot(data$Sepal.Length)
boxplot(data$Sepal.Width) # there are some outliers in this variable, so maybe we can transform the data.

# for example:
data = data %>% mutate(sw.sqrt = sqrt(Sepal.Width))
par(mfrow = c(1, 2))  ## set the layout to be 2 by 2
boxplot(data$Sepal.Width)
boxplot(data$pw.sqrt)
# After applying sqrt method, we also removed the outliers!

plot(data$Sepal.Length, data$Sepal.Width) 
# it's not perfectly linear but probably OK for correlation!
# Partly, again, is because this data is multi-modal (we will see that later).

# While we can use cor() function to get correlation results, it only returns the coefficient.
# We may want to see the p-value to have a better understanding of the relationship!
?cor
cor(data$Sepal.Length, data$Sepal.Width)

# cor.test() is a better option.
?cor.test
cor.test(data$Sepal.Length, data$Sepal.Width)
# We can see that we cannot reject the null hypothesis that the two variables do not significant correlation here!
# But for correlation, in many cases, we don't need to worry about the statistical significance!

# Let's analyze the result!
result = cor.test(data$Sepal.Length, data$Sepal.Width)
# We can extract different parts of the results.
result$estimate
result$p.value
# Most statistical results can be extracted like this!

# re: Simpson's Paradox: one thing we can examine is the correlation within each group!
# In the following code, I looped through all the three species and did an individual correlation test for each.
# I further extracted the coefficient (from estimate column) and p-value (from p.value column) from the results.
# And then paste everything in a table.
df = data.frame()
for (i in unique(data$Species)) {
  sub = data[data$Species == i,]
  test = cor.test(sub$Sepal.Length, sub$Sepal.Width)
  df = rbind(df,
             data.frame(
               "Species" = i,
               "coefficient" = test$estimate,
               "p-value" = test$p.value,
               stringsAsFactors = F
             ))
}
View(df)
# The results actually show that in every group, the relationship between the two variables is positive!
# Also, we can still say that our data is linear!

# To plot the relationship between two variables, we can use scatter plot.
ggplot(data, aes(Sepal.Length, Sepal.Width)) + # again, set up the data and canvas
  geom_point() + # using scatter plot
  stat_smooth(method=lm) # draw a trend line using the linear model ("lm")

# And we can play with some other parameters in ggplot2
ggplot(data, aes(Sepal.Length, Sepal.Width)) + # again, set up the data and canvas
  geom_point(aes(color = Species)) + # using scatter plot
  stat_smooth(method=lm) # draw a trend line using the linear model ("lm")
# To explain:
# In ggplot2, we need to define what variables will be used for which features of the graph (x, y, color, size...)
# Anything inside aes() are the features based on variables (i.e., color being defined by value in the column)
# The opposite scenario is we can set color "red" to all points:
ggplot(data, aes(Sepal.Length, Sepal.Width)) + # again, set up the data and canvas
  geom_point(color = "red") + # using scatter plot
  stat_smooth(method=lm) # draw a trend line using the linear model ("lm")

# We can further improve the previous example by having separate trend lines.
ggplot(data, aes(Sepal.Length, Sepal.Width)) + # again, set up the data and canvas
  geom_point(aes(color = Species)) + # using scatter plot
  stat_smooth(aes(color = Species), method=lm) # draw a trend line using the linear model ("lm")
# Please analyze how it is different from the example in line 103!

#### 2.2 Some more advanced options to produce results

# rcorr() function from Hmisc package can create the matrix.
library("Hmisc")
res2 <- Hmisc::rcorr(as.matrix(data[,1:4]))
res2
# And we can export the coefficient table very easily: transform it to a data.frame and save it to the folder:
write.csv(data.frame(res2$r))

# corrplot offers a Base visualization approach to heat map, which is not very elegant.
library(corrplot)
corrplot(cor(data[, 1:4]), type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)

# a even better option is ggcorrplot()
library(ggcorrplot)
ggcorrplot::ggcorrplot(cor(data[, 1:4]))

### 3. t-test
# Because t-test can only compare up to two groups, we will use a subset of the data object.
# We will look at if the sepal length varies across the categories of setosa and versicolor.
# This is a two sample t-test, as we are comparing two samples.
t.test(Sepal.Length ~ Species, data[data$Species %in% c("setosa", "versicolor"),])
# t.test(Sepal.Length ~ Species, data) --> we cannot use the whole dataset, because it contains three groups!
# The results show that they are significantly different from each other, 
# with a very large absolute t value and a very small p-value.
# We can also see the confidence interval that is the comparison between the mean values.

# The results are certainly consistent with the box plot as well as the scatterplot we saw earlier!
plot(Sepal.Length ~ Species, data=data)

# a one sample t-test:
# Remember, we are comparing the mean of one data sample with a number that we give.
# We can first look at the mean of sepal length for all setosa.
mean(data$Sepal.Length[data$Species == "setosa"])
# And do the comparison: mu stands for the mean value we want to compare with the data.
t.test(data$Sepal.Length[data$Species == "setosa"], mu = 6)

?t.test
# for paired t-test, we can change the parameter of "paired" to True.
# But then, we need to make sure our data is paired.

### 4. ANOVA

# If we used the same model like the t-test, we can get the same results from ANOVA... 
# even though the calculation is different!
model0 = aov(Sepal.Length ~ Species, data[data$Species %in% c("setosa", "versicolor"),])
summary(model0)

# But we can calculate more than two groups in ANOVA!
model_anova = aov(Sepal.Length ~ Species, data)
summary(model_anova)
# The results show that there are significant differences across at least two species group!
# But we don't know how the groups are different from each other from here.

# To understand this, we can use Tukey Test.
tukey.test = stats::TukeyHSD(model_anova)
# We can look at the results from the analysis.
tukey.test
# But we can also plot the result!
plot(tukey.test)

# Let's try two-way ANOVA that uses two independent variables!
# Because the data have only one categorical variable, we will create another variable based on the methods introduced last week:
# To translate sepal width into a categorical variable.
data <- data %>% mutate(Sepal.Width.group = case_when(Sepal.Width>= 3~ "Large",
                                                      Sepal.Width< 3~ "Small"))
# We can pass a character variable as a factor variable in statistical models. 
class(data$Sepal.Width.group)
# In the model, by using "+", it means we only consider the individual effect of the two groups on the outcome.
# instead of considering the interaction effect...
model_anova1 = aov(Sepal.Length ~ Species + Sepal.Width.group, data)
summary(model_anova1)
# In the results, we can see that both variables are connected to significant differences in the outcome!
# We, again, don't know the exact difference!
# And judged by the f-value, Species are correlated with larger changes.

# But we can use "*" to detect interaction effect between the two independent variables.
model_anova2 = aov(Sepal.Length ~ Species * Sepal.Width.group, data)
summary(model_anova2)
# Besides the main effects of the two independent variables,
# we also see the third row (interaction effect), which shows how the two variables interact with each other,
# in terms of their relationship with the outcome.
# We see a very small f value and very large p-value, which shows that their effects on the outcome...
# are largely independent, that is not influenced by the other factor.
# However, we can observe that the main effects are somewhat different from the previous model.

# We can again run the Tukey Test, but the results are much more complex, as we are comparing across two factors.
tukey.test1 = stats::TukeyHSD(model_anova2)
tukey.test1

# One way of showing the results is actually creating multiple box plots based on the raw data.
ggplot(data, aes(Species, Sepal.Length, color = Sepal.Width.group)) +
  geom_boxplot()
# Explain of the graph: we can use the color feature to add an extra box for each species based on the width.group.
# So what does the result of no interaction effect mean? 
# --> no interaction effect means both trends are parallel to each other:
# (1) three species groups are parallel to each other (i.e., setosa < versicolor, regardless of the width)
# (2) the two width groups are parallel to each other (i.e., large width < small width, regardless of the species)

# Technically, it is also possible to use tukey.test1 in ggplot2, but it may take some extra steps. 
# So I am going to skip.

# Personally, I would say showing the multiple box plot + analysis from anova test would be the best way for reporting two-way ANOVA results!

### 5. chi-square test & Activity

# We will not talk about chi-square, but feel free to use the examples in the following link to understand how it works.
# https://www.sthda.com/english/wiki/chi-square-test-of-independence-in-r

# Activity:
# I want you to analyze chi-square method and at least one more method from 7 of this week's lecture,
# to understand:
# (1) what variables should be used to make the model work?
# (2) what type of conclusions can be draw from the model?
# (3) What requirements for the data do they have?
# Please post your answer to W6 Discussion.




