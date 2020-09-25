assocc_processing.plot <- function(x_var_name,
                                   y_var_name,
                                   
                                   #line names should be input parameters to be compared against each other
                                   #a list can be provided (e.g. "ratio app user" and "recursive")
                                   lines_var_names, 
                                   input_variables_to_display,
                                   local_df,
                                   title_string = "",
                                   print_shadows = FALSE,
                                   smoothen_curve = FALSE,
                                   export_to_csv_file = TRUE
) 
{
  ##preprocessing data
  #throw away variables that are not used out of the original dataframe, for greater readibility
  vars_to_remember <- c(x_var_name, y_var_name, lines_var_names, "X.random.seed")
  tmp_dataframe <- local_df[c(x_var_name, y_var_name,"X.random.seed")]

  #in case of multiple line variables, the multiple line variable columns must be fused into unique column called "line_name"
  #for instance "ratio app user = 0.8" and "recursive = true" should be fused in "line_name=0.8, true"
  foreach(id = lines_var_names)%do% {tmp_dataframe$line_name <- paste(tmp_dataframe$line_name,local_df[,id])}
  local_df <- tmp_dataframe
  xData = local_df[[x_var_name]]
  yData = local_df[[y_var_name]]
  
  #generate a dataframe for the averages (e.g. fusing the random seeds)
  means <- local_df %>% 
    group_by(local_df[x_var_name], line_name) %>% 
    summarise(mean = mean(!!sym(y_var_name), na.rm = TRUE))
  
  colnames(means)[names(means)=='mean'] <- y_var_name
  colnames(means)[names(means)=='grp'] <- "line_name"
  
  local_df <- arrange(local_df, nb.days)
  
  ##some checking and preparing automatic title generation (automating the writing of the title)
  #a bit dirty, should be left out to a subprocedure
  number_of_repetitions<-length(table(i$X.random.seed))
  
  firstRound <- TRUE
  parametersString <- ""
  foreach(name = input_variables_to_display) %do% 
    {
      number_occurrences <- length(table(local_df[[name]][1]))
      if(number_occurrences > 1)
        stop(paste("Wrong number of occurrences for",name))
      value_of_occurrence <- names(table(local_df[[name]][1]))[1]
      if(! firstRound){
        parametersString <- paste(parametersString,",", sep = "")
        firstRound <- FALSE
      }
      
      parametersString <- paste(parametersString,assocc_processing.get_display_name(name))
      if(! firstRound)paste(parametersString,",", sep="")
      parametersString <- paste(parametersString,value_of_occurrence, sep = "")
    }

  ##automatic generation of the title string
  if(title_string == "")
  {  
  title_string <- paste(assocc_processing.get_display_name(y_var_name)," depending on  ", assocc_processing.get_display_name(lines_var_names), " (",
        parametersString, sep="")
  if(!firstRound) if(! firstRound)paste(title_string,",", sep="")
  title_string <- paste(title_string,"N=",number_of_repetitions,")", sep ="")
  }
  
  ##actual plotting
  #plot according to a given x variable
  p <- ggplot(local_df, aes(x=!!sym(x_var_name),colour=line_name))
  
  #plot the shadows
  #--seems to be broken due to the data manipulation cleanup we did for spitting out CSV files
  #but no-one seems to care about this function anymore, so me neither
  #I guess it is about sorting things around such that it is adequately grouped
  if(print_shadows)
    p <- p + geom_line(alpha = 0.2, aes(group = X.random.seed, y=!!sym(y_var_name)))
  
  #plot the averaged curves
  if(smoothen_curve) p <- p + 
    geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,aes(y=means[[y_var_name]]))
  else p <- p + geom_line(data = means,size = 1,aes(y=means[[y_var_name]]))

  lines_display_string <- assocc_processing.get_display_name(lines_var_names)
  
  #fixing the cosmetics of the plot (line names, line colors, title)
  p<- p +
    xlab(assocc_processing.get_display_name(x_var_name)) +
    ylab(assocc_processing.get_display_name(y_var_name)) + 
    labs(title=title_string,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         colours = lines_display_string)+
    scale_linetype_discrete(lines_display_string) +
    scale_shape_discrete(lines_display_string) +
    scale_colour_discrete(lines_display_string) +
  scale_color_viridis_d(lines_display_string, end = 0.9)
  
  ##spit out the data in CSV file
  if(export_to_csv_file)
  {
    write.csv(local_df,paste(title_string," (raw).csv",sep = ""), row.names = TRUE)
    write.csv(means,paste(title_string," (averaged).csv",sep = ""), row.names = TRUE)
  }
  p
}

prepare_plot_along_different_Y <- function(
  cumulative,
  x_var_name,
  list_of_y_variables_to_compare,
  name_independent_variables_to_display,
  local_df
)
{
  if(cumulative)
  {
    list_of_point_identifier <- c("X.run.number.", x_var_name,  "X.random.seed")
    list_of_variables_to_save <- c(list_of_point_identifier, list_of_y_variables_to_compare)
    list_of_all_variables_to_remember <- c(list_of_variables_to_save, name_independent_variables_to_display)
    df_tmp <- local_df[list_of_variables_to_save] 
    df_res <- local_df[list_of_all_variables_to_remember]
    foreach(name = list_of_y_variables_to_compare) %do% 
      {
        df_tmp_local <- local_df[c(list_of_point_identifier,name)]
        
        df_tmp_local_cumulative <- 
          df_tmp_local %>% 
          group_by(!!sym("X.run.number.")) %>% 
          arrange(!!sym(x_var_name)) %>% 
          mutate(cs = cumsum(!!sym(name))
          )
        df_tmp_local_cumulative[[name]]<-df_tmp_local_cumulative$cs
        df_tmp_local_cumulative = subset(df_tmp_local_cumulative, select = -cs )
        to_del <- c(name)
        # print(paste("to delete:", to_del)
        df_tmp <- df_tmp[,!(names(df_tmp) %in% to_del)]
        df_tmp <- merge(df_tmp,df_tmp_local_cumulative,by=list_of_point_identifier)
      }
    #local_df <- df_tmp[ , -which(names(df_tmp) %in% list_of_y_variables_to_compare)]
    local_df <- df_tmp
  }
  
  vars_to_remember <- c(x_var_name, list_of_y_variables_to_compare, "X.random.seed")
  local_df <- local_df[vars_to_remember]
  local_df
}

