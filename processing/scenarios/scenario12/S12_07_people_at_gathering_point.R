#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12PeopleAtGatheringPoint <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  
  name = "s12_people_at_gathering_point"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_people <- df_scenario12 %>% 
    group_by(tick, condition_phasing_out, experiment_name) %>% 
    summarise(essential_shops = mean(people_at_essential_shop, na.rm = TRUE),
              homes = mean(people_at_home, na.rm = TRUE),
              hospitals = mean(people_at_hospital, na.rm = TRUE),
              non_essential_shops = mean(people_at_non_essential_shop, na.rm = TRUE),
              private_leisure = mean(people_at_private_leisure, na.rm = TRUE),
              public_leisure = mean(people_at_public_leisure, na.rm = TRUE),
              pubtrans = mean(people_that_took_bus, na.rm = TRUE),
              queuing = mean(people_that_queued, na.rm = TRUE),
              away = mean(people_at_away, na.rm = TRUE),
              schools = mean(people_at_school, na.rm = TRUE),
              shared_cars = mean(people_that_took_shared_car, na.rm = TRUE),
              universities = mean(people_at_university, na.rm = TRUE),
              workplaces = mean(people_at_workplace, na.rm = TRUE))
  colnames(df_people)
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_people, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  seg_acc_people <- gather(df_people, Gathering_point, measurement, essential_shops:workplaces)
  
  print(paste(name, " making plots", sep=""))
  
  for(i in unique(seg_acc_people$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_people_per_gp_strat_", i, "_smooth", sep=""))
    print(plot_ggplot_smooth(seg_acc_people[seg_acc_people$experiment_name==i, ], filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  }  
  
  for(i in unique(seg_acc_people$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_people_per_gp_strat_", i, sep=""))
    print(plot_ggplot(seg_acc_people[seg_acc_people$experiment_name==i, ], filter(plot_phases, experiment_name==i), i))
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
    ggplot(aes(x = tick/4, 
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
    ylab("Number of people per tick") +
    labs(title=paste("Number of people per type of location - exit strategy:", strat),
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
    ggplot(aes(x = tick/4, 
               y = measurement + 1,
               group = Gathering_point,
               fill = Gathering_point), fill=NA) +
    geom_smooth(aes(col=Gathering_point), method="loess", span=0.1, se=FALSE) +
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
    ylab("Number of people per tick") +
    labs(title=paste("Number of people per type of location (Smoothed) - exit strategy:", strat),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme) %>% tag_facet()
}