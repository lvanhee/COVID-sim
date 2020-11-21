#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoLockdown <- function(df_economy, output_dir, one_plot) {
  
  name = "Lockdown_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # CONTACTS PER GATHERING POINT PER APP USAGE SCENARIO ----------------------------
  
  df_lockdown <- df_economy %>% group_by(tick, preset_scenario) %>% 
      summarise(tick, preset_scenario, lockdown = mean(ifelse_value_is_lockdown_active_1_0))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_lockdown, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_lockdown")
  print(plot_ggplot(df_lockdown))
  dmfPdfClose()

}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = lockdown)) +
    #geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_line(size=1,alpha=0.8,aes(color=preset_scenario, group = preset_scenario)) +
    #geom_errorbar(aes(ymin = mean_capital - std_mean_capital, ymax = mean_capital + std_mean_capital,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Lockowns") + 
    labs(title="Lockdown status",
         subtitle="% of runs that are in lockdown in time", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