average_df_over <- function(
  local_df,
  variable_to_keep_distinct,
  variables_to_maintain_and_fuse
)
{
  means <- local_df %>% 
    group_by(default_x_var_name=c(local_df[[x_var_name]])) %>% 
    summarise_at(variables_to_maintain_and_fuse, mean, na.rm = TRUE)
  
  means[x_var_name] = means$default_x_var_name
  means = means[ , -which(names(means) %in% c("default_x_var_name"))]
  means
}

assocc_processing.plotCompareAlongDifferentY <- function(x_var_name,
                                                         y_display_var_name,
                                                         list_of_y_variables_to_compare,
                                                         name_independent_variables_to_display,
                                                         local_df,
                                                         title_string = "",
                                                         cumulative=FALSE,
                                                         with_shadows = FALSE,
                                                         smoothen_curve = FALSE,
                                                         lines_display_string = "variables",
                                                         export_to_csv_file = TRUE) 
{
  local_df = prepare_plot_along_different_Y(
    cumulative, 
    x_var_name,
    list_of_y_variables_to_compare,
    name_independent_variables_to_display,
    local_df
    )
  
  all_the_means_altogether = average_df_over(local_df, x_var_name, list_of_y_variables_to_compare)
  val_x <- sym(x_var_name) 
  
  p <- ggplot(local_df, aes(x=x_var_name))
  
  position <- "identity"
  
  if(length(list_of_y_variables_to_compare) >= 1)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[1]), na.rm = TRUE))
    
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        #position = "stack",
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed, 
                        y=!!sym(list_of_y_variables_to_compare[1]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))  
    
    if(smoothen_curve) #p = p + 
        p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                    aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))
    else p<-p + geom_line(data = means,size=1,aes(x=!!sym(x_var_name), y=mean, 
                                           colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))
    

    
    
  } 
  if(length(list_of_y_variables_to_compare) >= 2)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[2]), na.rm = TRUE))
    
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,
        aes(x=!!val_x,group = X.random.seed,
            y=!!sym(list_of_y_variables_to_compare[2]),
            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
  }
  if(length(list_of_y_variables_to_compare) >= 3)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[3]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[3]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3]))) 
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[3])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[3])))
    
  }
  if(length(list_of_y_variables_to_compare) >= 4)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[4]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[4]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = 
                                             assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))
  }
  if(length(list_of_y_variables_to_compare) >= 5)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[5]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[5]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))  
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))
    
  }
  if(length(list_of_y_variables_to_compare) >= 6)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[6]), na.rm = TRUE))
    
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[6]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))  
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))
    
  }
  if(length(list_of_y_variables_to_compare) >= 7)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[7]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                            y=!!sym(list_of_y_variables_to_compare[7]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))

    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))
  }
  if(length(list_of_y_variables_to_compare) >= 8)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[8]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[8]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))
  }
  if(length(list_of_y_variables_to_compare) >= 9)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[9]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[9]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9]))) 
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[9])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[9])))
    
  }
  if(length(list_of_y_variables_to_compare) >= 10)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[10]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[10]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))
  }
  if(length(list_of_y_variables_to_compare) >= 11)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[11]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[11]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))
  }
  if(length(list_of_y_variables_to_compare) >= 12)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[12]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[12]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[12])))
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[12])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[12])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[12])))
  }
  if(length(list_of_y_variables_to_compare) >= 13)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[13]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[13]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[13]))) 
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[13])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[13])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[13])))
  }
  if(length(list_of_y_variables_to_compare) >= 14)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[14]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[14]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[14]))) 
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[14])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[14])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[14])))
  }
  if(length(list_of_y_variables_to_compare) >= 15)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[15]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[15]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[15]))) 
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[15])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[15])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[15])))
    
  }
  if(length(list_of_y_variables_to_compare) >= 16)
  {
    means <- local_df %>% 
      group_by(local_df[x_var_name]) %>% 
      summarise(mean = mean(!!sym(list_of_y_variables_to_compare[16]), na.rm = TRUE))
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        alpha = 0.2,aes(x=!!val_x,group = X.random.seed,
                        y=!!sym(list_of_y_variables_to_compare[16]),
                        colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[16]))) 
    
    colour = colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[16])
    if(smoothen_curve) #p = p + 
      p = p + geom_smooth(data=means, method="loess", size=1, span = 0.25, se=FALSE, fullrange=FALSE, level=0.95,
                          aes(x=!!sym(x_var_name),y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[16])))
    else p<-p + geom_line(data = means, size=1,aes(x=!!sym(x_var_name), y=mean, colour = assocc_processing.get_display_name(list_of_y_variables_to_compare[16])))
    
  }
  if(length(list_of_y_variables_to_compare) >= 17)
  {stop(paste("Not defined for more than",length(list_of_y_variables_to_compare), "lines"))}
  
  if(title_string == "")
    title_string = assocc_processing.get_title(x_var_name, y_display_var_name, name_independent_variables_to_display,
                                               local_df, cumulative)
  colours_name = lines_display_string
  
  p<-p+
    labs(
      title =  title_string,
      caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
      colours = colours_name,
      colour = "variables"
    )   +
    xlab(assocc_processing.get_display_name(x_var_name)) +
    ylab(assocc_processing.get_display_name(y_display_var_name)) + 
    scale_linetype_discrete(lines_display_string) +
    scale_shape_discrete(lines_display_string) +
    scale_colour_discrete(lines_display_string)
  
  ##spit out the data in CSV file
  if(export_to_csv_file)
  {
    write.csv(local_df,paste(title_string," (raw).csv",sep = ""), row.names = TRUE)
    write.csv(all_the_means_altogether,paste(title_string," (averaged).csv",sep = ""), row.names = TRUE)
  }
  
  p
}


