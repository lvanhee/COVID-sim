#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewStackedBarRatioContactsPerContacted <- function(df_scenario6, output_dir, one_plot) {
  
  name = "curfew_stacked_bar_ratio_contacts_contacted"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  #Take the mean of all the runs for all the ticks
  df_ratio_contacts <- df_scenario6 %>% 
    group_by(curfew_type) %>% 
    summarise(contacts_young_age_young_age   = mean(contacts_young_age_young_age, na.rm = TRUE),
              contacts_young_age_student_age = mean(contacts_young_age_student_age, na.rm = TRUE),
              contacts_young_age_worker_age  = mean(contacts_young_age_worker_age, na.rm = TRUE),
              contacts_young_age_retired_age = mean(contacts_young_age_retired_age, na.rm = TRUE),
              contacts_student_age_young_age   = mean(contacts_student_age_young_age, na.rm = TRUE),
              contacts_student_age_student_age = mean(contacts_student_age_student_age, na.rm = TRUE),
              contacts_student_age_worker_age  = mean(contacts_student_age_worker_age, na.rm = TRUE),
              contacts_student_age_retired_age = mean(contacts_student_age_retired_age, na.rm = TRUE),
              contacts_worker_age_young_age   = mean(contacts_worker_age_young_age, na.rm = TRUE),
              contacts_worker_age_student_age = mean(contacts_worker_age_student_age, na.rm = TRUE),
              contacts_worker_age_worker_age  = mean(contacts_worker_age_worker_age, na.rm = TRUE),
              contacts_worker_age_retired_age = mean(contacts_worker_age_retired_age, na.rm = TRUE),
              contacts_retired_age_young_age   = mean(contacts_retired_age_young_age, na.rm = TRUE),
              contacts_retired_age_student_age = mean(contacts_retired_age_student_age, na.rm = TRUE),
              contacts_retired_age_worker_age  = mean(contacts_retired_age_worker_age, na.rm = TRUE),
              contacts_retired_age_retired_age = mean(contacts_retired_age_retired_age, na.rm = TRUE))
  colnames(df_ratio_contacts)
  
  # Make list for each of the app usage
  df_list_ratio_contacts = split(df_ratio_contacts, f = df_ratio_contacts$curfew_type)
  
  # I know, from this point it gets pretty ugly, but I didn't manage to make it in a different way
  # And using for loops with very small dataframes is fine
  df_list_wide_ratio_contacts = list()
  for (i in 1:length(df_list_ratio_contacts)) {
  
    # Take an app usage from the list
    temp_ratio_contacts = df_list_ratio_contacts[[i]]
    
    # Manually adjust the wide, so it contains an contacted and contactor column
    temp_wide_ratio_contacts <- gather(temp_ratio_contacts, contacted_contactor, ratio, factor_key=TRUE, contacts_young_age_young_age:contacts_retired_age_retired_age)
    temp_wide_ratio_contacts$contacted_contactor <- gsub("_age_", "_age.", temp_wide_ratio_contacts$contacted_contactor)
    temp_wide_ratio_contacts$contacted_contactor <- gsub("_", "", temp_wide_ratio_contacts$contacted_contactor)
    temp_wide_ratio_contacts$contacted_contactor <- gsub("contacts", "", temp_wide_ratio_contacts$contacted_contactor)
    temp_wide_ratio_contacts <- temp_wide_ratio_contacts %>% separate(contacted_contactor, c("contacted", "contactor"))
    
    # Add dataframe to list
    df_list_wide_ratio_contacts <- c(df_list_wide_ratio_contacts, list(temp_wide_ratio_contacts))
  }
  
  # Calculate for type of contacted
  df_list_wide_ratio_contacts_real = list()
  for (i in 1:length(df_list_wide_ratio_contacts)) {
    
    # Temp_wide_ratio_infections
    t_w_r_c <- df_list_wide_ratio_contacts[[i]]
    t_w_r_c$raw_summed_ratio <- rep(0, nrow(t_w_r_c))
    
    # Calculate the sum of raw ratio
    for (contacted_age in levels(as.factor(t_w_r_c$contacted))) {
      summed_raw_summed_ratio_y <- sum(t_w_r_c[t_w_r_c$contacted==contacted_age, ]$ratio)
      t_w_r_c <- within(t_w_r_c, raw_summed_ratio[contacted==contacted_age] <- summed_raw_summed_ratio_y)
    }
    
    # Divide raw ratio by summed raw ratio
    t_w_r_c <- t_w_r_c %>% 
      select(curfew_type:raw_summed_ratio) %>% 
      mutate(real_ratio = ratio/raw_summed_ratio)
    
    # Rename
    t_w_r_c$contacted <- gsub("youngage", "Young", t_w_r_c$contacted)
    t_w_r_c$contactor <- gsub("youngage", "Young", t_w_r_c$contactor)
    t_w_r_c$contacted <- gsub("studentage", "Student", t_w_r_c$contacted)
    t_w_r_c$contactor <- gsub("studentage", "Student", t_w_r_c$contactor)
    t_w_r_c$contacted <- gsub("workerage", "Worker", t_w_r_c$contacted)
    t_w_r_c$contactor <- gsub("workerage", "Worker", t_w_r_c$contactor)
    t_w_r_c$contacted <- gsub("retiredage", "Retired", t_w_r_c$contacted)
    t_w_r_c$contactor <- gsub("retiredage", "Retired", t_w_r_c$contactor)
      
    # Order the factors
    t_w_r_c$contacted <- factor(t_w_r_c$contacted, levels = c("Young", "Student", "Worker", "Retired"))
    t_w_r_c$contactor <- factor(t_w_r_c$contactor, levels = c("Young", "Student", "Worker", "Retired"))
    
    # Add dataframe to list
    df_list_wide_ratio_contacts_real <- c(df_list_wide_ratio_contacts_real, list(t_w_r_c))
  }
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_list_wide_ratio_contacts_real, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
 
  print(paste(name, " making plots", sep=""))

  for (i in 1:length(df_list_wide_ratio_contacts_real)) {
    
    df_plot <- df_list_wide_ratio_contacts_real[[i]]
    
    # Add label_ypos
    df_plot <- ddply(df_plot, "contacted", transform, label_ypos= cumsum(real_ratio) - 0.5*real_ratio)
    
    p_title = paste("Ratio contactors per contacted - curfew type: ", unique(df_plot$curfew_type), sep="")
    dmfPdfOpen(output_dir, paste("curfew_ratio_contactor_contacted_app_", unique(df_plot$curfew_type), sep=""))
    print(plot_ggplot_bar(df_plot, p_title))
    dmfPdfClose()
  }
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot_bar <- function(data_to_plot, p_title = "None") {
  
  data_to_plot %>% ggplot(aes(x=contacted, y=real_ratio, fill=contactor)) +
    geom_bar(stat="identity")+
    geom_text(aes(y=1-label_ypos, label=round(real_ratio, digits=3), vjust="middle"), 
              color="white", size=3.5) +
    scale_fill_brewer(palette="Paired", name="Contactors age") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Contacted age group", y="Ratio contactors") +
    gl_plot_theme
}
