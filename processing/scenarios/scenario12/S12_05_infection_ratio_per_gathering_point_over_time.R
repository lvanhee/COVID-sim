#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12InfectionRatioGP <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  
  name = "s12_infection_ratio_gp"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_people_infected_gp <- df_scenario12 %>% 
    group_by(tick, experiment_name, condition_phasing_out) %>% 
    summarise(essential_shops = mean(people_infected_in_essential_shops, na.rm = TRUE),
              homes = mean(people_infected_in_homes, na.rm = TRUE),
              hospitals = mean(people_infected_in_hospitals, na.rm = TRUE),
              non_essential_shops = mean(people_infected_in_non_essential_shops, na.rm = TRUE),
              private_leisure = mean(people_infected_in_private_leisure, na.rm = TRUE),
              public_leisure = mean(people_infected_in_public_leisure, na.rm = TRUE),
              pubtrans = mean(people_infected_in_pubtrans, na.rm = TRUE),
              queuing = mean(people_infected_in_queuing, na.rm = TRUE),
              away = mean(people_infected_in_away_travel, na.rm = TRUE),
              schools = mean(people_infected_in_schools, na.rm = TRUE),
              shared_cars = mean(people_infected_in_shared_cars, na.rm = TRUE),
              universities = mean(people_infected_in_universities, na.rm = TRUE),
              workplaces = mean(people_infected_in_workplaces, na.rm = TRUE))
  colnames(df_people_infected_gp)
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  df_people_infected_gp$day <- dmfConvertTicksToDay(df_people_infected_gp$tick)
  
  # Sum for every day (combine the four ticks)
  df_people_infected_gp_day <- df_people_infected_gp %>% 
    group_by(day, experiment_name, condition_phasing_out) %>% 
    summarise(essential_shops = mean(essential_shops, na.rm = TRUE),
              homes = mean(homes, na.rm = TRUE),
              hospitals = mean(hospitals, na.rm = TRUE),
              non_essential_shops = mean(non_essential_shops, na.rm = TRUE),
              private_leisure = mean(private_leisure, na.rm = TRUE),
              public_leisure = mean(public_leisure, na.rm = TRUE),
              pubtrans = mean(pubtrans, na.rm = TRUE),
              queuing = mean(queuing, na.rm = TRUE),
              away = mean(away, na.rm = TRUE),
              schools = mean(schools, na.rm = TRUE),
              shared_cars = mean(shared_cars, na.rm = TRUE),
              universities = mean(universities, na.rm = TRUE),
              workplaces = mean(workplaces, na.rm = TRUE))

  print(paste(name, " writing CSV", sep=""))
  write.csv(df_people_infected_gp_day, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_people_infected_gp_day <- gather(df_people_infected_gp_day, People_infected_in, measurement, essential_shops:workplaces)
  
  print(paste(name, " making plots", sep=""))
  
  for(i in unique(seg_people_infected_gp_day$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_people_infected_gp_day_strat_", i, sep=""))
    print(plot_ggplot(seg_people_infected_gp_day[seg_people_infected_gp_day$experiment_name==i, ], filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  }  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, phase_lengths_to_plot, strat) {
  
  (data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement,
               group = People_infected_in,
               fill = People_infected_in), fill=NA) +
    geom_line(aes(col=People_infected_in)) +
    guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
    scale_colour_manual(name = "Locations", values = c(
      "away" = "#000000", # black
      "essential_shops" = "#CC0000", # darker red
      "non_essential_shops" = "#FF0000", #red
      "homes" = "#3366FF", #blue
      "hospitals" = "#66CCFF", # lighter blue
      "private_leisure" = "#006600",# Green
      "public_leisure" = "#00FF00", # darker green
      "pubtrans" = "#FF9933", #orange 
      "queuing" = "#CC9900", #yellow
      "shared_cars" = "#CC6600", #other orange
      "schools" = "#660099", #purple
      "universities" = "#9900FF", # lighter purple
      "workplaces" = "#FF00FF" #magenta
    )) +
    xlab("Days") +
    ylab("Cumulative agents infected") +
    labs(title=paste("Cummulative agents infected per type of location - exit strategy:", strat),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme)%>% tag_facet()
}