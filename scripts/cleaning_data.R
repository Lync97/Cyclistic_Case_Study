# Install required packages if not already installed
packages <- c("tidyverse", "lubridate", "janitor", "skimr")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])

# Load libraries
library(tidyverse)
library(lubridate)
library(janitor)
library(skimr)

# Import the dataset
cyclistic_df <- read_csv("C:/Users/user/Desktop/Cyclistic_Case_Study/data/csv_brut/Data_Cyclistic_Jul24_to_Jun25.csv")

# Clean column names
cyclistic_df <- clean_names(cyclistic_df)

# Remove empty columns and rows
cyclistic_df <- remove_empty(cyclistic_df, which = c("cols"))
cyclistic_df <- remove_empty(cyclistic_df, which = c("rows"))

# Remove duplicate rows
cyclistic_df <- distinct(cyclistic_df)

# Drop unnecessary columns
cyclistic_df <- cyclistic_df %>%
  select(-c(ride_id, start_station_id, end_station_id, start_lat,
            end_station_name, start_lng, end_lng, end_lat))

# Check for missing values in each column
colSums(is.na(cyclistic_df))

# Replace missing values in 'start_station_name' with "unknown_name"
cyclistic_df <- cyclistic_df %>%
  mutate(
    start_station_name = replace_na(start_station_name, "unknown_name")
  )

# Display summary statistics (without visual charts)
skim_without_charts(cyclistic_df)

# Calculate ride duration in minutes
cyclistic_df <- cyclistic_df %>%
  mutate(
    ride_duration = as.numeric(difftime(ended_at, started_at, units = "mins")),
    ride_duration = round(abs(ride_duration))
  )

# Remove rides with implausible durations
cyclistic_df <- cyclistic_df %>%
  filter(ride_duration > 1, ride_duration < 1440)

# Extract day of the week and month
cyclistic_df$day_of_week <- wday(cyclistic_df$started_at, label = TRUE)
cyclistic_df$month_of_year <- month(cyclistic_df$started_at, label = TRUE)

# Classify as weekend or weekday
cyclistic_df$weekend_vs_weekday <- if_else(
  as.character(cyclistic_df$day_of_week) %in% c("Sat", "Sun"),
  "weekend",
  "weekday"
)

# Extract hour of the day
cyclistic_df$hour_of_day <- hour(cyclistic_df$started_at)

# Assign seasons based on the month
cyclistic_df <- cyclistic_df %>%
  mutate(year_seasons = case_when(
    month(started_at) %in% 3:5  ~ "Spring",
    month(started_at) %in% 6:8  ~ "Summer",
    month(started_at) %in% 9:11 ~ "Fall",
    TRUE                        ~ "Winter"
  ))

# View the maximum and minimum ride durations by user type
View(cyclistic_df %>%
       group_by(member_casual) %>%
       drop_na() %>%
       summarize(
         max_ride_duration = max(ride_duration),
         min_ride_duration = min(ride_duration)
       ))

# Export the cleaned dataset
write_csv(cyclistic_df, "C:/Users/user/Desktop/Cyclistic_Case_Study/data/csv_data_clean/Cyclistic_Data_Clean_Jul24_to_Jun25.csv")
