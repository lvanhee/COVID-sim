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
# detach("package:plyr", unload=TRUE)
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
source("Curfew_1_dataframe_functions.r")

### MANUAL INPUT: Optionally specify filepath (i.e. where the behaviorspace csv is situated) ###
#NOTE: if csv files are placed in the workdirec, then leave filesPath unchanged
filesPath <- "data/"

### MANUAL INPUT: specify filenames ###

dataFilePattern <- "curfew_2021-01-20_112729.*.csv"
filesNames   <- list.files(path=filesPath, pattern=dataFilePattern)

#=============================================================
#========================= LOAD DATA =========================
#=============================================================

df <- loadData(filesPath, filesNames)

# REMOVE INVALID RUNS ---------------------------------------------------------------
#runs that have a lower amount of maximum infected are seen as invalid and are therefore removed
#specify the minimum number of infected people for a run to be considered as valid (5 person by default)
#the next will fail if the number of infected is not in the data as -> count.people.with..is.infected..
#df <- cleanData(df, 5)

#remove duplicate variable (X.contacts.in.pubtrans.1)
drop_names <- c("X.contacts.in.pubtrans.1")
print(paste("Removing the following columns manually:", drop_names))
#drop irrelevant variables
clean_df <- dplyr::select(df,-c(drop_names))

# RENAME COLUMN NAMES AUTOMATIC ---------------------------------------------------------------
old_variable_names <- names(clean_df)

# This function removes the X. at the beginning of a column name and changes the . to _
updateColumnNames <- function(p_clean_df) {
  
  #change variable names
  for (i in 1:length(p_clean_df)){
    
    col_name = names(p_clean_df)[i];
    # BASIC ADJUSTMENTS
    new_name = str_remove_all(col_name, "X.");
    new_name = str_replace_all(new_name, "\\.\\.\\.\\.", "_")
    new_name = str_replace_all(new_name, "\\.\\.\\.", "_")
    new_name = str_replace_all(new_name, "\\.\\.", "_")
    new_name = str_replace_all(new_name, "\\.", "_")
    if (substr(new_name, nchar(new_name), nchar(new_name)) == "_" ) {
      new_name = substr(new_name, 1, nchar(new_name)-1);
    }
    # ADVANCED ADJUSTMENTS
    new_name = str_remove(new_name, "age_group_to_age_group_")
    colnames(p_clean_df)[i] = new_name;
    print(paste(i ,". ", col_name, " >>> ", new_name, sep=""));
  }
  
  return(p_clean_df)
}
df_scenario6 <- updateColumnNames(clean_df)

# RENAME COLUMN NAMES MANUAL ---------------------------------------------------------------
colnames(df_scenario6)[match("step", colnames(df_scenario6))] = "tick";
colnames(df_scenario6)[match("ratio_of_people_using_the_tracking_app", colnames(df_scenario6))] = "curfew_type";
colnames(df_scenario6)[match("ratio_of_anxiety_avoidance_tracing_app_users", colnames(df_scenario6))] = "ratio_of_anxiety_app_users";
colnames(df_scenario6)[match("count_people_with_epistemic_infection_status_infected", colnames(df_scenario6))] = "believe_infected";

names_compare <- data.frame("new" = names(df_scenario6), "old" = old_variable_names)

rm(list = c("drop_names", "df", "clean_df", "old_variable_names"))
#rm(list=setdiff(ls(), c("df_scenario6","names_compare","dataFileName")))
print("Please check if names_compare has the right names")

df_scenario6 <- mutate(df_scenario6, 
                        curfew_type = case_when(
                          ratio_omniscious_infected_that_trigger_curfew == 0.02 ~ 
                            "Curfew starts at 2% infected, no lockdown",
                          trigger_curfew_when == "35-days-after-start-lockdown" & lockdown_duration == 35 ~ 
                            paste("Lockdown for", lockdown_duration, "days (starting at 2% infected) followed by curfew", sep=" "),
                          trigger_curfew_when == "35-days-after-start-lockdown" & lockdown_duration == 56 ~ 
                            "Lockdown for 35 days (starting at 2% infected) followed by lockdown plus curfew for 21 days",
                          all_self_isolate_for_35_days_when_first_hitting_2_infected == "true" ~ 
                            paste("Lockdown for", lockdown_duration, "days (starting at 2% infected)", sep=" "),
                          TRUE ~ "No restrictions"
                        ))
df_scenario6$curfew_type <- factor(df_scenario6$curfew_type,
                                   levels = c("No restrictions", 
                                              "Lockdown for 35 days (starting at 2% infected)", 
                                              "Lockdown for 56 days (starting at 2% infected)", 
                                              "Curfew starts at 2% infected, no lockdown",
                                              "Lockdown for 35 days (starting at 2% infected) followed by curfew",
                                              "Lockdown for 35 days (starting at 2% infected) followed by lockdown plus curfew for 21 days"))

#=============================================================
#========================== !PLOTS! ==========================
#=============================================================
plotAllPlots <- function() {

  # Create a new folder for the plots and csv's and set the output_dir as variable
  date_time = gsub(":", ".", gsub(" ", "_" , substr(Sys.time(),1,nchar(Sys.time()))))
  output_dir = paste("output_plots_", date_time, sep="")
  dir.create(output_dir)
  if (one_plot) {
    pdf(paste(output_dir, "/curfew_plots_", date_time, ".pdf", sep=""), width=9, height=6)
  }
  
  source("Curfew_infected_compliance_tests.r")
  plotCurfewInfectedComplianceTests(df_scenario6, output_dir, one_plot)
  source("Curfew_contacts_per_day.r")
  plotCurfewContactsPerDay(df_scenario6, output_dir, one_plot)
  source("Curfew_cumulative_infections.r")
  plotCurfewCumulativeInfections(df_scenario6, output_dir, one_plot)
  source("Curfew_stacked_bar_ratio_infector_infectee.r")
  plotCurfewStackedBarRatioInfectorInfectee(df_scenario6, output_dir, one_plot)
  source("Curfew_stacked_bar_ratio_contacts_per_contacted.r")
  plotCurfewStackedBarRatioContactsPerContacted(df_scenario6, output_dir, one_plot)
  source("Curfew_hospital_admissions.r")
  plotCurfewHospitalAdmissions(df_scenario6, output_dir, one_plot)
  source("Curfew_infection_ratio_per_gathering_point_over_time.r")
  plotCurfewInfectionRatioGP(df_scenario6, output_dir, one_plot)
  source("Curfew_infectors_and_infectees.r")
  plotCurfewInfectorsAndInfectees(df_scenario6, output_dir, one_plot)
  source("Curfew_contacts_at_gathering_point.r")
  plotCurfewContactsAtGatheringPoint(df_scenario6, output_dir, one_plot)
  
  if (one_plot) {
    dev.off()
  }
}

# Specify whether to have all plots in one pdf (TRUE) or in separate files (FALSE)
one_plot = TRUE

# Adjust the theme and the scales of the plots
gl_plot_guides = guides(colour = guide_legend(override.aes = list(size=5, alpha=1)))
gl_plot_theme  =  theme_bw()

plotAllPlots()
