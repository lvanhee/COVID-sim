#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoVelocity <- function(df_economy, output_dir, one_plot) {
  
  name = "Velocity_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))

  
  df_velocity <- df_economy %>% select(tick, run_number, preset_scenario, velocity = velocity_of_money_in_total_system)
  
  #means and std over the runs
  df_velocity_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>%
      summarise(tick, preset_scenario,
       mean = mean(velocity_of_money_in_total_system)
       ,std = sd(velocity_of_money_in_total_system)
  )
  
  # Add days converted from ticks
  df_velocity_day <- df_velocity
  df_velocity_day$day <- dmfConvertTicksToDay(df_velocity_day$tick)
  df_velocity_day <- df_velocity_day %>% group_by(day, run_number) %>% summarise(day, run_number, preset_scenario, mean = mean(velocity)) %>% unique()
  
  # and for averages of scenario
  df_velocity_mean_std_day <- df_velocity_mean_std
  df_velocity_mean_std_day$day <- dmfConvertTicksToDay(df_velocity_mean_std_day$tick)
  df_velocity_mean_std_day <- df_velocity_mean_std_day %>% group_by(day, preset_scenario) %>% summarise(
    day, preset_scenario,
    mean = mean(mean),
    std = mean(std))
  
  # And now for weeks.
  #  For this to go properly do remember that you need to have full weeks of ticks.
  #  We do not correct for broken weeks. 
  df_velocity_week <- df_velocity_day
  df_velocity_week$week <- dmfConvertDaysToWeek(df_velocity_week$day)
  df_velocity_week <- df_velocity_week %>% group_by(week, run_number) %>% summarise(week, run_number, preset_scenario, mean = mean(mean)) %>% unique()
  
  # and for averages of scenario
  df_velocity_mean_std_week <- df_velocity_mean_std_day
  df_velocity_mean_std_week$week <- dmfConvertDaysToWeek(df_velocity_mean_std_week$day)
  df_velocity_mean_std_week <- df_velocity_mean_std_week %>% group_by(week, preset_scenario) %>% summarise(
    week, preset_scenario,
    mean = mean(mean),
    std = mean(std))
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_velocity, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_velocity_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_velocity <- gather(df_velocity, variable, measurement, velocity)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_velocity")
  print(plot_ggplot(seg_velocity))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_velocity_smooth_uncertainty")
  print(plot_ggplot_smooth_uncertainty(df_velocity_mean_std))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_velocity_smooth")
  print(plot_ggplot_smooth(df_velocity_mean_std))
  dmfPdfClose()
  
  #days
  seg_velocity_day <- gather(df_velocity_day, variable, measurement, mean)
  
  dmfPdfOpen(output_dir, "eco_velocity_day")
  print(plot_ggplot_day(seg_velocity_day))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_velocity_day_smooth_uncertainty")
  print(plot_ggplot_smooth_uncertainty_day(df_velocity_mean_std_day))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_velocity_day_smooth")
  print(plot_ggplot_smooth_day(df_velocity_mean_std_day))
  dmfPdfClose()
  
  #weeks.
  seg_velocity_week <- gather(df_velocity_week, variable, measurement, mean)
  
  dmfPdfOpen(output_dir, "eco_velocity_week")
  print(plot_ggplot_week(seg_velocity_week))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_velocity_week_smooth_uncertainty")
  print(plot_ggplot_smooth_uncertainty_week(df_velocity_mean_std_week))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_velocity_week_smooth")
  print(plot_ggplot_smooth_week(df_velocity_mean_std_week))
  dmfPdfClose()
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
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system", 
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
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system (smoothed)", 
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
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system (smoothed + uncertainty (std. dev.))", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

###-------- Day graphs

#
#  NOTE: we have made a more generic function in goods production, TODO to use it here as well.
#


plot_ggplot_day <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    #geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_line(size=1,alpha=0.8,aes(color=preset_scenario, group = run_number)) +
    #geom_errorbar(aes(ymin = mean_capital - std_mean_capital, ymax = mean_capital + std_mean_capital,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Days") +
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_uncertainty_day <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean - std, ymax = mean + std,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Days") +
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system (smoothed + uncertainty (std. dev.))", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_day <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Days") +
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system (smoothed)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

###-------- Week graphs


plot_ggplot_week <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = week, 
               y = measurement)) +
    #geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_line(size=1,alpha=0.8,aes(color=preset_scenario, group = run_number)) +
    #geom_errorbar(aes(ymin = mean_capital - std_mean_capital, ymax = mean_capital + std_mean_capital,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Weeks") +
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_uncertainty_week <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = week, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean - std, ymax = mean + std,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Weeks") +
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system (smoothed + uncertainty (std. dev.))", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_week <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = week, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Weeks") +
    ylab("Velocity") + 
    labs(title="Velocity of money",
         subtitle="Velocity of money in the total system (smoothed)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

