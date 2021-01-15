plotS12Example <- function(df_scenario12, df_phase_lengths, output_dir, one_plot) {
  df_example <- df_scenario12 %>%
    filter(condition_phasing_out == "new infections under 10 over last 5 days", acknowledgement_ratio == 0.05, minimum_days_between_phases == 30, experiment_name == "PublicServices")
  df_example_lengths <- df_phase_lengths %>%
    filter(condition_phasing_out == "new infections under 10 over last 5 days", acknowledgement_ratio == 0.05, minimum_days_between_phases == 30, experiment_name == "PublicServices")
  
  output_dir <- paste(output_dir, "example", sep = "/")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  source("S12_02_Conditions.R")
  plotS12ConditionsExperimentName(df_example, df_example_lengths, output_dir, one_plot)
  source("S12_03_cumulative_infections.r")
  plotS12CumulativeInfections(df_example, df_example_lengths, experiment_name, "Exit Strategy", output_dir, one_plot)
  source('S12_04_stacked_bar_ratio_infector_infectee.R')
  plotS12StackedBarRatioInfectorInfectee(df_example, output_dir, one_plot)
  source("S12_05_infection_ratio_per_gathering_point_over_time.R")
  plotS12InfectionRatioGP(df_example, df_example_lengths, output_dir, one_plot)
  source("S12_06_contacts_at_gathering_point.R")
  plotS12ContactsAtGatheringPoint(df_example, df_example_lengths, output_dir, one_plot)
  source("S12_07_people_at_gathering_point.R")
  plotS12PeopleAtGatheringPoint(df_example, df_example_lengths, output_dir, one_plot)
  source("S12_09_capital.R")
  plotS12CapitalAgents(df_example, df_example_lengths, output_dir, one_plot)
  source("S12_10_goods.R")
  plotS12Goods(df_example, df_example_lengths, output_dir, one_plot)
}