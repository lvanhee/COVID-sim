
plotS12EndStateBoxplots <- function(df_scenario12, ctrl_var, var_descr, output_dir, one_plot) {
  ctrl_var <- enquo(ctrl_var)
  
  name = paste("s12_end_state", rlang::as_name(ctrl_var), sep = "_")
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  #CUMULATIVE INFECTIONS PER APP USAGE SCENARIO ----------------------------
  df_infections <- df_scenario12 %>% 
    filter(tick == 1499) %>%
    group_by(run_number) %>% 
    mutate(cumulative_total_infected = sum(cumulative_youngs_infected,
                                           cumulative_students_infected,
                                           cumulative_workers_infected,
                                           cumulative_retireds_infected)) %>%
    select(condition_phasing_out, !!ctrl_var, cumulative_total_infected, dead_people)
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_infections, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, paste(name, "total_infected", sep="_"), one_plot = one_plot)
  print(plot_ggplot(df_infections, !!ctrl_var, cumulative_total_infected, "Distribution cumulative infected at the end", var_descr, "Cumulative infected"))
  dmfPdfClose(one_plot = one_plot)
  
  dmfPdfOpen(output_dir, paste(name, "total_deceased", sep="_"), one_plot = one_plot)
  print(plot_ggplot(df_infections, !!ctrl_var, dead_people, "Distribution deceased at the end", var_descr, "Deceased"))
  dmfPdfClose(one_plot = one_plot)
}

plot_ggplot <- function(data_to_plot, ctrl_var, y, title, legend_name, ylab = "") {
  ctrl_var <- enquo(ctrl_var)
  y <- enquo(y)
  
  (data_to_plot %>%
     ggplot(aes(x = factor(!!ctrl_var),
                y = !!y), fill=NA) +
     geom_boxplot(aes(fill=as.factor(!!ctrl_var)),
                  notch=FALSE) +
     labs(title=title,
          x="",
          y=ylab,
          caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     facet_wrap(vars(condition_phasing_out), ncol=3) +
     scale_fill_brewer(palette = "Set1", name=legend_name) +
     gl_plot_guides + gl_plot_theme + 
     theme(legend.position = "bottom")) %>% tag_facet()
}