assocc_processing.plotCompareAlongDifferentY_matrix <- function(x_var_name,
                                                                y_var_name,
                                                                list_of_y_variables_to_compare,
                                                                name_independent_variables_to_display,
                                                                df) 
{
  val_x <- sym(x_var_name) 
  
  
  
  
  if(length(list_of_y_variables_to_compare) >= 1)
  {
    p <- ggplot(df, aes(group = X.random.seed ))
    p<-p +  geom_line(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[1]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))  }
  if(length(list_of_y_variables_to_compare) >= 2)
  {
    p1 <- ggplot(df)
    p1<-p1 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[2]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
  }
  if(length(list_of_y_variables_to_compare) >= 3)
  {
    p2 <- ggplot(df)
    p2<-p2 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[3]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3])))  }
  if(length(list_of_y_variables_to_compare) >= 4)
  {
    p3 <- ggplot(df)
    p3<-p3 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[4]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))  }
  if(length(list_of_y_variables_to_compare) >= 5)
  {
    p4 <- ggplot(df)
    p4<-p4 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[5]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))  }
  if(length(list_of_y_variables_to_compare) >= 6)
  {
    p5 <- ggplot(df)
    p5<-p5 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[6]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))  }
  if(length(list_of_y_variables_to_compare) >= 7)
  {
    p6 <- ggplot(df)
    p6<-p6 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[7]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))  }
  if(length(list_of_y_variables_to_compare) >= 8)
  {
    p7 <- ggplot(df)
    p7<-p7 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[8]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))  }
  if(length(list_of_y_variables_to_compare) >= 9)
  {
    p8 <- ggplot(df)
    p8<-p8 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[9]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9])))  }
  if(length(list_of_y_variables_to_compare) >= 10)
  {
    p9 <- ggplot(df)
    p9<-p9 +  geom_line(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[10]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))  }
  if(length(list_of_y_variables_to_compare) >= 11)
  {
    p10 <- ggplot(df)
    p10<-p10 +  geom_line(aes(x=!!val_x,
                                y=!!sym(list_of_y_variables_to_compare[11]),
                                colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))  }
  if(length(list_of_y_variables_to_compare) >= 12)
  {
    p11 <- ggplot(df)
    p11<-p11 +  geom_line(aes(x=!!val_x,
                                y=!!sym(list_of_y_variables_to_compare[12]),
                                colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[12])))  }
  if(length(list_of_y_variables_to_compare) >= 13)
  {
    p12 <- ggplot(df)
    p12<-p12 +  geom_line(aes(x=!!val_x,
                                y=!!sym(list_of_y_variables_to_compare[13]),
                                colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[13])))  }
  if(length(list_of_y_variables_to_compare) >= 14)
  {
    p13 <- ggplot(df)
    p13<-p13 +  geom_line(aes(x=!!val_x,
                                y=!!sym(list_of_y_variables_to_compare[14]),
                                colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[14])))  }
  if(length(list_of_y_variables_to_compare) >= 15)
  {
    p14 <- ggplot(df)
    p14<-p14 +  geom_line(aes(x=!!val_x,
                                y=!!sym(list_of_y_variables_to_compare[15]),
                                colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[15])))  }
  if(length(list_of_y_variables_to_compare) >= 16)
  {
    p15 <- ggplot(df)
    p15<-p15 +  geom_line(aes(x=!!val_x,
                                y=!!sym(list_of_y_variables_to_compare[16]),
                                colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[16])))  }
  if(length(list_of_y_variables_to_compare) >= 17)
  {stop("Not defined for more than 16 lines:")}
  
  p<-p+assocc_processing.get_title2(x_var_name, 
                                    x_var_name = 
                                      paste(y_var_name, 
                                            "young -> young"), c(),
                                    df)+
    theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p1<-p1+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "young -> workers"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p2<-p2+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "young -> students"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p3<-p3+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "young -> retireds"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p4<-p4+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "workers -> young"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p5<-p5+assocc_processing.get_title2(x_var_name, paste(y_var_name,  "workers -> workers"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p6<-p6+assocc_processing.get_title2(x_var_name, paste(y_var_name,  "workers -> students"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p7<-p7+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "workers -> retireds"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  
  p8<-p8+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "students -> young"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p9<-p9+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "students -> workers"), c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p10<-p10+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "students -> students"), c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p11<-p11+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "students -> retireds"), c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  
  p12<-p12+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "retireds -> young"), c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p13<-p13+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "retireds -> workers"), c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p14<-p14+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "retireds -> students"), c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p15<-p15+assocc_processing.get_title2(x_var_name,  paste(y_var_name, "retireds -> retireds"), c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  
  figure <- ggarrange(p, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, ncol = 4, nrow = 4)
  
  
}


