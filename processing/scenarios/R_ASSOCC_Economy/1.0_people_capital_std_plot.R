#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoPeopleStdCapital <- function(df_economy, output_dir, one_plot) {
  
  name = "People_std_capital_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # CONTACTS PER GATHERING POINT PER APP USAGE SCENARIO ----------------------------
  
  #group_by(tick) %>% summarise(total = mean(count_people_with_not_is_young_and_is_in_poverty))
  
  # Add days converted from ticks
  #df_economy$day <- dmfConvertTicksToDay(df_economy$tick)  
  
  # df_people_captial <- df_economy %>% select(tick, run_number, preset_scenario,
  #                                      workers = workers_average_amount_of_goods,
  #                                      retired = retirees_average_amount_of_goods,
  #                                      students = students_average_amount_of_goods)
  
  df_workers_capital_std <- df_economy %>% select(tick, run_number, preset_scenario,
                                                   capitalstd = standard_deviation_my_amount_of_capital_of_workers,
  )
  
  df_workers_capital_std_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                             mean_capital_std = mean(standard_deviation_my_amount_of_capital_of_workers)
                                                                                             ,std_mean_capital_std = sd(standard_deviation_my_amount_of_capital_of_workers)
  )
  
  df_students_capital_std <- df_economy %>% select(tick, run_number, preset_scenario,
                                                       capital_std = standard_deviation_my_amount_of_capital_of_students,
  )
  
  df_students_capital_std_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                                 mean_capital_std = mean(standard_deviation_my_amount_of_capital_of_students)
                                                                                                 ,std_mean_capital_std = sd(standard_deviation_my_amount_of_capital_of_students)
  )
  
  df_retired_capital_std <- df_economy %>% select(tick, run_number, preset_scenario,
                                              capital_std = standard_deviation_my_amount_of_capital_of_retireds,
  )
  
  df_retired_capital_std_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                        mean_capital_std = mean(standard_deviation_my_amount_of_capital_of_retireds)
                                                                                        ,std_mean_capital_std = sd(standard_deviation_my_amount_of_capital_of_retireds)
  )
  
  #seg_people_calpital <- gather(df_mean_std, variable, measurement, mean_capital_std, std_mean_capital_std)
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_workers_capital_std_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_students_capital_std_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_retired_capital_std_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  #seg_people_calpital <- gather(df_people_captial, variable, measurement, workers, retired)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_essential_shop_capital_std")
  print(plot_ggplot(df_workers_capital_std_mean_std, "workers"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_essential_shop_capital_std_smooth")
  print(plot_ggplot_smooth(df_workers_capital_std_mean_std, "workers"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_non_essential_shop_capital_std")
  print(plot_ggplot(df_students_capital_std_mean_std, "students"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_non_essential_shop_capital_std_smooth")
  print(plot_ggplot_smooth(df_students_capital_std_mean_std, "students"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_workplace_capital_std")
  print(plot_ggplot(df_retired_capital_std_mean_std, "retired"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_workplace_smooth")
  print(plot_ggplot_smooth(df_retired_capital_std_mean_std, "retired"))
  dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot, type_of_people) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean_capital_std)) +
    geom_line(size=0.5,alpha=0.8,aes(color=preset_scenario, group = preset_scenario)) +
    #geom_errorbar(aes(ymin = mean_capital_std - std_mean_capital_std, ymax = mean_capital_std + std_mean_capital_std,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Standard deviation") + 
    labs(title=paste("Capital standard deviation of", type_of_people, "", sep = " "),
         subtitle=paste("Standard deviation of capital owned by ", type_of_people, sep = " "), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}


plot_ggplot_smooth <- function(data_to_plot, type_of_people) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean_capital_std)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean_capital_std - std_mean_capital_std, ymax = mean_capital_std + std_mean_capital_std,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Standard deviation") + 
    labs(title=paste("Capital standard deviation of", type_of_people, "", sep = " "),
         subtitle=paste("Standard deviation of capital owned by ", type_of_people, "(smoothed + uncertainty (std. dev.))", sep = " "), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}
