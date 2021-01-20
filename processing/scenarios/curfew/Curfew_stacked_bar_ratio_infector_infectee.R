#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewStackedBarRatioInfectorInfectee <- function(df_scenario6, output_dir, one_plot) {
  
  name = "curfew_stacked_bar_ratio_infector_infectee"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  #Take the mean of all the runs for all the ticks
  df_ratio_infections <- df_scenario6 %>% 
    group_by(curfew_type) %>% 
    summarise(ratio_infections_young_age_young_age   = mean(ratio_infections_young_age_young_age, na.rm = TRUE),
              ratio_infections_young_age_student_age = mean(ratio_infections_young_age_student_age, na.rm = TRUE),
              ratio_infections_young_age_worker_age  = mean(ratio_infections_young_age_worker_age, na.rm = TRUE),
              ratio_infections_young_age_retired_age = mean(ratio_infections_young_age_retired_age, na.rm = TRUE),
              ratio_infections_student_age_young_age   = mean(ratio_infections_student_age_young_age, na.rm = TRUE),
              ratio_infections_student_age_student_age = mean(ratio_infections_student_age_student_age, na.rm = TRUE),
              ratio_infections_student_age_worker_age  = mean(ratio_infections_student_age_worker_age, na.rm = TRUE),
              ratio_infections_student_age_retired_age = mean(ratio_infections_student_age_retired_age, na.rm = TRUE),
              ratio_infections_worker_age_young_age   = mean(ratio_infections_worker_age_young_age, na.rm = TRUE),
              ratio_infections_worker_age_student_age = mean(ratio_infections_worker_age_student_age, na.rm = TRUE),
              ratio_infections_worker_age_worker_age  = mean(ratio_infections_worker_age_worker_age, na.rm = TRUE),
              ratio_infections_worker_age_retired_age = mean(ratio_infections_worker_age_retired_age, na.rm = TRUE),
              ratio_infections_retired_age_young_age   = mean(ratio_infections_retired_age_young_age, na.rm = TRUE),
              ratio_infections_retired_age_student_age = mean(ratio_infections_retired_age_student_age, na.rm = TRUE),
              ratio_infections_retired_age_worker_age  = mean(ratio_infections_retired_age_worker_age, na.rm = TRUE),
              ratio_infections_retired_age_retired_age = mean(ratio_infections_retired_age_retired_age, na.rm = TRUE))
  colnames(df_ratio_infections)
  
  # Make list for each of the app usage
  df_list_ratio_infections = split(df_ratio_infections, f = df_ratio_infections$curfew_type)
  
  # I know, from this point it gets pretty ugly, but I didn't manage to make it in a different way
  # And using for loops with very small dataframes is fine
  df_list_wide_ratio_infections = list()
  for (i in 1:length(df_list_ratio_infections)) {
  
    # Take an app usage from the list
    temp_ratio_infections = df_list_ratio_infections[[i]]
    
    # Manually adjust the wide, so it contains an infectee and infector column
    temp_wide_ratio_infections <- gather(temp_ratio_infections, infectee_infector, ratio, factor_key=TRUE, ratio_infections_young_age_young_age:ratio_infections_retired_age_retired_age)
    temp_wide_ratio_infections$infectee_infector <- gsub("_age_", "_age.", temp_wide_ratio_infections$infectee_infector)
    temp_wide_ratio_infections$infectee_infector <- gsub("_", "", temp_wide_ratio_infections$infectee_infector)
    temp_wide_ratio_infections$infectee_infector <- gsub("ratioinfections", "", temp_wide_ratio_infections$infectee_infector)
    temp_wide_ratio_infections <- temp_wide_ratio_infections %>% separate(infectee_infector, c("infectee", "infector"))
    
    # Add dataframe to list
    df_list_wide_ratio_infections <- c(df_list_wide_ratio_infections, list(temp_wide_ratio_infections))
  }
  
  # Calculate for type of infectee
  df_list_wide_ratio_infections_real = list()
  for (i in 1:length(df_list_wide_ratio_infections)) {
    
    # Temp_wide_ratio_infections
    t_w_r_i <- df_list_wide_ratio_infections[[i]]
    t_w_r_i$raw_summed_ratio <- rep(0, nrow(t_w_r_i))
    
    # Calculate the sum of raw ratio
    for (infectee_age in levels(as.factor(t_w_r_i$infectee))) {
      summed_raw_summed_ratio_y <- sum(t_w_r_i[t_w_r_i$infectee==infectee_age, ]$ratio)
      t_w_r_i <- within(t_w_r_i, raw_summed_ratio[infectee==infectee_age] <- summed_raw_summed_ratio_y)
    }
    
    # Divide raw ratio by summed raw ratio
    t_w_r_i <- t_w_r_i %>% 
      select(curfew_type:raw_summed_ratio) %>% 
      mutate(real_ratio = ratio/raw_summed_ratio)
    
    # Rename
    t_w_r_i$infectee <- gsub("youngage", "Young", t_w_r_i$infectee)
    t_w_r_i$infector <- gsub("youngage", "Young", t_w_r_i$infector)
    t_w_r_i$infectee <- gsub("studentage", "Student", t_w_r_i$infectee)
    t_w_r_i$infector <- gsub("studentage", "Student", t_w_r_i$infector)
    t_w_r_i$infectee <- gsub("workerage", "Worker", t_w_r_i$infectee)
    t_w_r_i$infector <- gsub("workerage", "Worker", t_w_r_i$infector)
    t_w_r_i$infectee <- gsub("retiredage", "Retired", t_w_r_i$infectee)
    t_w_r_i$infector <- gsub("retiredage", "Retired", t_w_r_i$infector)
      
    # Order the factors
    t_w_r_i$infectee <- factor(t_w_r_i$infectee, levels = c("Young", "Student", "Worker", "Retired"))
    t_w_r_i$infector <- factor(t_w_r_i$infector, levels = c("Young", "Student", "Worker", "Retired"))
    
    # Add dataframe to list
    df_list_wide_ratio_infections_real <- c(df_list_wide_ratio_infections_real, list(t_w_r_i))
  }
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_list_wide_ratio_infections_real, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
 
  print(paste(name, " making plots", sep=""))

  for (i in 1:length(df_list_wide_ratio_infections_real)) {
    
    df_plot <- df_list_wide_ratio_infections_real[[i]]
    
    # Add label_ypos
    df_plot <- ddply(df_plot, "infectee", transform, label_ypos= cumsum(real_ratio) - 0.5*real_ratio)
    
    p_title = paste("Ratio infectors per infectee - curfew type: ", unique(df_plot$curfew_type), sep="")
    dmfPdfOpen(output_dir, paste("curfew_ratio_infector_infectee_app_", unique(df_plot$curfew_type), sep=""))
    print(plot_ggplot_bar(df_plot, p_title))
    dmfPdfClose()
  }
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot_bar <- function(data_to_plot, p_title = "None") {
  
  data_to_plot %>% ggplot(aes(x=infectee, y=real_ratio, fill=infector)) +
    geom_bar(stat="identity")+
    geom_text(aes(y=1-label_ypos, label=round(real_ratio, digits=3), vjust="middle"), 
              color="white", size=3.5) +
    scale_fill_brewer(palette="Paired", name="Infector age") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Infectee age group", y="Ratio infectors") +
    gl_plot_theme
}
