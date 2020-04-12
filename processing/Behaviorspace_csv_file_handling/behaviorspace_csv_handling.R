rm(list=ls())
#specify working directory
workdirec <- " ... "
#specify filepath (i.e. where the behaviorspace csv is situated)
filepath <- " ... "
setwd(workdirec)

#load relevant libraries
library(ggplot2)
library(tidyverse)
library(plotly)

# READ DATA ---------------------------------------------------------------

#read in datafile
df <- read.csv(filepath, skip = 6, sep = ",",head=TRUE,stringsAsFactors = FALSE)
names(df)

# CLEAN DATA (REMOVE IRRELEVANT VARIABLES) ---------------------------------------------------------------

#create list of irrelevant variables
#first load all variable names into list
all_names <- names(df)

#if needed, select variable names to be dropped from the dataframe by indexing those ...
#or simply typing the names.
drop_names <- c(all_names[1:11],"some_variable_name")

#drop irrelevant variables
df <- dplyr::select(df,-c(drop_names))

# TRANSFORM DATAFRAME -----------------------------------------------------

#create convenient variable names
colnames(df)[1] = "run_number"
colnames(df)[2] = "step"
colnames(df)[3] = "hedonism"
colnames(df)[4] = "stimulation"
colnames(df)[5] = "self_direction"
colnames(df)[6] = "universalism"
colnames(df)[7] = "benevolence"
colnames(df)[8] = "conformity_tradition"
colnames(df)[9] = "security"
colnames(df)[10] = "power"
colnames(df)[11] = "achievement"

#check whether all variables now have convenient names
names(df)

#Netlogo outputs the agent variables into one big string for each reporter variable (i.e. metric) ...
#If one needs to create a separate variable for each individual agent for each metric,
#then the following blocks of code will help to that.

#create new column names, one for each metric (9x) and for each agent (500x),
#thereby creating 500 x 9 = 4500 variables
n_agents = 500
HED = paste0("hedonism_agent",1:n_agents)
STM = paste0("stimulation_agent",1:n_agents)
SD = paste0("self_direction_agent",1:n_agents)
UNI = paste0("universalism_agent",1:n_agents)
BEN = paste0("benevolence_agent",1:n_agents)
CT = paste0("conformity_tradition_agent",1:n_agents)
SEC = paste0("security_agent",1:n_agents)
POW = paste0("power_agent",1:n_agents)
ACH = paste0("achievement_agent",1:n_agents)

#create variables based on column names created in previous step,
#specifically, use the comma as a separator in order to split the list of agent-specific variables
#over the columns created in the previous step.
df <- df %>% separate(hedonism, HED, sep = ",")
df <- df %>% separate(stimulation, STM, sep = ",")
df <- df %>% separate(self_direction, SD, sep = ",")
df <- df %>% separate(universalism, UNI, sep = ",")
df <- df %>% separate(benevolence, BEN, sep = ",")
df <- df %>% separate(conformity_tradition, CT, sep = ",")
df <- df %>% separate(security, SEC, sep = ",")
df <- df %>% separate(power, POW, sep = ",")
df <- df %>% separate(achievement, ACH, sep = ",")

#transform wide dataframe into long format dataframe (in order to make it ggplot compatible)
df_long <- gather(df, variable, measurement, hedonism_agent1:achievement_agent500)
#remove old file to make space on RAM
rm(list = "df")

#transform 'measurement' variable to numeric (as to avoid ggplot errors)
df_long$measurement <- as.numeric(df_long$measurement)
#round 'measurement' variable to 4 decimals
df_long$measurement <- round(df_long$measurement, 4)

#alter content of 'variable' column: create a factor variable with [Number of Metrics] levels 
df_long$variable <- ifelse(
  grepl("hedonism", df_long$variable),
  "hedonism",
  ifelse(
    grepl("stimulation", df_long$variable),
    "stimulation",
    ifelse(
      grepl("self_direction", df_long$variable),
      "self_direction",
      ifelse(
        grepl("universalism", df_long$variable),
        "universalism",
        ifelse(
          grepl("benevolence", df_long$variable),
          "benevolence",
          ifelse(
            grepl("conformity_tradition", df_long$variable),
            "conformity_tradition",
            ifelse(
              grepl("security", df_long$variable),
              "security",
              ifelse(
                grepl("power", df_long$variable),
                "power",
                "achievement")
            )
          )
        )
      )
    )
  )
)

#convert categorical variables to factors (as to avoid ggplot errors)
df_long$variable <- as.factor(df_long$variable)
#perform some small checks to see whether everything is OK
summary(df_long$variable)
str(df_long)

#The dataframe should now be ready for making data visualizations
