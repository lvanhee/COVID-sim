#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewContactsAtGatheringPoint <- function(df_scenario6, output_dir, one_plot) {
  
  name = "curfew_contacts_at_gathering_point"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_contacts <- df_scenario6 %>% 
    group_by(tick, curfew_type) %>% 
    summarise(essential_shops = mean(contacts_in_essential_shops, na.rm = TRUE),
              homes = mean(contacts_in_homes, na.rm = TRUE),
              hospitals = mean(contacts_in_hospitals, na.rm = TRUE),
              non_essential_shops = mean(contacts_in_non_essential_shops, na.rm = TRUE),
              private_leisure = mean(contacts_in_private_leisure, na.rm = TRUE),
              public_leisure = mean(contacts_in_public_leisure, na.rm = TRUE),
              pubtrans = mean(contacts_in_pubtrans, na.rm = TRUE),
              queuing = mean(contacts_in_queuing, na.rm = TRUE),
              schools = mean(contacts_in_schools, na.rm = TRUE),
              shared_cars = mean(contacts_in_shared_cars, na.rm = TRUE),
              universities = mean(contacts_in_universities, na.rm = TRUE),
              workplaces = mean(contacts_in_workplaces, na.rm = TRUE))
  colnames(df_contacts)
  
  df_contacts$day <- dmfConvertTicksToDay(df_contacts$tick)
  
  # Sum for every day (combine the four ticks)
  df_contacts_accumulated <- df_contacts %>% 
    group_by(day, curfew_type) %>% 
    summarise(essential_shops = sum(essential_shops, na.rm = TRUE),
              homes = sum(homes, na.rm = TRUE),
              hospitals = sum(hospitals, na.rm = TRUE),
              non_essential_shops = sum(non_essential_shops, na.rm = TRUE),
              private_leisure = sum(private_leisure, na.rm = TRUE),
              public_leisure = sum(public_leisure, na.rm = TRUE),
              pubtrans = sum(pubtrans, na.rm = TRUE),
              queuing = sum(queuing, na.rm = TRUE),
              schools = sum(schools, na.rm = TRUE),
              shared_cars = sum(shared_cars, na.rm = TRUE),
              universities = sum(universities, na.rm = TRUE),
              workplaces = sum(workplaces, na.rm = TRUE))

  print(paste(name, " writing CSV", sep=""))
  write.csv(df_contacts_accumulated, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_acc_contacts <- gather(df_contacts_accumulated, Gathering_point, measurement, essential_shops:workplaces)
  
  
  print(paste(name, " making plots", sep=""))

  for(i in unique(seg_acc_contacts$curfew_type)) {
    dmfPdfOpen(output_dir, paste("curfew_contacts_per_gp_app_", i, "_smooth", sep=""))
    print(plot_ggplot_smooth(seg_acc_contacts[seg_acc_contacts$curfew_type==i, ], i))
    dmfPdfClose()
  }  
  
  for(i in unique(seg_acc_contacts$curfew_type)) {
    dmfPdfOpen(output_dir, paste("curfew_contacts_per_gp_app_", i, sep=""))
    print(plot_ggplot(seg_acc_contacts[seg_acc_contacts$curfew_type==i, ], i))
    dmfPdfClose()
  }  
  
  #==================== DIVIDED PLOTS ==========================
  #seg_acc_contacts1 <- gather(accumulatedContacts, variable, measurement, essential_shops:public_leisure)
  #seg_acc_contacts2 <- gather(accumulatedContacts, variable, measurement, pubtrans:workplaces)
  
  #for(i in c(0, 0.6, 0.8, 1)) {
  #  dmfOpenPdf(output_dir, paste("curfew__contacts_per_gp1_app", i, sep=""))
  #  print(plot_ggplot(seg_acc_contacts1[seg_acc_contacts1$curfew_type==i, ], i))
  #  dmfClosePdf()
  #  
  #  dmfOpenPdf(output_dir, paste("curfew__contacts_per_gp2_app", i, sep=""))
  #  print(plot_ggplot(seg_acc_contacts2[seg_acc_contacts1$curfew_type==i, ], i))
  #  dmfClosePdf()
  #}  
  
  #for(i in c(0, 0.6, 0.8, 1)) {
  #  dmfOpenPdf(output_dir, paste("curfew__contacts_per_gp1_smooth_app", i, sep=""))
  #  print(plot_ggplot_smooth(seg_acc_contacts1[seg_acc_contacts1$curfew_type==i, ], i))
  #  dmfClosePdf()
  #  
  #  dmfOpenPdf(output_dir, paste("curfew__contacts_per_gp2_smooth_app", i, sep=""))
  #  print(plot_ggplot_smooth(seg_acc_contacts2[seg_acc_contacts2$curfew_type==i, ], i))
  #  dmfClosePdf()
  #}  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, app_use) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement,
               group = Gathering_point,
               fill = Gathering_point), fill=NA) +
    geom_line(aes(col=Gathering_point)) +
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
    ylab("Number of contacts per day") +
    labs(title=paste("Number of contacts per gathering point - curfew type:", app_use),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}

plot_ggplot_smooth <- function(data_to_plot, app_use) {
  
  data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement,
               group = Gathering_point,
               fill = Gathering_point), fill=NA) +
    geom_smooth(aes(col=Gathering_point), span=0.1, se=FALSE) +
    scale_colour_manual(values = c(
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
    ylab("Number of contacts per day") +
    labs(title=paste("Number of contacts per gathering point (Smoothed) - curfew type:", app_use),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    gl_plot_guides + gl_plot_theme
}
