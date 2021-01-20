#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewInfectorsAndInfectees <- function(df_scenario6, output_dir, one_plot) {
  
  name = "curfew_cummulative_infector_and_infectees"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_cummulative_infectors_and_infectee <- df_scenario6 %>% 
    group_by(tick, curfew_type) %>% 
    summarise(young_infected = mean(cumulative_youngs_infected, na.rm = TRUE),
              young_infector = mean(cumulative_youngs_infector, na.rm = TRUE),
              student_infected = mean(cumulative_students_infected, na.rm = TRUE),
              student_infector = mean(cumulative_students_infector, na.rm = TRUE),
              worker_infected = mean(cumulative_workers_infected, na.rm = TRUE),
              worker_infector = mean(cumulative_workers_infector, na.rm = TRUE),
              retired_infected = mean(cumulative_retireds_infected, na.rm = TRUE),
              retired_infector = mean(cumulative_retireds_infector, na.rm = TRUE))
  colnames(df_cummulative_infectors_and_infectee)

  df_cummulative_infectors_and_infectee$day <- dmfConvertTicksToDay(df_cummulative_infectors_and_infectee$tick)
  
  # Sum for every day (combine the four ticks)
  df_cummulative_infectors_and_infectee_avg_day <- df_cummulative_infectors_and_infectee %>% 
    group_by(day, curfew_type) %>% 
    summarise(young_infected = mean(young_infected, na.rm = TRUE),
              young_infector = mean(young_infector, na.rm = TRUE),
              student_infected = mean(student_infected, na.rm = TRUE),
              student_infector = mean(student_infector, na.rm = TRUE),
              worker_infected = mean(worker_infected, na.rm = TRUE),
              worker_infector = mean(worker_infector, na.rm = TRUE),
              retired_infected = mean(retired_infected, na.rm = TRUE),
              retired_infector = mean(retired_infector, na.rm = TRUE))

  print(paste(name, " writing CSV", sep=""))
  write.csv(df_cummulative_infectors_and_infectee_avg_day, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_infectortee_day <- gather(df_cummulative_infectors_and_infectee_avg_day, Age_group, measurement, young_infected:retired_infector)
  
  print(paste(name, " making plots", sep=""))
  
  for(i in unique(seg_infectortee_day$curfew_type)) {
    dmfPdfOpen(output_dir, paste("curfew_infector_infectee_", i, sep=""))
    print(plot_ggplot(seg_infectortee_day[seg_infectortee_day$curfew_type==i, ], i))
    dmfPdfClose()
  }  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, app_use) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement,
               group = Age_group,
               fill = Age_group), fill=NA) +
    geom_line(aes(col=Age_group)) +
    guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
    xlab("Days") +
    ylab("Cumulative agents infected") +
    labs(title=paste("Cummulative infectors and infectees - curfew type:", app_use),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}
