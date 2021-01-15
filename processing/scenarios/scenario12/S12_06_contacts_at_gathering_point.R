#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12ContactsAtGatheringPoint <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  
  name = "s12_contacts_at_gathering_point"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_contacts <- df_scenario12 %>% 
    group_by(tick, condition_phasing_out, experiment_name) %>% 
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
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  df_contacts$day <- dmfConvertTicksToDay(df_contacts$tick)
  
  # Sum for every day (combine the four ticks)
  df_contacts_accumulated <- df_contacts %>% 
    group_by(day, condition_phasing_out, experiment_name) %>% 
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
  
  for(i in unique(seg_acc_contacts$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_contacts_per_gp_strat_", i, "_smooth", sep=""))
    print(plot_ggplot_smooth(seg_acc_contacts[seg_acc_contacts$experiment_name==i, ], filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  }  
  
  for(i in unique(seg_acc_contacts$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_contacts_per_gp_strat_", i, sep=""))
    print(plot_ggplot(seg_acc_contacts[seg_acc_contacts$experiment_name==i, ], filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  }  
  
  #==================== DIVIDED PLOTS ==========================
  #seg_acc_contacts1 <- gather(accumulatedContacts, variable, measurement, essential_shops:public_leisure)
  #seg_acc_contacts2 <- gather(accumulatedContacts, variable, measurement, pubtrans:workplaces)
  
  #for(i in c(0, 0.12, 0.8, 1)) {
  #  dmfOpenPdf(output_dir, paste("s12_contacts_per_gp1_app", i, sep=""))
  #  print(plot_ggplot(seg_acc_contacts1[seg_acc_contacts1$ratio_of_app_users==i, ], i))
  #  dmfClosePdf()
  #  
  #  dmfOpenPdf(output_dir, paste("s12_contacts_per_gp2_app", i, sep=""))
  #  print(plot_ggplot(seg_acc_contacts2[seg_acc_contacts1$ratio_of_app_users==i, ], i))
  #  dmfClosePdf()
  #}  
  
  #for(i in c(0, 0.12, 0.8, 1)) {
  #  dmfOpenPdf(output_dir, paste("s12_contacts_per_gp1_smooth_app", i, sep=""))
  #  print(plot_ggplot_smooth(seg_acc_contacts1[seg_acc_contacts1$ratio_of_app_users==i, ], i))
  #  dmfClosePdf()
  #  
  #  dmfOpenPdf(output_dir, paste("s12_contacts_per_gp2_smooth_app", i, sep=""))
  #  print(plot_ggplot_smooth(seg_acc_contacts2[seg_acc_contacts2$ratio_of_app_users==i, ], i))
  #  dmfClosePdf()
  #}  
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, phase_lengths_to_plot, strat) {
  
  (data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement,
               group = Gathering_point,
               fill = Gathering_point), fill=NA) +
    geom_line(aes(col=Gathering_point)) +
    scale_colour_manual(name = "locations", values = c(
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
    guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
    xlab("Days") +
    ylab("Number of contacts per day") +
    labs(title=paste("Number of contacts per type of location - exit strategy:", strat),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme) %>% tag_facet()
}

plot_ggplot_smooth <- function(data_to_plot, phase_lengths_to_plot, strat) {
  
  (data_to_plot %>%
    ggplot(aes(x = day, 
               y = measurement,
               group = Gathering_point,
               fill = Gathering_point), fill=NA) +
    geom_smooth(aes(col=Gathering_point), span=0.1, se=FALSE) +
    scale_colour_manual(name = "locations", values = c(
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
    labs(title=paste("Number of contacts per type of location (Smoothed) - exit strategy:", strat),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme) %>% tag_facet()
}
