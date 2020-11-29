#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoSystemGoodsProd <- function(df_economy, output_dir, one_plot) {
  
  name = "Goods_produced_in_system_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_goods_produced_in_system <- df_economy %>% select(tick, run_number, preset_scenario, goods_produced = goods_production_of_total_system)
  
  df_goods_produced_in_system_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>%
    summarise(tick, preset_scenario,
              mean = mean(goods_production_of_total_system)
              ,std = sd(goods_production_of_total_system)
    )
  
  # Add days converted from ticks
  df_goods_produced_day <- df_goods_produced_in_system
  df_goods_produced_day$day <- dmfConvertTicksToDay(df_goods_produced_day$tick)
  df_goods_produced_day <- df_goods_produced_day %>% group_by(day, run_number) %>% summarise(day, run_number, preset_scenario, mean = mean(goods_produced)) %>% unique()
  
  # and for averages of scenario
  df_goods_produced_mean_std_day <- df_goods_produced_in_system_mean_std
  df_goods_produced_mean_std_day$day <- dmfConvertTicksToDay(df_goods_produced_mean_std_day$tick)
  df_goods_produced_mean_std_day <- df_goods_produced_mean_std_day %>% group_by(day, preset_scenario) %>% summarise(
    day, preset_scenario,
    mean = mean(mean),
    std = mean(std))
  
  # And now for weeks.
  #  For this to go properly do remember that you need to have full weeks of ticks.
  #  We do not correct for broken weeks. 
  df_goods_produced_week <- df_goods_produced_day
  df_goods_produced_week$week <- dmfConvertDaysToWeek(df_goods_produced_week$day)
  df_goods_produced_week <- df_goods_produced_week %>% group_by(week, run_number) %>% summarise(week, run_number, preset_scenario, mean = mean(mean)) %>% unique()
  
  # and for averages of scenario
  df_goods_produced_mean_std_week <- df_goods_produced_mean_std_day
  df_goods_produced_mean_std_week$week <- dmfConvertDaysToWeek(df_goods_produced_mean_std_week$day)
  df_goods_produced_mean_std_week <- df_goods_produced_mean_std_week %>% group_by(week, preset_scenario) %>% summarise(
    week, preset_scenario,
    mean = mean(mean),
    std = mean(std))
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_goods_produced_in_system, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_goods_produced_in_system_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_goods_produced_in_system <- gather(df_goods_produced_in_system, variable, measurement, goods_produced)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system")
  print(plot_ggplot(seg_goods_produced_in_system, "tick"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_smooth_uncertainty")
  print(plot_ggplot_smooth_uncertainty(df_goods_produced_in_system_mean_std, "tick"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_smooth")
  print(plot_ggplot_smooth(df_goods_produced_in_system_mean_std, "tick"))
  dmfPdfClose()
  
  
  #days
  seg_goods_produced_day <- gather(df_goods_produced_day, variable, measurement, mean)
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_day")
  print(plot_ggplot(seg_goods_produced_day, "day"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_smooth_uncertainty_day")
  print(plot_ggplot_smooth_uncertainty(df_goods_produced_mean_std_day, "day"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_smooth_day")
  print(plot_ggplot_smooth(df_goods_produced_mean_std_day, "day"))
  dmfPdfClose()
  
  #weeks
  seg_goods_produced_week <- gather(df_goods_produced_week, variable, measurement, mean)
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_week")
  print(plot_ggplot(seg_goods_produced_week, "week"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_smooth_uncertainty_week")
  print(plot_ggplot_smooth_uncertainty(df_goods_produced_mean_std_week, "week"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_goods_produced_in_system_smooth_week")
  print(plot_ggplot_smooth(df_goods_produced_mean_std_week, "week"))
  dmfPdfClose()

}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot, timeframe) {
  
  timeframe <- sym(timeframe)
  
  data_to_plot %>%
    ggplot(aes(x = !!timeframe, 
               y = measurement)) +
    #geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_line(size=1,alpha=0.8,aes(color=preset_scenario, group = run_number)) +
    #geom_errorbar(aes(ymin = mean_goods_produced - std_mean_goods_produced, ymax = mean_goods_produced + std_mean_goods_produced,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab(paste(timeframe, "s", sep = "")) +
    ylab("Goods produced") + 
    labs(title="Goods produced in the system",
         subtitle="Goods produced in the total system", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth <- function(data_to_plot, timeframe) {
  
  timeframe <- sym(timeframe)
  
  data_to_plot %>%
    ggplot(aes(x = !!timeframe, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab(paste(timeframe, "s", sep = "")) +
    ylab("Goods produced") + 
    labs(title="Goods produced in the system",
         subtitle="Goods produced in the total system (smoothed)", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth_uncertainty <- function(data_to_plot, timeframe) {
  
  timeframe <- sym(timeframe)
  
  data_to_plot %>%
    ggplot(aes(x = !!timeframe, 
               y = mean)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean - std, ymax = mean + std,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab(paste(timeframe, "s", sep = "")) +
    ylab("Goods produced") + 
    labs(title="Goods produced in the system",
         subtitle="Goods produced in the total system (smoothed + uncertainty (std. dev.))))", 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}