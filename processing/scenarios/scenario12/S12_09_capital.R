#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12CapitalAgents <- function(df_scenario12, df_phase_lengths, output_dir="output_plots_testing", one_plot=F) {
  
  name = "s12_capital"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_capital <- df_scenario12 %>% 
    group_by(tick, experiment_name, condition_phasing_out) %>% 
    summarise(workers_capital = mean(workers_average_amount_of_capital, na.rm=TRUE),
              students_capital = mean(students_average_amount_of_capital, na.rm=TRUE),
              retirees_capital = mean(retirees_average_amount_of_capital, na.rm=TRUE),
              essential_shop_capital = mean(essential_shop_amount_of_capital, na.rm=TRUE),
              non_essential_shop_capital = mean(non_essential_shop_amount_of_capital, na.rm=TRUE),
              total_capital = mean(total_amount_of_capital_in_the_system, na.rm=TRUE),
              government_capital = mean(government_reserve_of_capital, na.rm=TRUE))
  colnames(df_capital)
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_capital, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  
  print(paste(name, " making plots", sep=""))
  
  df_agent_capital <- pivot_longer(df_capital, workers_capital:retirees_capital, names_to = "label", values_to = "capital")
  for(i in unique(df_agent_capital$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_capital_agent_", i, sep=""))
    print(plot_ggplot(filter(df_agent_capital, experiment_name==i), filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  }
  
  df_ess_store_capital <- pivot_longer(df_capital, essential_shop_capital, names_to = "label", values_to = "capital")
  dmfPdfOpen(output_dir, paste("s12_capital_essential_store", sep=""))
  print(plot_ggplot_all(df_ess_store_capital, plot_phases, "Essential shops"))
  dmfPdfClose()
  
  df_ness_store_capital <- pivot_longer(df_capital, non_essential_shop_capital, names_to = "label", values_to = "capital")
  dmfPdfOpen(output_dir, paste("s12_capital_non_essential_store", sep=""))
  print(plot_ggplot_all(df_ness_store_capital, plot_phases, "Non-essential shops"))
  dmfPdfClose()  
  
  df_total_capital <- pivot_longer(df_capital, total_capital, names_to = "label", values_to = "capital")
    dmfPdfOpen(output_dir, paste("s12_capital_total", sep=""))
    print(plot_ggplot_all(df_total_capital, plot_phases, "Total"))
    dmfPdfClose()
  
  df_government_capital <- pivot_longer(df_capital, government_capital, names_to = "label", values_to = "capital")
    dmfPdfOpen(output_dir, paste("s12_capital_government", sep=""))
    print(plot_ggplot_all(df_government_capital, plot_phases, "Government"))
    dmfPdfClose()
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, phase_lengths_to_plot, strat) {
  
  (data_to_plot %>%
    ggplot(aes(x = tick/4, 
               y = capital,
               group = label,
               fill = label), fill=NA) +
    geom_line(aes(col=label)) +
    guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
    xlab("Days") +
    ylab("Capital") +
    labs(title=paste("Amount of capital - exit strategy:", strat),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme)%>% tag_facet()
}

plot_ggplot_all <- function(data_to_plot, phase_lengths_to_plot, of_who) {
  
  (data_to_plot %>%
     ggplot(aes(x = tick/4, 
                y = capital,
                group = experiment_name,
                fill = experiment_name), fill=NA) +
     geom_line(aes(col=experiment_name)) +
     guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
     xlab("Days") +
     ylab("Capital") +
     labs(title=paste("Amount of capital (", of_who, ")", sep = " "),
          caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase), colour=factor(experiment_name)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
     facet_wrap(vars(condition_phasing_out), ncol=2) +
     gl_plot_guides + gl_plot_theme)%>% tag_facet()
}