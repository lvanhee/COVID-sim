#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoPoverty <- function(df_economy, output_dir, one_plot) {
  
  name = "Poverty_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # CONTACTS PER GATHERING POINT PER APP USAGE SCENARIO ----------------------------

  #group_by(tick) %>% summarise(total = mean(count_people_with_not_is_young_and_is_in_poverty))

  # Add days converted from ticks
  df_economy$day <- dmfConvertTicksToDay(df_economy$tick)  
  
  # Calculate contacts per day per gathering point
  df_contacts_gp_by_day <- df_economy %>% 
    group_by(run_number, day) %>% 
    summarise(total = mean(count_people_with_not_is_young_and_is_in_poverty))
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_contacts_gp_by_day, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_contacts_gp_by_day <- gather(df_contacts_gp_by_day, variable, measurement, total)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "s6_contacts_per_agent")
  print(plot_ggplot(seg_contacts_gp_by_day))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "s6_contacts_per_agent_smooth")
  print(plot_ggplot_smooth(seg_contacts_gp_by_day))
  dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_line(size=0.5,alpha=0.3,aes(color=run_number, group = run_number)) + 
    #continues_colour_brewer(palette = "Spectral", name="App users ratio") +
    xlab("Days") +
    ylab("number of people in poverty") + 
    labs(title="Poverty numbers",
         subtitle="Total number of people in poverty over time", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_smooth(aes(col=run_number, group = run_number), span=0.1, se=FALSE) +
    #scale_colour_brewer(palette = "Spectral", name="App users ratio") +
    xlab("Days") +
    ylab("number of people in poverty") + 
    labs(title="Poverty numbers",
         subtitle="Total number of people in poverty over time (smoothed)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}