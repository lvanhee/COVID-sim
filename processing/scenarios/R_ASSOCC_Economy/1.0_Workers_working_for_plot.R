#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotEcoPeopleWokringFor <- function(df_economy, output_dir, one_plot) {
  
  name = "People_working_for_plot"
  
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
  
  df_workers_working_for_essential_shop <- df_economy %>% select(tick, run_number, preset_scenario,
                                                  working_for = workers_working_at_essential_shop,
  )
  
  df_workers_working_for_essential_shop_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                                  mean_working_for = mean(workers_working_at_essential_shop)
                                                                                                  ,std_mean_working_for = sd(workers_working_at_essential_shop)
  )
  
  df_workers_working_for_non_essential_shop <- df_economy %>% select(tick, run_number, preset_scenario,
                                                   working_for = workers_working_at_non_essential_shop,
  )
  
  df_workers_working_for_non_essential_shop_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                                   mean_working_for = mean(workers_working_at_non_essential_shop)
                                                                                                   ,std_mean_working_for = sd(workers_working_at_non_essential_shop)
  )
  
  df_workers_working_for_workplace <- df_economy %>% select(tick, run_number, preset_scenario,
                                                  working_for = workers_working_at_workplace,
  )
  
  df_workers_working_for_workplace_mean_std <- df_economy %>% group_by(tick, preset_scenario) %>% summarise(tick, preset_scenario,
                                                                                                  mean_working_for = mean(workers_working_at_workplace)
                                                                                                  ,std_mean_working_for = sd(workers_working_at_workplace)
  )
  
  #seg_people_calpital <- gather(df_mean_std, variable, measurement, mean_working_for, std_mean_working_for)
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_workers_working_for_essential_shop_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_workers_working_for_non_essential_shop_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  write.csv(df_workers_working_for_workplace_mean_std, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  #seg_people_calpital <- gather(df_people_captial, variable, measurement, workers, retired)
  
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "eco_essential_shop_working_for")
  print(plot_ggplot(df_workers_working_for_essential_shop_mean_std, "essential shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_essential_shop_working_for_smooth")
  print(plot_ggplot_smooth(df_workers_working_for_essential_shop_mean_std, "essential shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_non_essential_shop_working_for")
  print(plot_ggplot(df_workers_working_for_non_essential_shop_mean_std, "non-essential shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_non_essential_shop_working_for_smooth")
  print(plot_ggplot_smooth(df_workers_working_for_non_essential_shop_mean_std, "non essential-shop"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_workplace_working_for")
  print(plot_ggplot(df_workers_working_for_workplace_mean_std, "workplace"))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "eco_workplace_smooth")
  print(plot_ggplot_smooth(df_workers_working_for_workplace_mean_std, "workplace"))
  dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================


plot_ggplot <- function(data_to_plot, type_of_people) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean_working_for)) +
    geom_line(size=0.5,alpha=0.8,aes(color=preset_scenario, group = preset_scenario)) +
    #geom_errorbar(aes(ymin = mean_working_for - std_mean_working_for, ymax = mean_working_for + std_mean_working_for,
    #                  color=preset_scenario, group = preset_scenario)) +
    #continues_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Workers") + 
    labs(title=paste("Workers working for", type_of_people, "", sep = " "),
         subtitle=paste("Workers working for", type_of_people, sep = " "), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}


plot_ggplot_smooth <- function(data_to_plot, type_of_people) {
  
  data_to_plot %>%
    ggplot(aes(x = tick, 
               y = mean_working_for)) +
    geom_smooth(aes(col=preset_scenario), span=0.1, se=FALSE) +
    #geom_ribbon(aes(ymin = mean_working_for - std_mean_working_for, ymax = mean_working_for + std_mean_working_for,
    #                color= preset_scenario), alpha=0.1) +
    #scale_colour_brewer(palette = "Spectral", name="Infected") +
    xlab("Ticks") +
    ylab("Workers") + 
    labs(title=paste("Workers working for", type_of_people, "", sep = " "),
         subtitle=paste("Workers working for", type_of_people, "(smoothed)", sep = " "), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}
