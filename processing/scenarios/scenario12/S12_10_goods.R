#=============================================================
#====================== MAIN FUNCTION ========================
#=============================================================

plotS12Goods <- function(df_scenario12, df_phase_lengths, output_dir="output_plots_testing", one_plot=F) {
  
  name = "s12_goods"
  
  #-------------------------------------------------------------
  #-------------------- DATA MANIPULATION ----------------------
  #-------------------------------------------------------------
  print(paste(name, " performing data manipulation", sep=""))
  
  df_goods <- df_scenario12 %>% 
    group_by(tick, experiment_name, condition_phasing_out) %>% 
    summarise(essential_shop_goods = mean(essential_shop_amount_of_goods_in_stock, na.rm=TRUE),
              non_essential_shop_goods = mean(non_essential_shop_amount_of_goods_in_stock, na.rm=TRUE),
              workplace_goods = mean(workplace_amount_of_goods_in_stock, na.rm=TRUE))
  colnames(df_goods)
  
  plot_phases <- df_phase_lengths %>% filter(phase != "no_crisis") %>%
    group_by(condition_phasing_out, minimum_days_between_phases, acknowledgement_ratio, experiment_name, phase) %>%
    summarise(start = mean(start))
  
  print(paste(name, " writing CSV", sep=""))
  write.csv(df_goods, file=paste(output_dir, "/plot_data_", name, ".csv", sep=""))
  
  #-------------------------------------------------------------
  #------------------------- Plotting --------------------------
  #-------------------------------------------------------------
  
  print(paste(name, " making plots", sep=""))
  
  df_store_goods <- pivot_longer(df_goods, c(essential_shop_goods, non_essential_shop_goods), names_to = "label", values_to = "goods")
  df_store_goods$label <- df_store_goods$label %>%
    sub("(.*)_goods", "\\1", .) %>%
    gsub("_", " ", .)
  for(i in unique(df_store_goods$experiment_name)) {
    dmfPdfOpen(output_dir, paste("s12_goods_store_", i, sep=""))
    print(plot_ggplot(filter(df_store_goods, experiment_name==i), filter(plot_phases, experiment_name==i), i))
    dmfPdfClose()
  }    
}

#=============================================================
#=================== PLOTTING FUNCTIONS ======================
#=============================================================
plot_ggplot <- function(data_to_plot, phase_lengths_to_plot, strat) {
  
  (data_to_plot %>%
    ggplot(aes(x = tick/4, 
               y = goods,
               group = label,
               fill = label), fill=NA) +
    geom_line(aes(col=label)) +
    guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
    xlab("Days") +
    ylab("Goods in stock") +
    labs(title=paste("Amount of goods in stock - exit strategy:", strat),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
     geom_vline(aes(xintercept=start/4, linetype=factor(phase)), phase_lengths_to_plot) + 
     scale_linetype_manual(name = "Phase start:", drop = FALSE,
                           values = c("solid", "longdash", "dashed", "dotdash"),
                           labels = c("crisis", "phase-1", "phase-2", "phase-3")) +
    facet_wrap(vars(condition_phasing_out), ncol=2) +
    gl_plot_guides + gl_plot_theme)%>% tag_facet()
}