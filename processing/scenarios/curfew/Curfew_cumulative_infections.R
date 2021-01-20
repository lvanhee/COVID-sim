#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotCurfewCumulativeInfections <- function(df_scenario6, output_dir, one_plot) {

  name = "curfew_infected_compliance_tests"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  #CUMULATIVE INFECTIONS PER APP USAGE SCENARIO ----------------------------
  df_infections <- df_scenario6 %>% 
    group_by(tick, curfew_type) %>% 
    summarise(cumulative_youngs_infected = mean(cumulative_youngs_infected, na.rm = TRUE),
              cumulative_students_infected = mean(cumulative_students_infected, na.rm = TRUE),
              cumulative_workers_infected = mean(cumulative_workers_infected, na.rm = TRUE),
              cumulative_retireds_infected = mean(cumulative_retireds_infected, na.rm = TRUE))
  
  df_total_cummul_infections <- df_infections %>% 
    group_by(tick, curfew_type) %>% 
    summarise(total_cumulative_infections = sum(cumulative_youngs_infected,
                                                cumulative_students_infected,
                                                cumulative_workers_infected,
                                                cumulative_retireds_infected))
  
  df_total_cummul_infections$curfew_type <- as.factor(df_total_cummul_infections$curfew_type)

  print(paste(name, " writing CSV", sep=""))
  write.csv(df_total_cummul_infections, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  print(paste(name, " making plots", sep=""))
  
  dmfPdfOpen(output_dir, "curfew_cumulative_infections")
  print(plot_ggplot(df_total_cummul_infections))
  dmfPdfClose()
}

plot_ggplot <- function(data_to_plot) {
  
  data_to_plot %>%
    ggplot(aes(x = tick / 4,
               y = total_cumulative_infections,
               group = curfew_type,
               fill = curfew_type), fill=NA) +
    geom_line(aes(col=as.factor(curfew_type))) +
    xlab("Days") +
    ylab("Cumulative number of infections") + 
    labs(title="Cumulative Infections depending on the curfew type",
         fill="Proportion of App Users",
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
    scale_colour_brewer(palette = "Spectral", name="Curfew type") +
    gl_plot_guides + gl_plot_theme +
    theme(legend.position = "bottom", legend.direction = "vertical")
}