assocc_processing.plot_stacked_bar_chart2 <- function (
  df,
  values,
  x_output_name,
  y_output_name,
  linesVarName,
  get_variable_name_crossing_x_y,
  title_constants
)
{
  list_of_columns <- c()
  local_df <- c()
  foreach(xval = values ) %do%
    {
      values_xval <- c()
      foreach(yval = values ) %do%
        {
          values_xval <- c(values_xval, sum(df[[get_variable_name_crossing_x_y(xval,yval)]]))
        }
      local_df[[xval]]<- values_xval
    }
  
  local_df <- data.frame(local_df, row.names = values)
  local_df$y <- values
  
  toPlotdfLong <- melt(local_df, id.vars = c("y"), value.name = y_output_name)
  names(toPlotdfLong)[2] <-paste("x") 
  
  title <- paste(y_output_name, linesVarName, "per",  x_output_name, title_constants)
  
  
  
  # factored <- factor(df$y, levels = rev(values))
  factored <- c(toPlotdfLong$y)
  x_list <- c(toPlotdfLong$x)
  y_list <- c(toPlotdfLong[[y_output_name]])
  
  var_y <- sym(y_output_name)
  
  ggplot(toPlotdfLong, aes( x=x, y=!!var_y,
                            #fill = factored
                            fill = factor(y,levels = values)
  )) + 
    geom_bar(position="fill", stat="identity") +   
    labs(
      title =title,
      caption = "ASSOCC", fill = linesVarName, x=x_output_name, y = y_output_name
    )
}


