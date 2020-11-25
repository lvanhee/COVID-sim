#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoCompanyCapital <- function(df_economy, output_dir, one_plot) {
  
  name = "Company_capital_plot"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # CONTACTS PER GATHERING POINT PER APP USAGE SCENARIO ----------------------------
  
  #group_by(tick) %>% summarise(total = mean(count_people_with_not_is_young_and_is_in_poverty))
  
  # Add days converted from ticks
  #df_economy$day <- dmfConvertTicksToDay(df_economy$tick)  
  
  # df_people_captial <- df_economy %>% select(tick, run_number, preset_scenario,
  #                                      workers = workers_average_amount_of_capital,
  #                                      retired = retirees_average_amount_of_capital,
  #                                      students = students_average_amount_of_capital)
  
  df_essential_shop_captial <- df_economy %>% select(tick, run_number, preset_scenario,
                                              capital = essential_shop_amount_of_capital,
  )
  
  df_essential_shop_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                      mean_capital = mean(essential_shop_amount_of_capital)
                                                                                      ,std_mean_capital = sd(essential_shop_amount_of_capital)
  )
  
  df_non_essential_shop_captial <- df_economy %>% select(tick, run_number, preset_scenario,
                                              capital = non_essential_shop_amount_of_capital,
  )
  
  df_non_essential_shop_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                      mean_capital = mean(non_essential_shop_amount_of_capital)
                                                                                      ,std_mean_capital = sd(non_essential_shop_amount_of_capital)
  )
  
  # df_workplace_captial <- df_economy %>% select(tick, run_number, preset_scenario,
  #                                              students = students_average_amount_of_capital,
  # )
  # 
  # df_students_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
  #                                                                                      mean_capital = mean(students_average_amount_of_capital)
  #                                                                                      ,std_mean_capital = sd(students_average_amount_of_capital)
  # )
  
  #seg_people_calpital <- gather(df_mean_std, variable, measurement, mean_capital, std_mean_capital)
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_essential_shop_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_non_essential_shop_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  # write.csv(df_students_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  #seg_people_calpital <- gather(df_people_captial, variable, measurement, workers, retired)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_essential_shop_capital")
  print(plot_ggplot(df_essential_shop_mean_std, "essential shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_essential_shop_capital_smooth")
  print(plot_ggplot_smooth(df_essential_shop_mean_std, "essential shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_non_essential_shop_capital")
  print(plot_ggplot(df_non_essential_shop_mean_std, "non-essential shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_non_essential_shop_capital_smooth")
  print(plot_ggplot_smooth(df_non_essential_shop_mean_std, "non-essential shop"))
  dmfPdfClose()
  
  # dmfPdfOpen(output_dir, "eco_students_capital")
  # print(plot_ggplot(df_students_mean_std, "students"))
  # dmfPdfClose()
  # 
  # dmfPdfOpen(output_dir, "eco_students_capital_smooth")
  # print(plot_ggplot_smooth(df_students_mean_std, "students"))
  # dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot, type_of_people) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean_capital)) +
    geom_line(size=0.5,alpha=0.8,aes(color=preset_scenario, group = preset_scenario)) +
    #geom_errorbar(aes(ymin = mean_capital - std_mean_capital, ymax = mean_capital + std_mean_capital,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Capital") + 
    labs(title=paste("Average", type_of_people, "capital", sep = " "),
         subtitle=paste("Average capital of", type_of_people, sep = " "), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}


plot_ggplot_smooth <- function(data_to_plot, type_of_people) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean_capital)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    geom_ribbon(aes(ymin = mean_capital - std_mean_capital, ymax = mean_capital + std_mean_capital,
                    color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Capital") + 
    labs(title=paste("Average", type_of_people, "capital", sep = " "),
         subtitle=paste("Average capital of", type_of_people, "(smoothed)", sep = " "), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}
