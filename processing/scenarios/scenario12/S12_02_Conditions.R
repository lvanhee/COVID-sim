#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12ConditionsExperimentName <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  
  name = "s12_conditions_strategy"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_data <- df_scenario12 %>% 
    group_by(tick, experiment_name, condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio) %>% 
    summarise(infected = mean(infected, na.rm = TRUE),
              newly_infected_this_tick = mean(newly_infected_this_tick, na.rm=TRUE),
              dead_people = mean(dead_people, na.rm = TRUE),
              taken_hospital_beds = mean(taken_hospital_beds, na.rm=TRUE),
              believe_infected = mean(believe_infected, na.rm = TRUE))
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_data, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  # Infected
  plots_data_infected <- gather(df_data, variable, measurement, infected)
  for (days in unique(df_data$minimum_days_between_phases)) {
    for (ack_rate in unique(df_data$acknowledgement_ratio)) {
      dmfPdfOpen(output_dir, paste("s12_strategy_infected_days", days, "ack_rate", ack_rate, sep="_"), one_plot = one_plot)
      print(plot_ggplot_tick(plots_data_infected[plots_data_infected$minimum_days_between_phases == days & plots_data_infected$acknowledgement_ratio == ack_rate,], 
                             plot_phases[plot_phases$minimum_days_between_phases == days & plot_phases$acknowledgement_ratio == ack_rate,],
                             experiment_name, "Exit strategy:",
                             paste("Agents infected depending on the exit strategy (min. days between phases: ", days, ", acknowledgment ratio:", ack_rate, ")", sep=''), 
                             "Number of infected"))
      dmfPdfClose(one_plot = one_plot)
    }
  }
  
  # Newly infected
  plots_data_newly_infected <- gather(df_data, variable, measurement, newly_infected_this_tick)
  for (days in unique(df_data$minimum_days_between_phases)) {
    for (ack_rate in unique(df_data$acknowledgement_ratio)) {
      dmfPdfOpen(output_dir, paste("s12_strategy_newly_infected_days", days, "ack_rate", ack_rate, sep="_"), one_plot = one_plot)
      print(plot_ggplot_tick(plots_data_newly_infected[plots_data_infected$minimum_days_between_phases == days & plots_data_infected$acknowledgement_ratio == ack_rate,], 
                             plot_phases[plot_phases$minimum_days_between_phases == days & plot_phases$acknowledgement_ratio == ack_rate,],
                             experiment_name, "Exit strategy:",
                             paste("Agents infected depending on the exit strategy (min. days between phases: ", days, ", acknowledgment ratio:", ack_rate, ")", sep=''), 
                             "Number of infected"))
      dmfPdfClose(one_plot = one_plot)
    }
  }  
  
  # Mortality
  plots_data_mortality <- gather(df_data, variable, measurement, dead_people)
  for (days in unique(df_data$minimum_days_between_phases)) {
    for (ack_rate in unique(df_data$acknowledgement_ratio)) {
      dmfPdfOpen(output_dir, paste("s12_strategy_mortality_days", days, "ack_rate", ack_rate, sep="_"), one_plot = one_plot)
      print(plot_ggplot_tick(plots_data_mortality[plots_data_mortality$minimum_days_between_phases == days & plots_data_mortality$acknowledgement_ratio == ack_rate,], 
                             plot_phases[plot_phases$minimum_days_between_phases == days & plot_phases$acknowledgement_ratio == ack_rate,],
                             experiment_name, "Exit strategy:",
                             paste("Agents deceased depending on the exit strategy (min. days between phases: ", days, ", acknowledgment ratio:", ack_rate, ")", sep=''), "Number of deaths"))
      dmfPdfClose(one_plot = one_plot)
    }
  }
  
  # Hospitalization
  plots_data_hospitalization <- gather(df_data, variable, measurement, taken_hospital_beds)
  for (days in unique(df_data$minimum_days_between_phases)) {
    for (ack_rate in unique(df_data$acknowledgement_ratio)) {
      dmfPdfOpen(output_dir, paste("s12_strategy_hospitalization_days", days, "ack_rate", ack_rate, sep="_"), one_plot = one_plot)
      print(plot_ggplot_tick(plots_data_hospitalization[plots_data_hospitalization$minimum_days_between_phases == days & plots_data_hospitalization$acknowledgement_ratio == ack_rate,], 
                             plot_phases[plot_phases$minimum_days_between_phases == days & plot_phases$acknowledgement_ratio == ack_rate,],
                             experiment_name, "Exit strategy:",
                             paste("Agents in hosptial depending on the exit strategy (min. days between phases: ", days, ", acknowledgment ratio:", ack_rate, ")", sep=''), "Number of hospitalizations"))
      dmfPdfClose(one_plot = one_plot)
    }
  }
}


