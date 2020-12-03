#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoSystemCapital <- function(df_economy, output_dir, one_plot) {
  
  name = "Capital_in_system_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # CONTACTS PER GATHERING POINT PER APP USAGE SCENARIO ----------------------------
  
  df_capital_in_system <- df_economy %>% select(tick, run_number, preset_scenario, total_capital = total_amount_of_capital_in_the_system)
  
  df_capital_in_system_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>%
    summarise(tick, preset_scenario,
              mean = mean(total_amount_of_capital_in_the_system)
              ,std = sd(total_amount_of_capital_in_the_system)
    )
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_capital_in_system, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_capital_in_system_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_capital_in_system <- gather(df_capital_in_system, variable, measurement, total_capital)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_capital_in_system")
  print(plot_ggplot(seg_capital_in_system))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_capital_in_system_smooth_uncertainty")
  print(plot_ggplot_smooth_uncertainty(df_capital_in_system_mean_std))
  dmfPdfClose()
  
  # dmfPdfOpen(output_dir, "eco_capital_in_system_smooth")
  # print(plot_ggplot_smooth(df_capital_in_system_mean_std))
  # dmfPdfClose()
  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = measurement)) +
    #geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_line(size=1,alpha=0.8,aes(color=preset_scenario, group = run_number)) +
    #geom_errorbar(aes(ymin = mean_capital - std_mean_capital, ymax = mean_capital + std_mean_capital,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Capital") + 
    labs(title="Capital in the system",
         subtitle="Capital in the total system", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Capital") + 
    labs(title="Capital in the system",
         subtitle="Capital in the total system (smoothed)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_uncertainty <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean - std, ymax = mean + std,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Capital") + 
    labs(title="Capital in the system",
         subtitle="Capital in the total system (smoothed + uncertainty (std. dev.)))", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}