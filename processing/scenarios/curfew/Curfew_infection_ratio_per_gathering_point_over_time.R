#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewInfectionRatioGP <- function(df_scenario6, output_dir, one_plot) {
  
  name = "curfew_infection_ratio_gp"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_people_infected_gp <- df_scenario6 %>% 
    group_by(tick, curfew_type) %>% 
    summarise(essential_shops = mean(people_infected_in_essential_shops, na.rm = TRUE),
              homes = mean(people_infected_in_homes, na.rm = TRUE),
              hospitals = mean(people_infected_in_hospitals, na.rm = TRUE),
              non_essential_shops = mean(people_infected_in_non_essential_shops, na.rm = TRUE),
              private_leisure = mean(people_infected_in_private_leisure, na.rm = TRUE),
              public_leisure = mean(people_infected_in_public_leisure, na.rm = TRUE),
              pubtrans = mean(people_infected_in_pubtrans, na.rm = TRUE),
              queuing = mean(people_infected_in_queuing, na.rm = TRUE),
              schools = mean(people_infected_in_schools, na.rm = TRUE),
              shared_cars = mean(people_infected_in_shared_cars, na.rm = TRUE),
              universities = mean(people_infected_in_universities, na.rm = TRUE),
              workplaces = mean(people_infected_in_workplaces, na.rm = TRUE))
  colnames(df_people_infected_gp)
  
  df_people_infected_gp$day <- dmfConvertTicksToDay(df_people_infected_gp$tick)
  
  # Sum for every day (combine the four ticks)
  df_people_infected_gp_day <- df_people_infected_gp %>% 
    group_by(day, curfew_type) %>% 
    summarise(essential_shops = mean(essential_shops, na.rm = TRUE),
              homes = mean(homes, na.rm = TRUE),
              hospitals = mean(hospitals, na.rm = TRUE),
              non_essential_shops = mean(non_essential_shops, na.rm = TRUE),
              private_leisure = mean(private_leisure, na.rm = TRUE),
              public_leisure = mean(public_leisure, na.rm = TRUE),
              pubtrans = mean(pubtrans, na.rm = TRUE),
              queuing = mean(queuing, na.rm = TRUE),
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
  
  for(i in unique(df_people_infected_gp$curfew_type)) {
    dmfPdfOpen(output_dir, paste("curfew_people_infected_gp_day_app_", i, sep=""))
    print(plot_ggplot(seg_people_infected_gp_day[seg_people_infected_gp_day$curfew_type==i, ], i))
    dmfPdfClose()
  }  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, app_use) {
  
  data_to_plot %>%
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
    labs(title=paste("Cummulative agents infected per gathering point - app usage ratio:", app_use),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}
