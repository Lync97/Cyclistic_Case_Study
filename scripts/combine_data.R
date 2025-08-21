# Install required packages if not already installed
packages <- c("tidyverse", "janitor", "skimr")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])

# Load libraries
library(tidyverse)
library(janitor)
library(skimr)

# Change the working directory
setwd("C:/Users/user/Desktop/Cyclistic_Case_Study/data/csv_brut")

# List all CSV files in the folder
csv_files <- list.files(pattern = "\\.csv$")

# Read and merge all files into a single dataframe
cyclistic_df <- csv_files %>%
  map_df(read_csv)

# Check the dataset structure
str(cyclistic_df)
skim(cyclistic_df)

# Save the merged file
write_csv(cyclistic_df, "Data_Cyclistic_Jul24_to_Jun25.csv")

# Delete the files (if necessary)
file.remove(csv_files)

