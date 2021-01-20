# ASSOCC
#=============================================================
#================== DATA LOADING FUNCTIONS ===================
#=============================================================

# READ DATA ---------------------------------------------------------------
loadData <- function(p_files_path, p_files_names) {
  
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

# REMOVE INVALID RUNS ---------------------------------------------------------------

cleanData <- function(p_df, p_infected_max_below_remove) {
  
  # remove all invalid runs, 1) for every run
  p_clean_df <- p_df
  r_removed <- 0
  print(paste("Removing runs that are invalid: infected <",p_infected_max_below_remove))
  for(i in 1:max(p_df$X.run.number.)) {
    # 2) get maximum number of infected and compare with infected_max_below_remove
    if (max(p_df[p_df$X.run.number.==i, ]$X.infected) < p_infected_max_below_remove) {
      p_clean_df <- p_clean_df[p_clean_df$X.run.number!=i, ]
      print(paste(".. removed run", i, ", infected ", max(p_df[p_df$X.run.number.==i, ]$X.infected), "<", p_infected_max_below_remove))
      r_removed <- r_removed + 1
    }
  }
  print(paste("Removed",r_removed,"runs"))
  return(p_clean_df)
}

# RENAME VARIABLES ---------------------------------------------------------------
printColumnNames <- function(p_clean_df) {
  
  variable_names <- names(p_clean_df)
  index <- 1
  for (i in variable_names) {
    # print(i)
    print(paste("Column", index, "is called:", i))
    index <- index + 1
  }
}

#=============================================================
#============== DATA MANIPULATION FUNCTIONS ==================
#=============================================================
dmfConvertTicksToDay <- function(p_tick_vector) {
  
  ticks_per_day = 4
  v_days <- floor(p_tick_vector / ticks_per_day)
  return(v_days)
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
