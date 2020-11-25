#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoInfected <- function(df_economy, output_dir, one_plot) {
  
  name = "Infected_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # Add days converted from ticks
  #df_economy$day <- dmfConvertTicksToDay(df_economy$tick)  
  
  df_infected <- df_economy %>% select(tick, run_number, preset_scenario, infected = count_people_with_is_infected)
  
  #for uncertainty area
  df_infected_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(
                                                                    mean = mean(count_people_with_is_infected)
                                                                    ,std_mean = sd(count_people_with_is_infected))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_infected, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_infected <- gather(df_infected, variable, measurement, infected)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_infected")
  print(plot_ggplot(seg_infected))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_infected_smooth")
  print(plot_ggplot_smooth(seg_infected))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_infected_smooth_uncertainty")
  print( plot_ggplot_smooth_uncertainty(df_infected_mean_std))
  dmfPdfClose() 
  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = measurement)) +
    geom_line(size=0.5,alpha=0.8,aes(color=preset_scenario, group = run_number)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("ticks") +
    ylab("Infected") + 
    labs(title="Infected numbers",
         subtitle="Total number of people infected", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = measurement)) +
    geom_smooth(aes(col=preset_scenario, group = run_number), span=0.1, se=FALSE) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Infected") + 
    labs(title="Infected numbers",
         subtitle="Total number of people Infected (smoothed)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_uncertainty <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean - std_mean, ymax = mean + std_mean,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Infected") + 
    labs(title="Infected numbers",
         subtitle="Total number of people infected (smoothed with uncertainty)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}