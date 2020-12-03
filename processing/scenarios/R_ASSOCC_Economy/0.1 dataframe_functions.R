# ASSOCC
#=============================================================
#================== DATA LOADING FUNCTIONS ===================
#=============================================================

# READ DATA ---------------------------------------------------------------
dlfLoadData <- function(p_files_path, p_files_names) {
  
  #read in datafiles using filesNames and filesPath variables
  for (i in 1:length(p_files_names)) {
    print(paste("read csv from:", p_files_path, p_files_names[i], sep=""))
    #bind data from dataframe into new dataframe
    if (exists('t_df') && is.data.frame(get('t_df'))) {
      temp_df <- read.csv(paste(p_files_path, p_files_names[i], sep=""), skip = 6, sep = ",",head=TRUE,stringsAsFactors = TRUE)
      temp_df$X.run.number. <- temp_df$X.run.number + max_run_number
      t_df <- rbind(t_df, temp_df)
    } else {
      t_df <- read.csv(paste(p_files_path, p_files_names[i], sep=""), skip = 6, sep = ",",head=TRUE,stringsAsFactors = TRUE)
    }
    max_run_number <- max(t_df$X.run.number.)
  }
  return(t_df)
}

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

# REMOVE unfinished runs
dlfRemoveUnfinishedRuns <- function(p_df) {
  
  print("Removing unfinished runs")
  df_summarized_ticks <- p_df %>% 
    group_by(run_number) %>% summarise(tick = sum(tick, na.rm = TRUE))
  
  sum_correct_ticks <- max(df_summarized_ticks$tick)
  df_wrong_run_number <- df_summarized_ticks[df_summarized_ticks$tick != sum_correct_ticks, ]
  
  if (nrow(df_wrong_run_number) == 0) {
    print("Removed no runs, all runs were finished!")
    return(p_df)
  }
  
  for (i in 1:nrow(df_wrong_run_number)) {
    p_df <- subset(p_df, run_number!=df_wrong_run_number$run_number[i])
    message(paste("Removed run number: ", df_wrong_run_number$run_number[i], sep="") )
  }
  
  return(p_df)
}

# Remove failed because of low amount of infections run
dlfRemoveFailedInfectionsRuns <- function(p_df, p_min_required_n_infections) {
  
  print(paste("Removing runs that are invalid: infected <", p_min_required_n_infections))
  
  df_max_infections_per_run <- p_df %>% 
    group_by(run_number) %>% summarise(infected = max(infected, na.rm = TRUE))
  
  df_max_infections_per_run_failed <- df_max_infections_per_run %>% 
    filter(infected < p_min_required_n_infections) 
  
  if (nrow(df_max_infections_per_run_failed) == 0) {
    print(paste("Removed no runs, all runs had more than", p_min_required_n_infections, "infected!"))
    return(p_df)
  }

  p_df_clean <- p_df
  for (i in 1:nrow(df_max_infections_per_run_failed)) {
    t_run_number <- df_max_infections_per_run_failed$run_number[i]
    p_df_clean <- p_df_clean %>% filter(run_number != t_run_number)
    message(paste("Removed run number: ", t_run_number, " with infected ", df_max_infections_per_run_failed$infected[i], sep="") )
  }
  
  return(p_df_clean)
}

# This function creates the dataframe used to report the
dlfCreateIncludedRunsReport <- function(p_df_full, p_df_removed_runs) {
  
  # take all the runs with tick 0
  p_df_full         <- p_df_full %>% filter(tick == 0)
  p_df_removed_runs <- p_df_removed_runs %>% filter(tick == 0)
  
  # remove run_number and tick column
  p_df_full         <- p_df_full %>% select(-run_number, -tick)
  p_df_removed_runs <- p_df_removed_runs %>% select(-run_number, -tick)
  
  # save the column names
  p_names_full         <- names(p_df_full)
  
  # concatenate the columns in the dataframe
  p_df_full         <- p_df_full %>% unite("run_setting", 1:ncol(p_df_full), na.rm = TRUE, remove = FALSE, sep = ", ")
  p_df_removed_runs <- p_df_removed_runs %>% unite("run_setting", 1:ncol(p_df_removed_runs), na.rm = TRUE, remove = FALSE, sep = ", ")
  
  # add the number 1 to each row for counting
  p_df_full$count           <- rep(1, nrow(p_df_full))
  p_df_removed_runs$count   <- rep(1, nrow(p_df_removed_runs))

  # count the number of runs per different setting
  p_df_full         <- p_df_full %>% group_by(run_setting) %>% summarise(count = sum(count))
  p_df_removed_runs <- p_df_removed_runs %>% group_by(run_setting) %>% summarise(count = sum(count))
  
  # add the removed_runs column
  p_df_full$removed_runs         <- rep(FALSE, nrow(p_df_full))
  p_df_removed_runs$removed_runs <- rep(TRUE, nrow(p_df_removed_runs))
  
  p_df_full         <- rbind(p_df_full, p_df_removed_runs)
  
  # add the names
  p_df_full$setting_names      <- rep(paste(p_names_full, collapse = ', '), nrow(p_df_full))
  
  # append column
  return(p_df_full)
}

dlfPlotIncludedRunsReport <- function(p_df_runs_report, p_output_dir) {

  print("Printing included runs report")
  dmfPdfOpen(p_output_dir, "s_failed_and_succesful_runs_report")

  plot <- ggplot(data=p_df_runs_report, aes(x=run_setting, y=count, fill=removed_runs)) +
    geom_bar(stat="identity", position=position_dodge()) +
    gl_plot_theme +
    theme(axis.title.x = element_text(size=7), axis.text.x = element_text(angle = 90)) +
    xlab(p_df_runs_report$setting_names[1]) +
    ylab("Number of runs per setting") +
    labs(title=paste("Completed and incomplete runs per setting"),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         fill="Run removed") +
    scale_fill_manual(values=c('#004394','#de2900'))
  
  print(plot)
  dmfPdfClose()
}

#=============================================================
#============== DATA MANIPULATION FUNCTIONS ==================
#=============================================================
dmfConvertTicksToDay <- function(p_tick_vector) {
  
  ticks_per_day = 4
  v_days <- floor(p_tick_vector / ticks_per_day)
  return(v_days)
}

dmfConvertDaysToWeek <- function(p_day_vector) {
  
  days_per_week = 7
  v_weeks <- floor(p_day_vector / days_per_week)
  return(v_weeks)
}

# This function is a bit of a quick fix, it just checks the first row and sums everything
dmfGetTotalAmountOfPeople <- function(p_df) {
  
  amount_of_people = p_df$youngs_at_start[1] + p_df$students_at_start[1] +
    p_df$workers_at_start[1] + p_df$retireds_at_start[1]
  return(amount_of_people)
}

dmfPdfOpen <- function(p_output_dir, p_file_name, p_width=9, p_height=6) {
  
  if (!one_plot) {
    pdf(paste(p_output_dir, "/", p_file_name, ".pdf", sep=""), p_width, p_height)
  }
}

dmfPdfClose <- function() {
  
  if (!one_plot) {
    dev.off()
  }
}