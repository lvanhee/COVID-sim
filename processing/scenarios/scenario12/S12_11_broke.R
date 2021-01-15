plotS12broke <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  name <- "s12_broke"
  
  print(paste(name, " performing data manipulation", sep=""))
  
  df_broke <- df_scenario12 %>% 
    group_by(tick, experiment_name, condition_phasing_out) %>% 
    summarise(workers_out_of_capital = mean(workers_out_of_capital, na.rm = T),
              retired_out_of_capital = mean(retired_out_of_capital, na.rm = T),
              students_out_of_capital = mean(students_out_of_capital, na.rm = T),
              essential_shops_out_of_capital = mean(essential_shops_out_of_capital, na.rm = T),
              non_essential_shops_out_of_capital = mean(non_essential_shops_out_of_capital, na.rm = T),
              workplaces_out_of_capital = mean(workplaces_out_of_capital, na.rm = T),
              count_workers_with_is_in_poverty = mean(count_workers_with_is_in_poverty, na.rm=T),
              count_students_with_is_in_poverty = mean(count_students_with_is_in_poverty, na.rm=T),
              count_retireds_with_is_in_poverty = mean(count_retireds_with_is_in_poverty, na.rm=T))
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_broke, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  
  print(paste(name, " making plots", sep=""))
  
  df_agent_capital <- pivot_longer(df_broke, essential_shops_out_of_capital:workplaces_out_of_capital, names_to = "label", values_to = "Broke")
  df_agent_capital$label <- sub("(.*)_out_of_capital", "\\1", df_agent_capital$label) %>% gsub("_", " ", .)
  for(i in unique(df_agent_capital$experiment_name)) {
    dmfPdfOpen(output_dir, paste(name, i, sep="_"))
    print(plot_ggplot(filter(df_agent_capital, experiment_name==i), filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  } 
  
  df_agents_broke <- pivot_longer(df_broke, starts_with("count_"), names_to = "label", values_to = "Broke")
  df_agents_broke$label <- sub("count_(.*)_with_is_in_poverty", "\\1", df_agents_broke$label)
  for(i in unique(df_agent_capital$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_agents_poverty", i, sep="_"))
    print(plot_ggplot(filter(df_agents_broke, experiment_name==i), filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  } 
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, phase_lengths_to_plot, strat, capital=T) {
  title_ <- if (capital) {"Stores out of capital"} else {"Agents in poverty"}
  
  (data_to_plot %>%
     ggplot(aes(x = tick/4, 
                y = Broke,
                group = label,
                fill = label), fill=NA) +
     geom_line(aes(col=label)) +
     guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
     xlab("Days") +
     ylab("Count") +
     labs(title=paste(title_, "- exit strategy:", strat),
          caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
     facet_wrap(vars(condition_phasing_out), ncol=2) +
     gl_plot_guides + gl_plot_theme)%>% tag_facet()
}
