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
workdirec <- "C:/Users/loisv/git/COVID-sim/processing/Tutorial_behaviorspace_data_analysis"
setwd(workdirec)
source("functions_behaviorspace_table_output_handling.R")

### MANUAL INPUT: Optionally specify filepath (i.e. where the behaviorspace csv is situated) ###
#NOTE: if csv files are placed in the workdirec, then leave filesPath unchanged
filesPath <- "C:/Users/loisv/Desktop/"
### MANUAL INPUT: specify filenames ###
filesNames <- c("S62.csv")

# READ DATA ---------------------------------------------------------------

df <- loadData(filesPath, filesNames)

# REMOVE INVALID RUNS ---------------------------------------------------------------
#runs that have a lower amount of maximum infected are seen as invalid and are therefore removed
#specify the minimum number of infected people for a run to be considered as valid (5 person by default)
# the next will fail if the number of infected is not in the data as -> count.people.with..is.infected..
df <- cleanData(df, 1)

# REMOVE IRRELEVANT VARIABLES ---------------------------------------------------------------

#Loop through dataframe and identify variables that do NOT vary (i.e. that are FIXED)
#Unfixed variables are either independent or dependent and therefore relevant to include in the analysis
df <- removeVariables(df)

# RENAME VARIABLES ---------------------------------------------------------------
printColumnNames(df)

### MANUAL INPUT: specify new (easy-to-work-with) variable names ###
new_variable_names <- list(
  "run_number",
  "app_user_ratio",
  "psychorigid",
  "tick",
  "infected",
  "dead",
  "officially quarantining",
  "actually quarantining",
  "tests_performed",
  "r0"
)

clean_df <- changeColumnNames(df, new_variable_names)

# TRANSFORM DATAFRAME -----------------------------------------------------

#transform wide dataframe into long format dataframe (in order to make it ggplot compatible)
### MANUAL INPUT: make sure that you specify which variables are to be considered as metrics (i.e. dependent variables)
#As can be seen in clean_df, the dependent variables are (by default) called "infected", "aware_of_infected" and "tests_performed" ...
#...therefore the dataframe transformation revolves around pivoting infected:tests_performed 
df_long <- gather(clean_df, variable, measurement, infected:tests_performed)

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
df_long$app_user_ratio <- as.factor(df_long$app_user_ratio)
df_long$variable <- as.factor(df_long$variable)
#perform some small checks to see whether everything is OK
str(df_long)

# PLOTTING -----------------------------------------------------
clean_df$app_user_ratio <- as.factor(clean_df$app_user_ratio)

export_pdf = TRUE;
if (export_pdf) {
  pdf(file="Scenario 6 - Combined plots.pdf", width=9, height=6);
  par(mfcol=c(2,3))
}

#infected plot with trendline
ggplot(clean_df, aes(x=tick, y=infected, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=c("red1","gray10")) +
  scale_colour_manual(values=c("red1","gray10")) +
  xlim(0, 500) + 
  ylim(0, 700) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Infected People") + 
  labs(title="Infection Plot",
       subtitle="Infected People & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#aware_of_infected plot with trendline
ggplot(clean_df, aes(x=tick, y=dead, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=c("orange1","gray10")) +
  scale_colour_manual(values=c("orange1","gray10")) +
  xlim(0, 500) + 
  ylim(0, 700) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of dead") + 
  labs(title="#dead Infection Plot",
       subtitle="#dead & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#hospital_admissions plot with trendline
ggplot(clean_df, aes(x=tick, y=hospital_admissions, fill=app_user_ratio)) +
  geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=c("pink1","gray10")) +
  scale_colour_manual(values=c("pink1","gray10")) +
  xlim(0, 500) + 
  ylim(0, 20) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of People Hospitalized") + 
  labs(title="Hospitalization Plot",
       subtitle="Hospitalization & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#taken_hospital_beds plot with trendline
ggplot(clean_df, aes(x=tick, y=taken_hospital_beds, fill=app_user_ratio)) +
  geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=c("purple1","gray10")) +
  scale_colour_manual(values=c("purple1","gray10")) +
  xlim(0, 500) + 
  ylim(0, 200) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Occupied Hospital Beds") + 
  labs(title="Occupied Hospital Beds Plot",
       subtitle="Occupied Hospital Beds & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#cumulative_deaths plot with trendline
ggplot(clean_df, aes(x=tick, y=cumulative_deaths, fill=app_user_ratio)) +
  geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=c("gray50","gray10")) +
  scale_colour_manual(values=c("gray50","gray10")) +
  xlim(0, 500) + 
  ylim(0, 50) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Deaths") + 
  labs(title="Number of Deaths Plot",
       subtitle="Number of Deaths & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#tests_performed plot with trendline
ggplot(clean_df, aes(x=tick, y=tests_performed, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  # scale_colour_gradient(low = "red", high = "gray20") +
  scale_fill_manual(values=c("blue1","gray10")) +
  scale_colour_manual(values=c("blue1","gray10")) +
  xlim(0, 500) + 
  ylim(0, 15000) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Tests") + 
  labs(title="Number of Tests Plot",
       subtitle="Tests & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

# Ending of export to pdf
if (export_pdf) {
  dev.off();
}

#line plot
#ggplot(data = clean_df, mapping = aes(x = tick, y = infected, group = run_number)) + 
#  scale_colour_gradient(low = "red", high = "red4") +
#  geom_line(size=1,alpha=1,aes(color=app_user_ratio)) + 
#  xlab("x-label") +
#  ylab("y-label") + 
#  ggtitle("some title") +
#  labs(title="Title",
#       subtitle="Subtitle", 
#       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#  theme_linedraw()

