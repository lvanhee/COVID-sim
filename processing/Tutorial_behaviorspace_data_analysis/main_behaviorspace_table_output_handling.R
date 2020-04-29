#Made by Maarten Jensen (Umea University) & Kurt Kreulen (TU Delft) for ASSOCC

#first empty working memory
rm(list=ls())

# #then install packages (NOTE: this only needs to be done once for new users of RStudio!)
#install.packages("ggplot2")
#install.packages("plotly")
#install.packages("tidyr")

#then load relevant libraries
library(ggplot2)
library(plotly)
library(tidyr)

### MANUAL INPUT: specify and set working directory ###
workdirec <- "~/Desktop/ASSOCC Behaviorspace/tutorial"
setwd(workdirec)
source("functions_behaviorspace_table_output_handling.r")

### MANUAL INPUT: Optionally specify filepath (i.e. where the behaviorspace csv is situated) ###
#NOTE: if csv files are placed in the workdirec, then leave filesPath unchanged
filesPath <- ""
### MANUAL INPUT: specify filenames ###
filesNames <- c("ASSOCC-Dummy-Data-NL-v1.csv",
                "ASSOCC-Dummy-Data-Italy-v1.csv")

# READ DATA ---------------------------------------------------------------

df <- loadData(filesPath, filesNames)

# REMOVE INVALID RUNS ---------------------------------------------------------------
#runs that have a lower amount of maximum infected are seen as invalid and are therefore removed
#specify the minimum number of infected people for a run to be considered as valid (5 person by default)
#the next will fail if the number of infected is not in the data as -> count.people.with..is.infected..
df <- cleanData(df, 0)

# REMOVE IRRELEVANT VARIABLES ---------------------------------------------------------------

#Loop through dataframe and identify variables that do NOT vary (i.e. that are FIXED)
#Unfixed variables are either independent or dependent and therefore relevant to include in the analysis
df <- removeVariables(df)

# RENAME VARIABLES ---------------------------------------------------------------
printColumnNames(df)

### MANUAL INPUT: specify new (easy-to-work-with) variable names ###
new_variable_names <- list(
  "run_number",
  "country",
  "IVR",
  "global_confinement_measures",
  "IDV",
  "UAI",
  "MAS",
  "LTO",
  "working_from_home_recommended",
  "trigger_ratio_social_distancing",
  "PDI",
  "network_generation_method",
  "tick",
  "infected_people",
  "dead_people",
  "social_distancing_people",
  "people_at_home",
  "people_working_at_home",
  "workers",
  "retired_people",
  "students",
  "children",
  "people_in_school",
  "people_in_hospital",
  "people_at_work",
  "people_at_public_leisure",
  "people_at_essential_shops",
  "people_at_private_leisure",
  "mean_sleep_satisfaction",
  "mean_conformity_satisfaction",
  "mean_risk_avoidance_satisfaction",
  "mean_compliance_satisfaction",
  "mean_belonging_satisfaction",
  "mean_leisure_satisfaction",
  "mean_luxury_satisfaction",
  "mean_autonomy_satisfaction",
  "mean_QoL",
  "median_QoL",
  "max_QoL",
  "min_QoL"
)

#change variable names
variable_names <- names(df)
if (length(variable_names) == length(new_variable_names)) {
  clean_df <- changeColumnNames(df, new_variable_names)
} else {
  print("ERROR: the number of variable names you specified is not the same as the number of variables present within the dataframe; please check again")
}
#remove redundant objects from working memory
rm(list = "df", "new_variable_names")


# TRANSFORM DATAFRAME -----------------------------------------------------

#Create a long format dataframe: long dataframes enable you to plot multiple y-variables in one single graph
### MANUAL INPUT: make sure that you specify which variables are to be considered as metrics (i.e. dependent variables)
#Note that you need to specify the range of outcome variables! (see the last input to the 'gather' function)
df_long <- gather(clean_df, variable, measurement, infected_people:min_QoL)

# SPECIFY VARIABLE MEASUREMENT SCALES -----------------------------------------------------
### MANUAL INPUT: in order for ggplot and plotly to work, one must specify the following: ###
#-> continuous decimal (floating) variables as 'numeric'
#-> continuous integer variables as 'integer'
#-> discrete (or categorical) variables as 'factor'

#print an overview of variables and their measurement scales
str(df_long)
#transform 'measurement' variable to numeric (as to avoid ggplot errors)
df_long$measurement <- as.numeric(df_long$measurement)
#round 'measurement' variable to 4 decimals
df_long$measurement <- round(df_long$measurement, 4)
#convert categorical variables to factors (as to avoid ggplot errors)
df_long$run_number <- as.factor(df_long$run_number)
df_long$variable <- as.factor(df_long$variable)

# PLOTTING -----------------------------------------------------

# Below you can find some ggplot commands for building useful visualizations
# If you would like to build something different, check out the world wide web! :-)
# You can also contact Kurt or Maarten if you're stuck!
# http://r-statistics.co/Complete-Ggplot2-Tutorial-Part1-With-R-Code.html

#TIMESERIES PLOT WITH CONTINUOUS Z VARIABLE: Line Plot
ggplot(clean_df, aes(x = tick, y = infected_people, group = run_number)) + 
  geom_line(size=0.5,alpha=0.3,aes(color=IDV)) + 
  xlab("ticks [4ticks = 1 day]") +
  ylab("number of infected persons") + 
  labs(title="Infection-Rate Plot",
       subtitle="Number of infected people over time for individualistic (high IDV) versus collectivistic (low IDV) cultural profiles", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#TIMESERIES PLOT WITH DISCRETE Z: Scatter Plot with Trendline
ggplot(dplyr::sample_frac(clean_df,0.33), aes(x=tick, y=dead_people)) +
  geom_point(size=0.1,alpha=0.2,aes(group=run_number, color=global_confinement_measures)) +
  geom_smooth(aes(color = global_confinement_measures, linetype=global_confinement_measures),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_colour_manual(values=c("red1","gray10")) +
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Deaths") + 
  labs(title="Mortality Plot",
       subtitle="Deaths & Lockdown Measures", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()
