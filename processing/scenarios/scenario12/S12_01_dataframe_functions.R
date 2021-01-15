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
      temp_df$file_name <- p_files_names[i]
      t_df <- rbind(t_df, temp_df)
    } else {
      t_df <- read.csv(paste(p_files_path, p_files_names[i], sep=""), skip = 6, sep = ",",head=TRUE,stringsAsFactors = TRUE)
      t_df$file_name <- p_files_names[i]
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

dmfCalculatePhaseLengths <- function(p_df) {
  splitted_by_run_number <- split(p_df, p_df$run_number)
  length_by_run <- NULL
  
  for (run in splitted_by_run_number) {
    no_crisis_line <- match("crisis-not-acknowledged", run$current_governmental_model_phase)
    ongoing_crisis_line <- match("ongoing crisis", run$current_governmental_model_phase)
    phase_1_line <- match("phase-1", run$current_governmental_model_phase)
    phase_2_line <- match("phase-2", run$current_governmental_model_phase)
    phase_3_line <- match("phase-3", run$current_governmental_model_phase)
    no_crisis_lenght <- (run[ongoing_crisis_line,]$tick) - run[no_crisis_line,]$tick
    if(is.na(phase_1_line)) {
      phase_1_line <- which.max(run$tick)
    }
    ongoing_crisis_length <- (run[phase_1_line,]$tick) - run[ongoing_crisis_line,]$tick
    phase_1_newly_infected <- sum(run[(phase_1_line-3):phase_1_line,]$newly_infected_this_tick)
    if(is.na(phase_2_line)) {
      phase_2_line <- which.max(run$tick)
    }
    phase_1_length <- run[phase_2_line,]$tick - run[phase_1_line,]$tick
    phase_2_newly_infected <- sum(run[(phase_2_line-3):phase_2_line,]$newly_infected_this_tick)
    if(is.na(phase_3_line)) {
      phase_3_line <- which.max(run$tick)
    }
    phase_2_length <- run[phase_3_line,]$tick - run[phase_2_line,]$tick
    phase_3_newly_infected <- sum(run[(phase_3_line-3):phase_3_line,]$newly_infected_this_tick)
    phase_3_length <- max(run$tick) - run[phase_3_line,]$tick
    ongoing_crisis_start <- run[ongoing_crisis_line,]$tick
    
    min_days <- run[1,]$minimum_days_between_phases
    length_by_run <- rbind(length_by_run, data.frame(run=run[1,]$run_number, 
                                                     experiment_name=run[1,]$experiment_name, 
                                                     acknowledgement_ratio=run[1,]$acknowledgement_ratio, condition_phasing_out=run[1,]$condition_phasing_out,
                                                     minimum_days_between_phases=run[1,]$minimum_days_between_phases, next_phase_condition_percentage=run[1,]$next_phase_condition_percentage,
                                                     no_crisis_start=run[no_crisis_line,]$tick, ongoing_crisis_start=run[ongoing_crisis_line,]$tick,
                                                     phase_1_start=run[phase_1_line,]$tick, phase_2_start=run[phase_2_line,]$tick,
                                                     phase_3_start=run[phase_3_line,]$tick,
                                                     phase_1_minimum_start=ongoing_crisis_start + min_days,
                                                     phase_2_minimum_start=ongoing_crisis_start + 2*min_days,
                                                     phase_3_minimum_start=ongoing_crisis_start + 3*min_days,
                                                     no_crisis_length=no_crisis_lenght, ongoing_crisis_length=ongoing_crisis_length,
                                                     phase_1_newly_infected=phase_1_newly_infected,
                                                     phase_2_newly_infected=phase_2_newly_infected,
                                                     phase_3_newly_infected=phase_3_newly_infected,
                                                     phase_1_length=phase_1_length, phase_2_length=phase_2_length,
                                                     phase_3_length=phase_3_length))
  }
  return(pivot_longer(length_by_run, 
                      no_crisis_start:phase_3_length, 
                      names_to = c("phase", ".value"), names_pattern = "([^_]*_[^_]*)_(.*)", values_to = "value"))
  return(length_by_run)
}

dmfPhaseLengthPlotLabels <- function(phase_lengths_to_plot, ctrl_var) {
  ctrl_var <- enquo(ctrl_var)
  
  data <- phase_lengths_to_plot %>%
    pivot_longer(names_to = "col", values_to = "start", cols = ends_with("_start"))
  data$phase <- data$col %>%
    sub("_start", "", .) %>%
    sub("_", " ", .)
  data$col <- NULL
  
  data$y <- - 70 * (as.numeric(as.factor(data[[rlang::as_name(ctrl_var)]])) - 1)
  return(data)
}

dmfPdfOpen <- function(p_output_dir, p_file_name, p_width=10, p_height=7, one_plot=FALSE) {
  
  if (!one_plot) {
    pdf(paste(p_output_dir, "/", p_file_name, ".pdf", sep=""), p_width, p_height)
  }
}

dmfPdfClose <- function(one_plot=FALSE) {
  
  if (!one_plot) {
    dev.off()
  }
}

dmfPrintTime <- function(msg) {
  print(paste(strftime(Sys.time(), "%H:%M"), msg, sep="|> "))
}

tag_facet <- function(p, open = "(", close = ")", tag_pool = letters, x = Inf, y = Inf, 
                      hjust = 1.5, vjust = 1.5, fontface = 1, family = "", ...) {
  gb <- ggplot_build(p)
  lay <- gb$layout$layout
  tags <- cbind(lay, label = paste0(open, tag_pool[lay$PANEL], close), x = x, y = y)
  if (nrow(tags) > 1) {
  p + geom_text(data = tags, aes_string(x = "x", y = "y", label = "label"), ..., hjust = hjust, 
                vjust = vjust, fontface = fontface, family = family, inherit.aes = FALSE)
  } else {
    p
  }
}