#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewInfectedComplianceTests <- function(df_scenario6, output_dir, one_plot) {
  
  name = "curfew_infected_compliance_tests"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_data <- df_scenario6 %>% 
    group_by(tick, curfew_type) %>% 
    summarise(infected = mean(infected, na.rm = TRUE),
              believe_infected = mean(believe_infected, na.rm = TRUE),
              tests_performed = mean(tests_performed, na.rm = TRUE),
              ratio_quarantiners_complying = mean(ratio_quarantiners_currently_complying_to_quarantine, na.rm = TRUE))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_data, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  # Infected
  plots_data_infected <- gather(df_data, variable, measurement, infected)
  dmfPdfOpen(output_dir, "curfew_infected")
  print(plot_ggplot_tick(plots_data_infected, "Agents infected depending on the app usage ratio", "Number of infected"))
  dmfPdfClose()
  
  # Epistemic infected
  plots_data_epistemic_infected <- gather(df_data, variable, measurement, believe_infected)
  dmfPdfOpen(output_dir, "curfew_infected_epistemic")
  print(plot_ggplot_tick(plots_data_epistemic_infected, "Agents believing being infected depending on the app usage ratio",
                         "Number of agents believing they are infected"))
  dmfPdfClose()
  
  # Ratio quarantine 
  plots_data_ratio_quarantine <- gather(df_data, variable, measurement, ratio_quarantiners_complying)
  dmfPdfOpen(output_dir, "curfew_quarantiners_complying")
  print(plot_ggplot_tick(plots_data_ratio_quarantine, "Ratio agents in quarantine depending on the app usage ratio",
                         "Ratio of people complying to quarantine"))
  dmfPdfClose()
  
  # Ratio quarantine smoothed
  dmfPdfOpen(output_dir, "curfew_quarantiners_complying_smooth")
  print(plot_ggplot_tick_smooth(plots_data_ratio_quarantine, "Ratio agents in quarantine depending on the app usage ratio (Smoothed)",
                                "Ratio of people complying to quarantine"))
  dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot_tick <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = measurement)) +
    geom_line(aes(col=as.factor(curfew_type))) +
    scale_colour_brewer(palette = "Spectral", name="Curfew Type") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Ticks", y=p_y_lab) +
    gl_plot_guides + gl_plot_theme +
    theme(legend.position = "bottom", legend.direction = "vertical")
}


plot_ggplot_tick_smooth <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = measurement)) +
    stat_smooth(aes(col=as.factor(curfew_type)), method = "loess", formula = y ~ x, se = FALSE, span=0.1) +
    scale_colour_brewer(palette = "Spectral", name="Curfew Type") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Ticks", y=p_y_lab) +
    gl_plot_guides + gl_plot_theme +
    theme(legend.position = "bottom", legend.direction = "vertical")
}

plot_ggplot_day <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_line(aes(col=as.factor(curfew_type))) +
    scale_colour_brewer(palette = "Spectral", name="Curfew Type") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Days", y=p_y_lab) +
    gl_plot_guides + gl_plot_theme +
    theme(legend.position = "bottom", legend.direction = "vertical")
}

plot_ggplot_day_smooth <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_smooth(aes(col=as.factor(curfew_type)), span=0.1, se=FALSE) +
    scale_colour_brewer(palette = "Spectral", name="Curfew Type") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Days", y=p_y_lab) +
    gl_plot_guides + gl_plot_theme +
    theme(legend.position = "bottom", legend.direction = "vertical")
}
