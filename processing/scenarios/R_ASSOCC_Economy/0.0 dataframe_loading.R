# ASSOCC
# R Coding standard
# - Variables: with line _, e.g. df_test_2
#   * p_test (parameter variable)
#   * gl_test (global variable)
#   * df_test (dataframe variable)
#   * v_test (vector variable)
# - Functions: camelCase, e.g. loadData

#=============================================================
#========================== STARTUP ==========================
#=============================================================

#install.packages("ggplot2")
#install.packages("plotly")
#install.packages("tidyr")
#install.packages("tidyverse")
#install.packages("dplyr")
#install.packages("here")
#install.packages("plyr")

#first empty working memory
rm(list=ls())

#then load relevant libraries
library(here)
### The manual input of setting the directory is changed with the here() function, this function automatically finds the workplace ###
# If the program gives an error here please reload R so it unloads all the packages (plyr also has a function called here())
# detach
#detach("package:plyr", unload=TRUE)
setwd(here()) 
getwd()
library(plyr) # the plyr library also create a here() function, therefore we use the here() function before, its pretty cheap but it works
library(plotly)
library(ggplot2)
library(tidyverse)
library(tidyr)
library(dplyr)

#=============================================================
#========================= SET FILES =========================
#=============================================================

#Make sure the R script with functions is placed in the working directory!
rm(list=ls())
source("0.1 dataframe_functions.r")

### MANUAL INPUT: Optionally specify filepath (i.e. where the behaviorspace csv is situated) ###
#NOTE: if csv files are placed in the workdirec, then leave filesPath unchanged
filesPath <- ""

#=================== MANUAL INPUT: specify filenames ====================
dataFileName <- c("covid-sim economy-table_17-11-2020.csv")
filesNames   <- dataFileName

#=============================================================
#========================= LOAD DATA =========================
#=============================================================

df <- dlfLoadData(filesPath, filesNames)

#========================== Drop wrong columns ==========================
#run this code if there are columns in the data that should be removed
#drop_names <- c("X.contacts.in.pubtrans.1")
#print(paste("Removing the following columns manually:", drop_names))
#drop irrelevant variables
#df_clean <- dplyr::select(df,-c(drop_names))

df_clean <- df

#========================== Rename the columns ==========================
old_variable_names <- names(df_clean)

df_renamed <- updateColumnNames(df_clean)

colnames(df_renamed)[match("step", colnames(df_renamed))] = "tick";

df_names_compare <- data.frame("new" = names(df_renamed), "old" = old_variable_names)
print("Renamed the dateframe, please check the df_names_compare dataframe for correct column translation")

#========================== Remove invalid runs ==========================
# Might not be relevant for our economy runs, but left here as a reminder. With 0 it doesn't do anything.

###
df_renamed$infected <- rep(5, nrow(df_renamed))
###

#runs that have a lower amount of maximum infected are seen as invalid as the virus did not spread and are therefore removed
#specify the minimum number of infected people for a run to be considered as valid (5 person by default)
minimal_number_infected = 0
df_renamed_infected_remove <- dlfRemoveFailedInfectionsRuns(df_renamed, minimal_number_infected)

# If runs are not finished, if they do not go until the final tick amount they are removed
df_renamed_infected_and_unfinished_remove <- dlfRemoveUnfinishedRuns(df_renamed_infected_remove)
df_economy <- df_renamed_infected_and_unfinished_remove 

#========================== Show invalid runs report ==========================
# p_df_full         <- df_renamed %>% select(run_number:tick)
# p_df_removed_runs <- df_renamed_infected_and_unfinished_remove %>% select(run_number:tick)
# df_included_runs_report  <- dlfCreateIncludedRunsReport(p_df_full, p_df_removed_runs)

#this part assumes variable order from NetLogo where independent variable is between run_number and tick.
p_df_full         <- df_renamed %>% select(run_number:tick, -random_seed)
p_df_removed_runs <- df_renamed_infected_and_unfinished_remove %>% select(run_number:tick, -random_seed)
df_included_runs_report  <- dlfCreateIncludedRunsReport(p_df_full, p_df_removed_runs)

#========================== Clean up variables ==========================
rm(list = c("df", "df_clean", "df_renamed", "old_variable_names", "p_df_full", 
            "df_renamed_infected_and_unfinished_remove", "df_renamed_infected_remove", "p_df_removed_runs"))


#=============================================================
#========================== !PLOTS! ==========================
#=============================================================
plotAllPlots <- function() {
  
  #========================== Set the independent variable ==========================
  #p_independent_variable <- enquo(p_independent_variable)
  
  # Create a new folder for the plots and csv's and set the output_dir as variable
  date_time = gsub(":", ".", gsub(" ", "_" , substr(Sys.time(),1,nchar(Sys.time()))))
  output_dir = paste("output_plots_", date_time, sep="")
  dir.create(output_dir)
  if (one_plot) {
    pdf(paste(output_dir, "/economy_plots_", date_time, "_", str_remove(dataFileName[1], ".csv"), ".pdf", sep=""), width=9, height=6)
  }
  
  dlfPlotIncludedRunsReport(df_included_runs_report, output_dir)

  source("1.0_Infected_plot.r")
  plotEcoInfected(df_economy, output_dir, one_plot)
  
  source("1.0_Lockdown_plot.r")
  plotEcoLockdown(df_economy, output_dir, one_plot)
  
  source("1.0_people_capital_plot.r")
  plotEcoPeopleCapital(df_economy, output_dir, one_plot)
  
  source("1.0_company_capital_plot.r")
  plotEcoCompanyCapital(df_economy, output_dir, one_plot)
  
  source("1.0_company_goods_plot.r")
  plotEcoCompanyGoods(df_economy, output_dir, one_plot)
  
  source("1.0_velocity_plot.r")
  plotEcoVelocity(df_economy, output_dir, one_plot)
  
  # source("S6_infected_compliance_tests.r")
  # plotS6InfectedComplianceTests(df_economy, p_independent_variable, output_dir, one_plot)
  # source("S6_contacts_per_day.r")
  # plotS6ContactsPerDay(df_economy, p_independent_variable, output_dir, one_plot)

  
  if (one_plot) {
    dev.off()
  }
}

#========================== Plot settings ==========================
# Specify whether to have all plots in one pdf (TRUE) or in separate files (FALSE)
one_plot <- TRUE

# Adjust names, theme and the scales of the plots
gl_plot_guides <- guides(colour = guide_legend(override.aes = list(size=5, alpha=1)))
gl_plot_theme  <-  theme_bw()

# Specify the independent variable, the variable to separate the data on
plotAllPlots()