assocc_processing.plot_stacked_bar_chart <- function (df)
{
  ########WAS NOT DEFINED, QUICK BUGFIX###########
  name_independent_variables_to_display <- c()
  #Stacked bar plot#####################################################################
  generalPurpose <- "Infected by age group -"
  anxietyUsersTemplate <- "Ratio anxiety users" 
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  normalize <- function(x) {x/sum(x)}
  
  pdf("NonNormalizedInfectionsPerAgeGroupPerRun.pdf")
  for (j in 1:max(df$X.run.number.))
  {
    
    run1df <- subset(df, X.run.number. == j)
    young <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.young.age))
    students <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.student.age))
    workers <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.worker.age))
    retired <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.retired.age))
    rowNames <- c("young", "students", "workers", "retired")
    
    #young <- normalize(young)
    #students <- normalize(students)
    #workers <- normalize(workers)
    #retired <- normalize(retired)
    
    ratioAnxietyUsers <- toString(run1df[1,2])
    ratioAppUsers <- toString(run1df[1,3])
    
    toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
    
    toPlotdf$age <-rowNames
    
    
    toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
    names(toPlotdfLong)[2] <-paste("age_group") 
    
    q = ggplot(toPlotdfLong, aes( y=proportion, x=age_group, fill = factor(age, levels = rev(rowNames)))) + 
      geom_bar(position="stack", stat="identity") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
        caption = "ASSOCC", fill = "age"
      )
    print(q)
    
    Sys.sleep(1)
  }
  dev.off()
  
  # pdf("plotsStudentYoung.pdf")
  # 
  # for (i in 1:9){
  #  
  #   run1df <- subset(df, df$X.run.number. == i)
  #   young <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.young.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.young.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.young.age.retired.age))
  #   students <- c(sum (run1df$ratio.age.group.to.age.group..infections.student.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.retired.age))
  #   workers <- c(sum (run1df$ratio.age.group.to.age.group..infections.worker.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.retired.age))
  #   retired <- c(sum (run1df$ratio.age.group.to.age.group..infections.retired.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.retired.age))
  #   rowNames <- c("young", "students", "workers", "retired")
  #   
  #   ratioAnxietyUsers <- toString(run1df[1,2])
  #   ratioAppUsers <- toString(run1df[1,3])
  #   
  #   toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
  #   toPlotdf$age <-rowNames
  #   
  #   
  #   toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
  #   names(toPlotdfLong)[2] <-paste("age_group") 
  #   
  #   p = ggplot(toPlotdfLong, aes( y=proportion, x=age_group, fill = age)) + 
  #     geom_bar(position="stack", stat="identity") +   labs(
  #       title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
  #       subtitle = "Calculation students infected by young: ratio.age.group.to.age.group..infections.student.age.young.age",
  #       caption = "ASSOCC"
  #     )
  #   print(p)
  # }
  # dev.off()
  
  pdf("NormalizedInfectionsAgeGroupPerRun.pdf")
  for (j in 1:max(df$X.run.number.)){
    run1df <- subset(df, X.run.number. == j)
    young <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.young.age))
    students <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.student.age))
    workers <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.worker.age))
    retired <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.retired.age))
    rowNames <- c("young", "students", "workers", "retired")
    
    # young <- normalize(young)
    #students <- normalize(students)
    #workers <- normalize(workers)
    #retired <- normalize(retired)
    
    ratioAnxietyUsers <- toString(run1df[1,2])
    ratioAppUsers <- toString(run1df[1,3])
    
    toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
    
    toPlotdf$age <-rowNames
    
    library(reshape2)
    toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
    names(toPlotdfLong)[2] <-paste("age_group") 
    
    
    q = ggplot(toPlotdfLong, aes( y=proportion, x=age_group, fill = factor(age, levels = rev(rowNames)))) + 
      geom_bar(position="fill", stat="identity") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
        caption = "ASSOCC", fill = "age"
      )
    print(q)
    Sys.sleep(1)
  }
  
  dev.off()
  
  #######################################################################################
  
  #######ContactsPerAgeGroup#############################################################
  generalPurpose <- "Contacted by age group -\n"
  anxietyUsersTemplate <- "Ratio anxiety users" 
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  normalize <- function(x) {x/sum(x)}
  
  pdf("NonNormalizedContactsPerAgeGroupPerRun.pdf")
  for (k in 1:max(df$X.run.number.)){
    run1df <- subset(df, X.run.number. == k)
    young <- c(sum (run1df$age.group.to.age.group..contacts.young.age.young.age), sum (run1df$age.group.to.age.group..contacts.student.age.young.age), sum (run1df$age.group.to.age.group..contacts.worker.age.young.age), sum (run1df$age.group.to.age.group..contacts.retired.age.young.age))
    students <- c(sum (run1df$age.group.to.age.group..contacts.young.age.student.age), sum (run1df$age.group.to.age.group..contacts.student.age.student.age), sum (run1df$age.group.to.age.group..contacts.worker.age.student.age), sum (run1df$age.group.to.age.group..contacts.retired.age.student.age))
    workers <- c(sum (run1df$age.group.to.age.group..contacts.young.age.worker.age), sum (run1df$age.group.to.age.group..contacts.student.age.worker.age), sum (run1df$age.group.to.age.group..contacts.worker.age.worker.age), sum (run1df$age.group.to.age.group..contacts.retired.age.worker.age))
    retired <- c(sum (run1df$age.group.to.age.group..contacts.young.age.retired.age), sum (run1df$age.group.to.age.group..contacts.student.age.retired.age), sum (run1df$age.group.to.age.group..contacts.worker.age.retired.age), sum (run1df$age.group.to.age.group..contacts.retired.age.retired.age))
    rowNames <- c("young", "students", "workers", "retired")
    
    
    
    ratioAnxietyUsers <- toString(run1df[1,2])
    ratioAppUsers <- toString(run1df[1,3])
    
    toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
    
    toPlotdf$age <-rowNames
    
    library(reshape2)
    toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
    names(toPlotdfLong)[2] <-paste("age_group")
    names(toPlotdfLong)[3] <-paste("amount")
    
    u = ggplot(toPlotdfLong, aes( y=amount, x=age_group, fill = factor(age, levels = rev(rowNames)))) + 
      geom_bar(position="stack", stat="identity") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
        caption = "ASSOCC", fill = "age"
      )
    print(u)
  }
  dev.off()
  
  ################AVERAGE CONTACTS PER AGE GROUP####################################################
  generalPurpose <- "Contacted by age group -\n"
  anxietyUsersTemplate <- "Ratio anxiety users"
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  ratioAnxietyUsers <- "1"
  rowNames <- c("young", "students", "workers", "retired")
  
  pdf("AverageNonNormalizedContactsPerAgeGroup.pdf")
  RightsplittedByAppUsage  <- split(df, df$ratio.of.people.using.the.tracking.app, df$ratio.of.anxiety.avoidance.tracing.app.users)
  
  foreach(splittedByAppUsage = RightsplittedByAppUsage) %do% {
    young <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.young.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.young.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.young.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.young.age))
    students <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.student.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.student.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.student.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.student.age))
    workers <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.worker.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.worker.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.worker.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.worker.age))
    retired <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.retired.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.retired.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.retired.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.retired.age))
    
    factor <-length(unique(splittedByAppUsage$X.random.seed))
    
    averageYoung <- young / factor
    averageStudents <- students / factor
    averageWorkers <- workers / factor
    averageRetired <- retired / factor
    
    toPlotdf <- data.frame(averageYoung, averageStudents, averageWorkers, averageRetired, row.names = rowNames)
    
    toPlotdf$age <-rowNames
    
    library(reshape2)
    toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
    names(toPlotdfLong)[2] <-paste("age_group")
    names(toPlotdfLong)[3] <-paste("amount")
    
    u = ggplot(toPlotdfLong, aes( y=amount, x=age_group, fill = factor(age, levels = rev(rowNames)))) +
      geom_bar(position="stack", stat="identity") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, toString(splittedByAppUsage$ratio.of.people.using.the.tracking.app[1]), sep= " "),
        caption = "ASSOCC", fill = "age"
      )
    print(u)
    Sys.sleep(1)
    
  }
  dev.off()
  #######################################################################################
  #######ContactsPerAgeGroup#############################################################
  generalPurpose <- "Contacted by age group -\n"
  anxietyUsersTemplate <- "Ratio anxiety users" 
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  normalize <- function(x) {x/sum(x)}
  
  pdf("NormalizedContactsPerAgeGroupPerRun.pdf")
  for (k in 1:max(df$X.run.number.)){
    run1df <- subset(df, X.run.number. == k)
    young <- c(sum (run1df$age.group.to.age.group..contacts.young.age.young.age), sum (run1df$age.group.to.age.group..contacts.student.age.young.age), sum (run1df$age.group.to.age.group..contacts.worker.age.young.age), sum (run1df$age.group.to.age.group..contacts.retired.age.young.age))
    students <- c(sum (run1df$age.group.to.age.group..contacts.young.age.student.age), sum (run1df$age.group.to.age.group..contacts.student.age.student.age), sum (run1df$age.group.to.age.group..contacts.worker.age.student.age), sum (run1df$age.group.to.age.group..contacts.retired.age.student.age))
    workers <- c(sum (run1df$age.group.to.age.group..contacts.young.age.worker.age), sum (run1df$age.group.to.age.group..contacts.student.age.worker.age), sum (run1df$age.group.to.age.group..contacts.worker.age.worker.age), sum (run1df$age.group.to.age.group..contacts.retired.age.worker.age))
    retired <- c(sum (run1df$age.group.to.age.group..contacts.young.age.retired.age), sum (run1df$age.group.to.age.group..contacts.student.age.retired.age), sum (run1df$age.group.to.age.group..contacts.worker.age.retired.age), sum (run1df$age.group.to.age.group..contacts.retired.age.retired.age))
    rowNames <- c("young", "students", "workers", "retired")
    
    
    
    ratioAnxietyUsers <- toString(run1df[1,2])
    ratioAppUsers <- toString(run1df[1,3])
    
    toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
    
    toPlotdf$age <-rowNames
    
    library(reshape2)
    toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
    names(toPlotdfLong)[2] <-paste("age_group")
    names(toPlotdfLong)[3] <-paste("amount")
    
    u = ggplot(toPlotdfLong, aes( y=amount, x=age_group, fill = factor(age, levels = rev(rowNames)))) + 
      geom_bar(position="fill", stat="identity") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
        caption = "ASSOCC", fill = "age"
      )
    print(u)
  }
  dev.off()
  
  ################AVERAGE CONTACTS PER AGE GROUP####################################################
  generalPurpose <- "Contacted by age group -\n"
  anxietyUsersTemplate <- "Ratio anxiety users"
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  ratioAnxietyUsers <- "1"
  rowNames <- c("young", "students", "workers", "retired")
  
  pdf("AverageNormalizedContactsPerAgeGroup.pdf")
  RightsplittedByAppUsage  <- split(df, df$ratio.of.people.using.the.tracking.app, df$ratio.of.anxiety.avoidance.tracing.app.users)
  
  foreach(splittedByAppUsage = RightsplittedByAppUsage) %do% {
    young <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.young.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.young.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.young.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.young.age))
    students <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.student.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.student.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.student.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.student.age))
    workers <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.worker.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.worker.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.worker.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.worker.age))
    retired <- c(sum (splittedByAppUsage$age.group.to.age.group..contacts.young.age.retired.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.student.age.retired.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.worker.age.retired.age), sum (splittedByAppUsage$age.group.to.age.group..contacts.retired.age.retired.age))
    
    factor <-length(unique(splittedByAppUsage$X.random.seed))
    
    averageYoung <- young / factor
    averageStudents <- students / factor
    averageWorkers <- workers / factor
    averageRetired <- retired / factor
    
    toPlotdf <- data.frame(averageYoung, averageStudents, averageWorkers, averageRetired, row.names = rowNames)
    
    toPlotdf$age <-rowNames
    
    library(reshape2)
    toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
    names(toPlotdfLong)[2] <-paste("age_group")
    names(toPlotdfLong)[3] <-paste("amount")
    
    u = ggplot(toPlotdfLong, aes( y=amount, x=age_group, fill = factor(age, levels = rev(rowNames)))) +
      geom_bar(position="fill", stat="identity") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, toString(splittedByAppUsage$ratio.of.people.using.the.tracking.app[1]), sep= " "),
        caption = "ASSOCC", fill = "age"
      )
    print(u)
    Sys.sleep(1)
    
  }
  dev.off()
  #######################################################################################
  ##############################Contact per gathering point#############################
  generalPurpose <- "Contacts gathering point -\n"
  anxietyUsersTemplate <- "Ratio anxiety users"
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  
  
  pdf("ContactsPerGatheringPointPerRun.pdf")
  for (k in 1:max(df$X.run.number.)){
    run1df <- subset(df, X.run.number. == k)
    homes <- sum(run1df$X.contacts.in.homes)
    workplaces <- sum(run1df$X.contacts.in.workplaces)
    schools <- sum(run1df$X.contacts.in.schools)
    universities <- sum(run1df$X.contacts.in.universities)
    essentialShops <- sum(run1df$X.contacts.in.essential.shops)
    nonEssentianShops <- sum(run1df$X.contacts.in.non.essential.shops)
    hospital <- sum(run1df$X.contacts.in.hospitals)
    publicLeisure <- sum(run1df$X.contacts.in.public.leisure)
    privateLeisure <- sum(run1df$X.contacts.in.private.leisure)
    publicTransport <- sum(run1df$X.contacts.in.pubtrans)
    queuying <- sum(run1df$X.contacts.in.queuing)
    sharedCars <- sum(run1df$X.contacts.in.shared.cars)
    
    
    places <- c("homes", "workplaces", "schools", "universities", "essential shops", "non-essential shops", "hospital", "public leisure", "private leisure", "public transport", "queuing", "shared cars")
    
    amount <- c(homes, workplaces, schools, universities, essentialShops, nonEssentianShops, hospital, publicLeisure, privateLeisure, publicTransport, queuying, sharedCars)
    
    ratioAnxietyUsers <- toString(run1df[1,2])
    ratioAppUsers <- toString(run1df[1,3])
    
    
    
    u = ggplot(data.frame(amount), aes(x=places, amount)) +
      geom_bar(stat="identity", fill="steelblue") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
        caption = "ASSOCC"
      ) + coord_flip()
    print(u)
    
    Sys.sleep(1)
  }
  dev.off()
  
  
  
  
  
  #######################################################################################
  #################################Average contact per gathering point###################
  generalPurpose <- "Contacted by age group -\n"
  anxietyUsersTemplate <- "Ratio anxiety users"
  appUsersTemplate <- "+ Ratio app users"
  plot_list = list()
  plot_list2 = list()
  library(reshape2)
  ratioAnxietyUsers <- "1"
  rowNames <- c("young", "students", "workers", "retired")
  
  pdf("AverageContactPerGatheringPoint.pdf")
  
  RightsplittedByAppUsage  <- split(df, df$ratio.of.people.using.the.tracking.app, df$ratio.of.anxiety.avoidance.tracing.app.users)
  
  foreach(splittedByAppUsage = RightsplittedByAppUsage) %do% {
    homes <- sum(splittedByAppUsage$X.contacts.in.homes)
    workplaces <- sum(splittedByAppUsage$X.contacts.in.workplaces)
    schools <- sum(splittedByAppUsage$X.contacts.in.schools)
    universities <- sum(splittedByAppUsage$X.contacts.in.universities)
    essentialShops <- sum(splittedByAppUsage$X.contacts.in.essential.shops)
    nonEssentianShops <- sum(splittedByAppUsage$X.contacts.in.non.essential.shops)
    hospital <- sum(splittedByAppUsage$X.contacts.in.hospitals)
    publicLeisure <- sum(splittedByAppUsage$X.contacts.in.public.leisure)
    privateLeisure <- sum(splittedByAppUsage$X.contacts.in.private.leisure)
    publicTransport <- sum(splittedByAppUsage$X.contacts.in.pubtrans)
    queuying <- sum(splittedByAppUsage$X.contacts.in.queuing)
    sharedCars <- sum(splittedByAppUsage$X.contacts.in.shared.cars)
    
    
    factor <-length(unique(splittedByAppUsage$X.random.seed))
    
    averageHomes <- homes / factor
    averageWorkplaces <- workplaces / factor
    averageSchools <- schools / factor
    averageUniversities <- universities / factor
    averageEssentialShops <- essentialShops / factor
    averageNonEssentialShops <- nonEssentianShops / factor
    averageHospital <- hospital / factor
    averagePublicLeisure <- publicLeisure / factor
    averagePrivateLeisure <- privateLeisure / factor
    averagePublicTransport <- publicTransport / factor
    averageQueueing <- queuying / factor
    averageSharedCars <- sharedCars / factor
    
    
    places <- c("homes", "workplaces", "schools", "universities", "essential shops", "non-essential shops", "hospital", "public leisure", "private leisure", "public transport", "queuing", "shared cars")
    
    amount <- c(averageHomes, averageWorkplaces, averageSchools, averageUniversities, averageEssentialShops, averageNonEssentialShops, averageHospital, averagePublicLeisure, averagePrivateLeisure, averagePublicTransport, averageQueueing, averageSharedCars)
    
    u = ggplot(data.frame(amount), aes(x=places, amount)) +
      geom_bar(stat="identity", fill="steelblue") +   labs(
        title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, toString(splittedByAppUsage$ratio.of.people.using.the.tracking.app[1]), sep= " "),
        caption = "ASSOCC"
      ) + coord_flip()
    print(u)
    Sys.sleep(1)
    
  }
  dev.off()
  
  
  
  
  ########################################################################################
  
  ########################################################################################
  
  firstRound <-TRUE
  parametersString <- ""
  foreach(name = name_independent_variables_to_display) %do% 
    {
      
      number_occurrences <- length(table(df[[name]][1]))
      if(number_occurrences > 1)
        stop(paste("Wrong number of occurrences for",name))
      value_of_occurrence <- names(table(df[[name]][1]))[1]
      if(firstRound){firstRound = FALSE}
      else
        parametersString <- paste(parametersString,", ", sep = "")
      
      parametersString <- paste(parametersString,assocc_processing.get_display_name(name),
                                ": ", value_of_occurrence, sep = "")
    }
  
  #annotate_figure(figure,
  #           top = text_grob(parametersString, color = "red", face = "bold", size = 14),
  #        bottom = text_grob("Agent-based Social Simulation of Corona Crisis (ASSOCC)", color = "blue",
  #    hjust = 1, x = 1, face = "italic", size = 10)
  #)
}