plotS12ConditionsMinimumDays <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  
  name = "s12_conditions_min_days"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_data <- df_scenario12 %>% 
    group_by(tick, condition_phasing_out, minimum_days_between_phases) %>% 
    summarise(infected = mean(infected, na.rm = TRUE),
              newly_infected_this_tick = mean(newly_infected_this_tick, na.rm=TRUE),
              dead_people = mean(dead_people, na.rm = TRUE),
              taken_hospital_beds = mean(taken_hospital_beds, na.rm=TRUE),
              believe_infected = mean(believe_infected, na.rm = TRUE))
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_data, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  # Infected
  plots_data_infected <- gather(df_data, variable, measurement, infected)
  dmfPdfOpen(output_dir, paste("s12_min_days_infected", sep="_"), p_height=9, one_plot = one_plot)
  print(plot_ggplot_tick(plots_data_infected, plot_phases, minimum_days_between_phases, "Min. days between phases:",
                         "Agents infected depending on the exit strategy", "Number of infected"))
  dmfPdfClose(one_plot = one_plot)
  
  # Infected
  plots_data_infected <- gather(df_data, variable, measurement, newly_infected_this_tick)
  dmfPdfOpen(output_dir, paste("s12_min_days_newly_infected", sep="_"), p_height=9, one_plot = one_plot)
  print(plot_ggplot_tick(plots_data_infected, plot_phases, minimum_days_between_phases, "Min. days between phases:",
                         "Agents infected depending on the exit strategy", "Number of infected"))
  dmfPdfClose(one_plot = one_plot)  
  
  # Mortality
  plots_data_mortality <- gather(df_data, variable, measurement, dead_people)
  dmfPdfOpen(output_dir, paste("s12_min_days_mortality",sep="_"), p_height=9, one_plot = one_plot)
  print(plot_ggplot_tick(plots_data_mortality, plot_phases, minimum_days_between_phases, "Min. days between phases:",
                         "Agents deceased depending on the exit strategy", "Number of deaths"))
  dmfPdfClose(one_plot = one_plot)
  
  # Hospitalization
  plots_data_hospitalization <- gather(df_data, variable, measurement, taken_hospital_beds)
  dmfPdfOpen(output_dir, paste("s12_min_days_hospitalization", sep="_"), p_height=9, one_plot = one_plot)
  print(plot_ggplot_tick(plots_data_hospitalization, plot_phases, minimum_days_between_phases, "Min. days between phases:",
                         "Agents in hosptial depending on the exit strategy", "Number of hospitalizations"))
  dmfPdfClose(one_plot = one_plot)
}

