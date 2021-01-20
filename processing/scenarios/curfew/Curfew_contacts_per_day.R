#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewContactsPerDay <- function(df_scenario6, output_dir, one_plot) {

  name = "curfew_contacts_per_day"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  # CONTACTS PER GATHERING POINT PER APP USAGE SCENARIO ----------------------------
  df_contacts_gp <- df_scenario6 %>% 
    group_by(tick, curfew_type) %>% 
    summarise(contacts_in_essential_shops = mean(contacts_in_essential_shops, na.rm = TRUE),
              contacts_in_homes = mean(contacts_in_homes, na.rm = TRUE),
              contacts_in_hospitals = mean(contacts_in_hospitals, na.rm = TRUE),
              contacts_in_non_essential_shops = mean(contacts_in_non_essential_shops, na.rm = TRUE),
              contacts_in_private_leisure = mean(contacts_in_private_leisure, na.rm = TRUE),
              contacts_in_public_leisure = mean(contacts_in_public_leisure, na.rm = TRUE),
              contacts_in_pubtrans = mean(contacts_in_pubtrans, na.rm = TRUE),
              contacts_in_queuing = mean(contacts_in_queuing, na.rm = TRUE),
              contacts_in_schools = mean(contacts_in_schools, na.rm = TRUE),
              contacts_in_shared_cars = mean(contacts_in_shared_cars, na.rm = TRUE),
              contacts_in_universities = mean(contacts_in_universities, na.rm = TRUE),
              contacts_in_workplaces = mean(contacts_in_workplaces, na.rm = TRUE),
              dead_people = mean(dead_people, na.rm = TRUE))
  colnames(df_contacts_gp)

  # Count total people then add column for dead people
  total_people = dmfGetTotalAmountOfPeople(df_scenario6)
  df_contacts_gp$total_people = total_people - df_contacts_gp$dead_people

  # Add days converted from ticks
  df_contacts_gp$day <- dmfConvertTicksToDay(df_contacts_gp$tick)  

  # Calculate contacts per day per gathering point
  df_contacts_gp_by_day <- df_contacts_gp %>% 
    group_by(day, curfew_type) %>% 
    summarise(contacts_in_essential_shops = sum(contacts_in_essential_shops, na.rm = TRUE),
              contacts_in_homes = sum(contacts_in_homes, na.rm = TRUE),
              contacts_in_hospitals = sum(contacts_in_hospitals, na.rm = TRUE),
              contacts_in_non_essential_shops = sum(contacts_in_non_essential_shops, na.rm = TRUE),
              contacts_in_private_leisure = sum(contacts_in_private_leisure, na.rm = TRUE),
              contacts_in_public_leisure = sum(contacts_in_public_leisure, na.rm = TRUE),
              contacts_in_pubtrans = sum(contacts_in_pubtrans, na.rm = TRUE),
              contacts_in_queuing = sum(contacts_in_queuing, na.rm = TRUE),
              contacts_in_schools = sum(contacts_in_schools, na.rm = TRUE),
              contacts_in_shared_cars = sum(contacts_in_shared_cars, na.rm = TRUE),
              contacts_in_universities = sum(contacts_in_universities, na.rm = TRUE),
              contacts_in_workplaces = sum(contacts_in_workplaces, na.rm = TRUE),
              total_people = mean(total_people, na.rm = TRUE))
  
  # Divide by total_people
  df_contacts_gp_by_day_per_agent <- df_contacts_gp_by_day %>%
    group_by(day, curfew_type) %>% 
    summarise(AvgNumberOfContactsDay = sum(contacts_in_essential_shops, contacts_in_homes,
                                          contacts_in_hospitals, contacts_in_non_essential_shops,
                                          contacts_in_private_leisure, contacts_in_public_leisure,
                                          contacts_in_pubtrans, contacts_in_queuing,
                                          contacts_in_schools, contacts_in_shared_cars,
                                          contacts_in_universities, contacts_in_workplaces, na.rm = TRUE) / total_people )
  
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_contacts_gp_by_day_per_agent, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_contacts_gp_by_day_per_agent <- gather(df_contacts_gp_by_day_per_agent, variable, measurement, AvgNumberOfContactsDay)
  
  print(paste(name, " making plots", sep=""))

  dmfPdfOpen(output_dir, "curfew_contacts_per_agent")
  print(plot_ggplot(seg_contacts_gp_by_day_per_agent))
  dmfPdfClose()
  
  dmfPdfOpen(output_dir, "curfew_contacts_per_agent_smooth")
  print(plot_ggplot_smooth(seg_contacts_gp_by_day_per_agent))
  dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_line(aes(col=as.factor(curfew_type))) +
    scale_colour_brewer(palette = "Spectral", name="Curfew type") +
    xlab("Days") +
    ylab("Average contacts per agent") + 
    labs(title=paste("Number of contacts average per agent per day"), 
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme + 
    theme(legend.position = "bottom", legend.direction = "vertical")
}

plot_ggplot_smooth <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement)) +
    geom_smooth(aes(col=as.factor(curfew_type)), span=0.1, se=FALSE) +
    scale_colour_brewer(palette = "Spectral", name="Curfew type") +
    xlab("Days") +
    ylab("Average contacts per agent") + 
    labs(title=paste("Number of contacts average per agent per day (smoothed)"),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme +
    theme(legend.position = "bottom", legend.direction = "vertical")
}
