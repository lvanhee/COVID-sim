# ASSOCC
# R Coding standard
# - Variables: with line _, e.g. df_test_2
#   * p_test (parameter variable)
#   * gl_test (global variable)
#   * df_test (dataframe variable)
#   * v_test (vector variable)
# - Functions: camelCase, e.g. loadData

# Created by René Mellema
# Based on Code by Maarten Jensen

#=============================================================
#========================== STARTUP ==========================
#=============================================================

#first empty working memory
rm(list=ls())

#then load relevant libraries
library(here)
### The manual input of setting the directory is changed with the here() function, this function automatically finds the workplace ###
# If the program gives an error here please reload R so it unloads all the packages (plyr also has a function called here())
# detach("package:plyr", unload=TRUE)
setwd(here::here("scen12"))
getwd()
library(plyr) # the plyr library also create a here() function, therefore we use the here() function before, its pretty cheap but it works
library(plotly)
library(ggplot2)
library(egg)
library(tidyverse)
library(tidyr)
library(dplyr)

#=============================================================
#========================= SET FILES =========================
#=============================================================

#Make sure the R script with functions is placed in the working directory!
source("S12_01_dataframe_functions.R")

### MANUAL INPUT: Optionally specify filepath (i.e. where the behaviorspace csv is situated) ###
#NOTE: if csv files are placed in the workdirec, then leave filesPath unchanged
filesPath <- "data/"

### MANUAL INPUT: specify filenames ###

dataFilePattern <- "scen12_2020-12-08_.*.csv"
filesNames   <- list.files(path=filesPath, pattern=dataFilePattern)

#=============================================================
#========================= LOAD DATA =========================
#=============================================================

dmfPrintTime("Loading files")
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
dmfPrintTime("Renaming variables")
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
df_scenario12 <- updateColumnNames(clean_df)

# RENAME COLUMN NAMES MANUAL ---------------------------------------------------------------
colnames(df_scenario12)[match("step", colnames(df_scenario12))] = "tick";
colnames(df_scenario12)[match("ratio_of_people_using_the_tracking_app", colnames(df_scenario12))] = "ratio_of_app_users";
colnames(df_scenario12)[match("ratio_of_anxiety_avoidance_tracing_app_users", colnames(df_scenario12))] = "ratio_of_anxiety_app_users";
colnames(df_scenario12)[match("count_people_with_epistemic_infection_status_infected", colnames(df_scenario12))] = "believe_infected";

df_scenario12 <- rename(df_scenario12, 
                        c("people_that_queued" = "count_people_with_stayed_out_queuing_for_bus", 
                          "people_that_took_bus" = "sum_map_count_list_of_buses", 
                          "people_that_took_shared_car" = "sum_map_count_list_of_shared_cars"))

to_rename <- Filter(function(col) {
                      startsWith(col, "count_people_with_gathering_type_of_current_activity")
                    },
                    colnames(df_scenario12))
rename_vector <- list()
for (col_name in to_rename) {
  rename_vector[[sub("count_people_with_gathering_type_of_current_activity", "people_at", col_name)]] <- col_name
}
df_scenario12 <- rename(df_scenario12, unlist(rename_vector, use.names = T))

names_compare <- data.frame("new" = names(df_scenario12), "old" = old_variable_names)

rm(list = c("drop_names", "df", "clean_df", "old_variable_names", "to_rename", "rename_vector", "col_name"))
#rm(list=setdiff(ls(), c("df_scenario6","names_compare","dataFileName")))
print("Please check if names_compare has the right names")

# ADDING COLUMNS FOR ALL ------------------------------------------
dmfPrintTime("Adding calculted columns")
df_scenario12 <- mutate(df_scenario12, 
             # Add the experiment name for plotting
             experiment_name = case_when(grepl("Leisure", file_name, fixed=TRUE) ~ "Leisure",
                                         grepl("Business", file_name, fixed=TRUE) ~ "Business",
                                         grepl("PublicServices", file_name, fixed=TRUE) ~ "PublicServices"),
             # Rename the condition phasing out to something more descriptive.
             condition_phasing_out_2 = case_when(
               condition_phasing_out == "new infections percentage of average over day gap" ~ 
                 paste("new infections", next_phase_condition_percentage*100, "percent of average over day gap"),
               condition_phasing_out == "new infections under limit" ~ 
                 paste("new infections under", next_phase_new_infection_limit, "over last", day_gap_for_phasing_out_condition, "days"),
               condition_phasing_out == "percentage immune" ~ 
                 paste(next_phase_condition_percentage*100, "percent immune"),
               TRUE ~ as.character(condition_phasing_out)))