plotS12ConditionsAckRate <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  
  name = "s12_conditions_ack_rate"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_data <- df_scenario12 %>% 
    group_by(tick, condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio) %>% 
    summarise(infected = mean(infected, na.rm = TRUE),
              dead_people = mean(dead_people, na.rm = TRUE),
              taken_hospital_beds = mean(taken_hospital_beds, na.rm=TRUE),
              believe_infected = mean(believe_infected, na.rm = TRUE))
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_data, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  # Infected
  plots_data_infected <- gather(df_data, variable, measurement, infected)
  for (days in unique(df_data$minimum_days_between_phases)) {
    dmfPdfOpen(output_dir, paste("s12_ack_rate_infected_days", days, sep="_"), p_height=9, one_plot = one_plot)
    print(plot_ggplot_tick(plots_data_infected[plots_data_infected$minimum_days_between_phases == days,], 
                           plot_phases[plot_phases$minimum_days_between_phases == days,],
                           acknowledgement_ratio,"Acknowledgement ratio:",
                           paste("Agents infected depending on the exit strategy (min. days between phases: ", days, ")", sep=''), "Number of infected"))
    dmfPdfClose(one_plot = one_plot)
  }
  
  # Mortality
  plots_data_mortality <- gather(df_data, variable, measurement, dead_people)
  for (days in unique(df_data$minimum_days_between_phases)) {
    dmfPdfOpen(output_dir, paste("s12_ack_rate_mortality_days", days, sep="_"), p_height=9, one_plot = one_plot)
    print(plot_ggplot_tick(plots_data_mortality[plots_data_mortality$minimum_days_between_phases == days,], 
                           plot_phases[plot_phases$minimum_days_between_phases == days,],
                           acknowledgement_ratio,"Acknowledgement ratio:",
                           paste("Agents deceased depending on the exit strategy (min. days between phases: ", days, ")", sep=''), "Number of deaths"))
    dmfPdfClose(one_plot = one_plot)
  }
  
  # Hospitalization
  plots_data_hospitalization <- gather(df_data, variable, measurement, taken_hospital_beds)
  for (days in unique(df_data$minimum_days_between_phases)) {
    dmfPdfOpen(output_dir, paste("s12_ack_rate_hospitalization_days", days, sep="_"), p_height=9, one_plot = one_plot)
    print(plot_ggplot_tick(plots_data_hospitalization[plots_data_hospitalization$minimum_days_between_phases == days,], 
                           plot_phases[plot_phases$minimum_days_between_phases == days,],
                           acknowledgement_ratio, "Acknowledgement ratio:",
                           paste("Agents in hosptial depending on the exit strategy (min. days between phases: ", days, ")", sep=''), "Number of hospitalizations"))
    dmfPdfClose(one_plot = one_plot)
  }
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot_tick <- function(data_to_plot, phase_lengths_to_plot, ctrl_var, legend_name, p_title = "None", p_y_lab = "None") {
  ctrl_var <- enquo(ctrl_var)
  
  (data_to_plot %>%
    ggplot(aes(x = tick / 4, 
               y = measurement)) +
    geom_line(aes(col=as.factor(!!ctrl_var))) +
    scale_colour_brewer(palette = "Set1", name=legend_name) +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Days", y=p_y_lab) +
      geom_vline(aes(xintercept=start/4, colour=factor(!!ctrl_var), linetype=factor(phase)), phase_lengths_to_plot) + 
      scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
      # geom_text(aes(x=start, y=y, label=phase, colour=factor(!!ctrl_var)), data=phase_texts) + 
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme + 
    theme(legend.position = "bottom")) %>%
    tag_facet()
}


plot_ggplot_tick_smooth <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = measurement)) +
    stat_smooth(aes(col=as.factor(ratio_of_app_users)), method = "loess", formula = y ~ x, se = FALSE, span=0.1) +
    scale_colour_brewer(palette = "Spectral", name="Exit strategy") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Ticks", y=p_y_lab) +
    facet_wrap(vars(condition_phasing_out)) +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_day <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_line(aes(col=as.factor(ratio_of_app_users))) +
    scale_colour_brewer(palette = "Spectral", name="Exit strategy") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Days", y=p_y_lab) +
    facet_wrap(vars(condition_phasing_out)) +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_day_smooth <- function(data_to_plot, p_title = "None", p_y_lab = "None") {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_smooth(aes(col=as.factor(ratio_of_app_users)), span=0.1, se=FALSE) +
    scale_colour_brewer(palette = "Spectral", name="Exit strategy") +
    labs(title=p_title,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         x="Days", y=p_y_lab) +
    facet_wrap(vars(condition_phasing_out)) +
    gl_plot_guides + gl_plot_theme
}