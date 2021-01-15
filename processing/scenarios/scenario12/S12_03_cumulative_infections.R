#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12CumulativeInfections <- function(df_scenario12, df_phase_lengths, ctrl_var, var_name, output_dir, one_plot) {
  ctrl_var <- enquo(ctrl_var)

  name = paste("s12_cum_infected", rlang::as_name(ctrl_var), sep = "_")
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  #CUMULATIVE INFECTIONS PER APP USAGE SCENARIO ----------------------------
  df_infections <- df_scenario12 %>% 
    group_by(tick, condition_phasing_out, !!ctrl_var) %>% 
    summarise(cumulative_youngs_infected = mean(cumulative_youngs_infected, na.rm = TRUE),
              cumulative_students_infected = mean(cumulative_students_infected, na.rm = TRUE),
              cumulative_workers_infected = mean(cumulative_workers_infected, na.rm = TRUE),
              cumulative_retireds_infected = mean(cumulative_retireds_infected, na.rm = TRUE),
              youngs_at_start = mean(youngs_at_start),
              students_at_start = mean(students_at_start),
              workers_at_start = mean(workers_at_start),
              retireds_at_start = mean(retireds_at_start))
  
  df_infections <- df_infections %>%
    group_by(tick, condition_phasing_out, !!ctrl_var) %>%
    mutate(cumulative_total_infected = sum(cumulative_youngs_infected,
                                             cumulative_students_infected,
                                             cumulative_workers_infected,
                                             cumulative_retireds_infected),
           agents_at_start = sum(youngs_at_start, students_at_start, workers_at_start, retireds_at_start),
           ratio_youngs_infected = cumulative_youngs_infected / youngs_at_start,
           ratio_students_infected = cumulative_students_infected / students_at_start,
           ratio_workers_infected = cumulative_workers_infected / workers_at_start,
           ratio_retireds_infected = cumulative_retireds_infected / retireds_at_start,
           ratio_total_infected = cumulative_total_infected / agents_at_start)
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, !!ctrl_var, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_infections, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  plot_data <- pivot_longer(df_infections, cols=starts_with("cumulative_"), names_to = "variable", values_to = "counts")
  plot_data$group <- plot_data$variable %>%
    sub("cumulative_(.*)_infected", "\\1", .)
  plot_data$variable <- NULL
  
  for (exp_name in unique(plot_data[[rlang::as_name(ctrl_var)]])) {
    dmfPdfOpen(output_dir, paste("s12_cumulative_infections", rlang::as_name(ctrl_var), exp_name, sep="_"), one_plot = one_plot)
    print(plot_ggplot_all(filter(plot_data, !!ctrl_var == exp_name), filter(plot_phases, !!ctrl_var == exp_name), exp_name, "Age group:"))
    dmfPdfClose(one_plot = one_plot)
  }
  
  dmfPdfOpen(output_dir, paste("s12_cumulative_infections", rlang::as_name(ctrl_var), "all", sep="_"), one_plot = one_plot)
  print(plot_ggplot(filter(plot_data, group=="total"), plot_phases, !!ctrl_var, var_name))
  dmfPdfClose(one_plot = one_plot)
  
  plot_data <- pivot_longer(df_infections, cols=starts_with("ratio_"), names_to = "variable", values_to = "counts")
  plot_data$group <- plot_data$variable %>%
    sub("ratio_(.*)_infected", "\\1", .)
  plot_data$variable <- NULL
  
  for (exp_name in unique(plot_data[[rlang::as_name(ctrl_var)]])) {
    dmfPdfOpen(output_dir, paste("s12_cumulative_ratio_infections", rlang::as_name(ctrl_var), exp_name, sep="_"), one_plot = one_plot)
    print(plot_ggplot_all(filter(plot_data, !!ctrl_var == exp_name), filter(plot_phases, !!ctrl_var == exp_name), exp_name, "Age group:", ratio=T))
    dmfPdfClose(one_plot = one_plot)
  }
}

plot_ggplot <- function(data_to_plot, phase_lengths_to_plot, ctrl_var, legend_name, ratio=F) {
  ctrl_var <- enquo(ctrl_var)
  
  (data_to_plot %>%
    ggplot(aes(x = tick/4,
               y = counts,
               group = !!ctrl_var,
               fill = !!ctrl_var), fill=NA) +
    geom_line(aes(col=as.factor(!!ctrl_var))) +
    xlab("Days") +
    ylab(paste("Cumulative", if (ratio) "ratio" else "number", "of infections", sep= " ")) + 
    labs(title=if (ratio) "Cumulative ratio infected" else "Cumulative Infections",
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
      geom_vline(aes(xintercept=start/4, colour=factor(!!ctrl_var), linetype=factor(phase)), phase_lengths_to_plot) + 
      scale_linetype_manual(name = "Phase start:", drop = FALSE,
                            values = c("solid", "longdash", "dashed", "dotdash"),
                            labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    scale_colour_brewer(palette = "Set1", name=legend_name) +
    gl_plot_guides + gl_plot_theme + 
    theme(legend.position = "bottom")) %>% tag_facet()
}

plot_ggplot_all <- function(data_to_plot, phase_lengths_to_plot, exp_name, legend_name, ratio=F) {
  
  (data_to_plot %>%
    ggplot(aes(x = tick/4,
               y = counts,
               group = group,
               fill = group), fill=NA) +
    geom_line(aes(col=as.factor(group))) +
    xlab("Days") +
    ylab(paste("Cumulative", if (ratio) "ratio" else "number", "of infections", sep= " ")) + 
    labs(title=paste(if (ratio) "Cumulative ratio infected" else "Cumulative Infections", "- Exit strategy:", exp_name, sep=" "),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    scale_colour_brewer(palette = "Set1", name=legend_name) +
    gl_plot_guides + gl_plot_theme + 
    theme(legend.position = "bottom")) %>% tag_facet()
}