df_scenario12$condition_phasing_out <- relevel(factor(df_scenario12$condition_phasing_out_2), "only look at days since last phase")
df_scenario12 <- dplyr::select(df_scenario12,-c("file_name", "condition_phasing_out_2"))

# Calculate the phase lengths
dmfPrintTime("Calculate phase lengths")
df_phase_lengths <- dmfCalculatePhaseLengths(df_scenario12)

#=============================================================
#========================== !PLOTS! ==========================
#=============================================================
plotAllPlots <- function(one_plot) {
  
  # Create a new folder for the plots and csv's and set the output_dir as variable
  date_time = gsub(":", ".", gsub(" ", "_" , substr(Sys.time(),1,nchar(Sys.time()))))
  output_dir = paste("output_plots_", date_time, sep="")
  dir.create(output_dir)
  if (one_plot) {
    pdf(paste(output_dir, "/s12plots_", date_time, "_", str_remove(fileNames[1], ".csv"), ".pdf", sep=""), width=9, height=6)
  }
  
  source("S12_01_5_Example.R")
  plotS12Example(df_scenario12, df_phase_lengths, output_dir, one_plot)
  
  source("S12_02_Conditions.r")
  plotS12ConditionsMinimumDays(df_scenario12, df_phase_lengths, output_dir, one_plot)
  plotS12ConditionsAckRate(df_scenario12, df_phase_lengths, output_dir, one_plot)
  source("S12_08_boxplots_endstate.R")
  plotS12EndStateBoxplots(filter(df_scenario12, minimum_days_between_phases == 30), acknowledgement_ratio, "Acknowledgement ratio", output_dir, one_plot)
  
  df_scenario12_limited <- df_scenario12 %>%
    filter(!startsWith(as.character(condition_phasing_out), "hospital"), 
           !endsWith(as.character(condition_phasing_out), "day gap"), 
           minimum_days_between_phases == 30, acknowledgement_ratio == 0.02)
  df_phase_lengths_limited <- df_phase_lengths %>%
    filter(!startsWith(as.character(condition_phasing_out), "hospital"), 
           !endsWith(as.character(condition_phasing_out), "day gap"), 
           minimum_days_between_phases == 30, acknowledgement_ratio == 0.02)
  
  plotS12ConditionsExperimentName(df_scenario12_limited, df_phase_lengths_limited, output_dir, one_plot)
  
  # source("S6_contacts_per_day.r")
  # plotS6ContactsPerDay(df_scenario6, output_dir, one_plot)
  source("S12_03_cumulative_infections.r")
  plotS12CumulativeInfections(df_scenario12, df_phase_lengths, minimum_days_between_phases, "Min.days between phases:", output_dir, one_plot)
  plotS12CumulativeInfections(filter(df_scenario12, minimum_days_between_phases == 30), filter(df_phase_lengths, minimum_days_between_phases == 30), 
                              acknowledgement_ratio, "Acknowledgement ratio:", output_dir, one_plot)
  plotS12CumulativeInfections(df_scenario12_limited, df_phase_lengths_limited, experiment_name, "Exit strategy:", output_dir, one_plot)
  source('S12_04_stacked_bar_ratio_infector_infectee.R')
  plotS12StackedBarRatioInfectorInfectee(df_scenario12_limited, output_dir, one_plot)
  source("S12_05_infection_ratio_per_gathering_point_over_time.R")
  plotS12InfectionRatioGP(df_scenario12_limited, df_phase_lengths_limited, output_dir, one_plot)
#  source("S12_06_contacts_at_gathering_point.R")
#  plotS12ContactsAtGatheringPoint(df_scenario12_limited, df_phase_lengths_limited, output_dir, one_plot)
  source("S12_07_people_at_gathering_point.R")
  plotS12PeopleAtGatheringPoint(df_scenario12_limited, df_phase_lengths_limited, output_dir, one_plot)
  source("S12_09_capital.R")
  plotS12CapitalAgents(df_scenario12_limited, df_phase_lengths_limited, output_dir, one_plot)
  source("S12_10_goods.R")
  plotS12Goods(df_scenario12_limited, df_phase_lengths_limited, output_dir, one_plot)
  source("S12_11_broke.R")
  plotS12broke(df_scenario12_limited, df_phase_lengths, output_dir, one_plot)
  
  if (one_plot) {
    dev.off()
  }
}

output_dir <- "output_plots_testing"
# Specify whether to have all plots in one pdf (TRUE) or in separate files (FALSE)
one_plot = FALSE

# Adjust the theme and the scales of the plots
gl_plot_guides = guides(colour = guide_legend(override.aes = list(size=5, alpha=1)))
gl_plot_theme  =  theme_bw()

dmfPrintTime("Creating plots")
plotAllPlots(one_plot)