assocc_processing.get_title <- function(
  x_var_name, y_var_name, name_independent_variables_to_display,
  df, cumulative
)
{
  ##number of times the experiment was repeated
  number_of_repetitions<-length(table(df$X.run.number.))
  
  firstRound <-TRUE
  parametersString <- ""
  name <- ""
  
  foreach(name = name_independent_variables_to_display) %do% 
    {
      number_occurrences <- length(table(df[[name]][1]))
      if(number_occurrences > 1)
        stop(paste("Wrong number of occurrences for",name))
      value_of_occurrence <- names(table(df[[name]][1]))[1]
      if(firstRound){firstRound = FALSE}
      else
        parametersString <- paste(parametersString,", ", sep = "")
      
      parametersString <- paste(parametersString,assocc_processing.get_display_name(name),
                                ": ", value_of_occurrence, sep = "")
      
    }
  start <-""
  if(cumulative)start <- "Cumulative "
  
  text <- paste(start, assocc_processing.get_display_name(y_var_name)," over ", 
                assocc_processing.get_display_name(x_var_name), " (",
                parametersString,", ",
                "N=",number_of_repetitions,
                ")"
                , sep ="")
  
  text
  
}


assocc_processing.get_title2 <- function(
  x_var_name, y_var_name, name_independent_variables_to_display,
  df
)
{
  ##number of times the experiment was repeated
  number_of_repetitions<-length(table(df$X.random.seed))
  
  
  labs(
    title = 
      paste(y_var_name, sep =""),
    colour = "variables",
    x=x_var_name, 
    y="ratio"
  )
}





