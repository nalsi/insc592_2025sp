
# Overview of the demonstration
# 1. API
# 2. Web scrapping
# 3. Data format (especially CSV and JSON)

# 1. API

# There are APIs being packaged in the R libraries, that we can use directly, like ngramr.
# The opposite scenario would be that we have to get access to the API using the links.

# We need to install the following packages first.
library(httr) # the library to get access to http links
library(jsonlite) # the library to load JSON files (we don't always need it)

# We will use the MET Museum API as the example: https://metmuseum.github.io/
# It is a pretty simple and straightforward API. 
# All paths are taken from the page. So please read the page if you want to learn more about this API!

##
## First example: Get all object IDs
## In this example, we are going to get all item IDs.

# The first link would be the example to get access to all item IDs.
# In this case, we don't need to feed any variable in the link.
res = GET("https://collectionapi.metmuseum.org/public/collection/v1/objects")
# We can inspect the "res" object to understand what is in it.
View(res)
# Generally, all JSON responses from APIs have the same structure.
# We can quite safely load data from the "content" attribute to get all results.
# In the following line, we first transform the content to JSON object (rawToChar())
# and then transform it to an R object (fromJSON()) 
values = fromJSON(rawToChar(res$content)) 
value_list = values$objectIDs
value_list[1]

# By having a list, we can process the information automatically using loops.
for (item in value_list[1:10]) {
  print(item)
}

##
## Second example: Get metadata based on object IDs
## In this example, we are going to get object metadata by using individual IDs.

# By using the item ID, we can load the second link in the MET page to get...
# item-level metadata
# "https://collectionapi.metmuseum.org/public/collection/v1/objects/[objectID]"
# For example, we can feed the first item in the ID list:
new_path = "https://collectionapi.metmuseum.org/public/collection/v1/objects/1"
# or using the paste function to automatize the process
new_path = paste(
  "https://collectionapi.metmuseum.org/public/collection/v1/objects/",
  value_list[1], sep = ""
)
print(new_path)

# We first get the object from API
res = GET(new_path)
# Two things happened in this step:
# (1) we transform res$content into a JSON object: we later need to save this object into a JSON file
# (2) the JSON object is further transformed into an R object to be viewed in the system
metadata = fromJSON(rawToChar(res$content))
# We can directly call things from the parsed JSON file
metadata$accessionYear
# One of the complexities of JSON is that JSON can have nested data frames in it 
# such as in the "constituents" element
# So: R will not be able to save the "metadata" object to a data frame
metadata$constituents
# One of the solutions would be to use unlist() function to flatten the nested data frame
# But for those nested data frames with multiple rows,...
# this solution could create multiple rows for the same record.
# You can find out what t(), i.e., transpose, does in this line by yourself!
df = as.data.frame(t(data.frame(metadata = unlist(metadata))))
write.csv(df, "data/metadata_example.csv")
# Python will be able to solve this problem much more easily.

# Or, we can write the JSON file to the folder and process it later.
write(rawToChar(res$content), "data/metadata_example.json")

# A new package is needed for dataset concatenation
library(plyr)
# If we want to process multiple IDs, we can use the loop function.
# It is not the best solution if we have a large sample size, as it will be super slow.
# We will talk about a better solution than loops later in this class!
df = data.frame()
for (i in 1:20) {
  new_path = paste(
    "https://collectionapi.metmuseum.org/public/collection/v1/objects/",
    value_list[i], sep = ""
  ) # use the corresponding ID in the ID list to get access to the path
  res = GET(new_path)
  metadata = fromJSON(rawToChar(res$content))
  df1 = as.data.frame(t(data.frame(metadata = unlist(metadata))))
  df = plyr::rbind.fill(df, df1) # This function, from the plyr package, is explained below.
}
# Again, we can save the df object into a local CSV file

# rbind vs. cbind: concatenate data frames by row or by column
# Both functions require that the data frames have the same dimensions on the other scale
# i.e., if we row-bind, then the two items should have the same number of columns
# but rbind.fill() will automatically create those columns that do not exist on one side.

##
## Third example: Search
## In this example, we are going to search the database and find ID based on our query.

# We can also search the MET database:
# https://collectionapi.metmuseum.org/public/collection/v1/search
# In this case, we need to supply the query phrase behind the link,
# For example: "https://collectionapi.metmuseum.org/public/collection/v1/search?q=sunflowers"
# The page also contains other search option (for highlight or department...)

new_path1 = "https://collectionapi.metmuseum.org/public/collection/v1/search?q=impressionism"
res = GET(new_path1)
metadata = fromJSON(rawToChar(res$content))
id_list = metadata$objectIDs
length(id_list)

# Remember, we can use the results from the search to automatize other steps to follow
# So you can use the example above to loop through all retrieved IDs to get new data
# If you want to get all results, remove [1:10] from the first line.
for (item in id_list[1:10]) {
  new_path = paste(
    "https://collectionapi.metmuseum.org/public/collection/v1/objects/",
    value_list[i], sep = ""
  ) # use the corresponding ID in the ID list to get access to the path
  res = GET(new_path)
  metadata = fromJSON(rawToChar(res$content))
  df1 = as.data.frame(t(data.frame(metadata = unlist(metadata))))
  df = rbind.fill(df, df1) # rbind() is to concatenate data frames by the row
}

# 2. Web scrapping
# Example taken from textbook: https://r4ds.hadley.nz/webscraping
# Especially if you are unfamiliar with HTML, I encourage you to read this chapter.
# Web scrapping also requires a language to process XML information: XPath (XML Path Language)
# W3CSchools has a pretty useful tutorial for this language: https://www.w3schools.com/xml/XPath_intro.asp.

library(tidyverse) # tidyverse is a data processing pipeline for R
library(rvest)

# Sections 24.4 and 24.6 in our chapter are pretty helpful.
# Before doing web scrapping, we need to understand the structure of the page:
# https://rvest.tidyverse.org/articles/starwars.html
# Specifically: where is the relevant information in the HTML file?
# And can we use any pattern to identify all of them?

# 3. File formats

# It is highly recommended that we can load and write file using code!
# For formats that you are uncertain, Google how to do it in R!

# CSV is probably the most frequently used data format in this class.
# CSV stands for comma-separated values
# It is more advantaged to XLSX (or any other file formats used in Excel) because:
# 1. It is an open source file format
# 2. It is lightweight (we cannot add visualization or extra tabs to the data file)
# --> So it is more useful for data exchange.
# But if there are multiple data tables, we have to save them into separate files.
# I recommend, if possible, save any of your processed data as the CSV format.
?write.csv
?read.csv
?as.data.frame

# There are also packages to support loading large CSV files:
# https://stackoverflow.com/questions/1727772/quickly-reading-very-large-tables-as-dataframes

# JSON is becoming more popular, particularly in API services
# There are multiple packages for the JSON format
# We are primarily talking about jsonlite
?jsonlite::read_json

# XLSX: The original format for Excel that we sometimes have to use.
# Again, there are different packages.
# But I highly recommend readxl.
# Also, I don't recommend saving any of your data into an Excel format using R.
library(readxl)
?readxl::read_excel
# One thing to notice is that we need to provide sheet name when loading an xlsx/xls file.