assocc_processing.init_and_prepare_data <- function(workdirec)
{
  #args[1]
  
  # #then install packages (NOTE: this only needs to be done once for new users of RStudio!)
  #install.packages("ggplot2")
  #install.packages("plotly")
  #install.packages("tidyr")
  #install.packages("foreach")
  #install.packages("pracma")
  #install.packages("ggpubr")
  #install.packages("dplyr")
  #install.packages("sets")
  
   
  #then load relevant libraries
  library(ggplot2)
  library(plotly)
  library(tidyr)
  library(foreach)
  library(pracma)
  library(ggpubr)
  library(dplyr)
  library(reshape2)
  library(assertthat)
  #library(sets)
  
  ### MANUAL INPUT: specify and set working directory ###
  setwd(workdirec)
  # "C://Users//Maarten//Google Drive//Corona-Research//Program//RProgramming"
  functionFileLocation <- paste(workdirec,"behaviorspace_table_output_handling_functions.r", sep="")
  source(functionFileLocation)
  functionFileLocation <- paste(workdirec,"assocc_name.r", sep="")
  source(functionFileLocation)
  
  
  filesPath = workdirec
  #temp = list.files(pattern="*.csv")
  #myfiles = lapply(temp, read.delim)
  filesNames <- c("output.csv");
  
  # READ DATA ---------------------------------------------------------------
  
  df <- loadData(filesPath, filesNames)
  df$nb.days = df$X.step. / 4
  
  
  input_variable <- list(df$ratio.of.people.using.the.tracking.app,
                      df$X.random.seed,
                      df$is.tracking.app.testing.recursive.
                      )
  
  #########################################
  #THIS CODE SPLITS REMOVE FORBIDDEN VALUES AND UNSPIT BUT THE UNSPIT CAUSES SOME WRONG INDEXING,
  #WHICH JAMS THE REST AFTERWARDS
  #########################################
  # tmp_df <- split(df, input_variable)
  # 
  # for (i in length(tmp_df):1) {
  #   if(NROW(tmp_df[[i]]) == 0)tmp_df <- tmp_df[-i]
  # }
  # 
  # ######################################## safety check # of infected at tick 400
  # for (i in length(tmp_df):1) {
  #   current_df <- tmp_df[[i]]
  #   line <- current_df[current_df$X.step.==400,]
  #   if(line$X.infected == 0)
  #   {
  #     print(paste("removing run", line$ratio.of.people.using.the.tracking.app, line$X.random.seed, "due to no more infected at tick 400"))
  #     tmp_df <- tmp_df[-i]
  #   }    
  # }
  # 
  # tmp_df <- do.call(rbind.data.frame, tmp_df)
  # df <- tmp_df
  # 
  # df2 = unlist(tmp_df,input_variable)
  
  #########################################
  
  # REMOVE IRRELEVANT VARIABLES ---------------------------------------------------------------
  
  #Loop through dataframe and identify variables that do NOT vary (i.e. that are FIXED)
  #Unfixed variables are either independent or dependent and therefore relevant to include in the analysis
  #df <- removeVariables(df)
  #it did break some cases where some variable always remain set to 0
  
  # RENAME VARIABLES ---------------------------------------------------------------
  #printColumnNames(df)
  
  ### MANUAL INPUT: specify new (easy-to-work-with) variable names ###
  df
  
  # TRANSFORM DATAFRAME -----------------------------------------------------
  ##Seems to work without... Weird! I believe this is to be atuned for specific plots rather
  ##than making it needed to go through
  
  #transform wide dataframe into long format dataframe (in order to make it ggplot compatible)
  ### MANUAL INPUT: make sure that you specify which variables are to be considered as metrics (i.e. dependent variables)
  #As can be seen in clean_df, the dependent variables are (by default) called "infected", "aware_of_infected" and "tests_performed" ...
  #...therefore the dataframe transformation revolves around pivoting infected:tests_performed 
  #df_long <- gather(clean_df, variable, measurement, infected:tests_performed)
  
  # SPECIFY VARIABLE MEASUREMENT SCALES -----------------------------------------------------
  ### MANUAL INPUT: in order for ggplot and plotly to work, one must specify the following: ###
  #-> continuous decimal (floating) variables as 'numeric'
  #-> continuous integer variables as 'integer'
  #-> discrete (or categorical) variables as 'factor'
  
  #print an overview of variables and their measurement scales
  #str(df_long)
  #transform 'measurement' variable to numeric (as to avoid ggplot errors)
  #df_long$measurement <- as.numeric(df_long$measurement)
  #round 'measurement' variable to 4 decimals
  #df_long$measurement <- round(df_long$measurement, 4)
  #convert categorical variables to factors (as to avoid ggplot errors)
  #df_long$run_number <- as.factor(df_long$run_number)
  #df_long$app_user_ratio <- as.factor(df_long$app_user_ratio)
  #df_long$variable <- as.factor(df_long$variable)
  #perform some small checks to see whether everything is OK
  #str(df_long)
  
}

