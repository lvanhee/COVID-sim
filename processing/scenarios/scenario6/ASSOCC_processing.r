assocc_processing.plot <- function(xDataName,
                                   yDataName,
                                   linesVarName,
                                   input_variables_to_display,
                                   local_df
                                   ) 
{
  local_df[[linesVarName]] <- as.factor(local_df[[linesVarName]])
  
  xData = local_df[[xDataName]]
  yData = local_df[[yDataName]]
  
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
      
      parametersString <- paste(parametersString,assocc_processing.get_display_name(name),
                                ", ", value_of_occurrence, sep = "")
    }
   linesData <- local_df[[linesVarName]]
  p <- ggplot(data=local_df, aes(x=xData, y=yData, fill=linesData))
  p + 
    geom_smooth(aes(colour=linesData, linetype=linesData),
                method="loess",size=1.5,se=TRUE, fullrange=FALSE, level=0.95,  span = 0.1)+
    xlab(xDataName) +
    ylab(assocc_processing.get_display_name(yDataName)) + 
    labs(title=paste(assocc_processing.get_display_name(yDataName)," depending on  ", assocc_processing.get_display_name(linesVarName), " (",
                     parametersString,", ",
                     "N=",number_of_repetitions,
                     ")"
                     , sep =""),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         colours = assocc_processing.get_display_name(linesVarName))
}


assocc_processing.plotCompareAlongDifferentY <- function(x_var_name,
                                                         y_var_name,
                                                         list_of_y_variables_to_compare,
                                                         name_independent_variables_to_display,
                                                         df,
                                                         cumulative=FALSE) 
{
  if(cumulative)
  {
    list_of_variables_to_save <- c("X.run.number.", "X.step.", list_of_y_variables_to_compare)
    list_of_all_variables_to_remember <- c(list_of_variables_to_save, name_independent_variables_to_display)
    df_tmp <- df[list_of_variables_to_save]
    df_res <- df[list_of_all_variables_to_remember]
    foreach(name = list_of_y_variables_to_compare) %do% 
      {
        var_name = sym(name)
        
        df_tmp <- 
          df_tmp %>% 
          group_by(!!sym("X.run.number.")) %>% 
          arrange(!!sym("X.step.")) %>% 
          mutate(cs = cumsum(!!sym(name))
          )
        df_res[[name]] <- df_tmp$cs
      }
    #df <- df_tmp[ , -which(names(df_tmp) %in% list_of_y_variables_to_compare)]
    df <- df_res
  }
  val_x <- sym(x_var_name) 
  
  p <- ggplot(df)
  
  if(length(list_of_y_variables_to_compare) >= 1)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[1]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))  }
  if(length(list_of_y_variables_to_compare) >= 2)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[2]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
  }
  if(length(list_of_y_variables_to_compare) >= 3)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[3]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3])))  }
  if(length(list_of_y_variables_to_compare) >= 4)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[4]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))  }
  if(length(list_of_y_variables_to_compare) >= 5)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[5]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))  }
  if(length(list_of_y_variables_to_compare) >= 6)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[6]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))  }
  if(length(list_of_y_variables_to_compare) >= 7)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[7]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))  }
  if(length(list_of_y_variables_to_compare) >= 5)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[8]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))  }
  if(length(list_of_y_variables_to_compare) >= 9)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[9]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9])))  }
  if(length(list_of_y_variables_to_compare) >= 9)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[9]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9])))  }
  if(length(list_of_y_variables_to_compare) >= 10)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[10]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))  }
  if(length(list_of_y_variables_to_compare) >= 11)
  {
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[11]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))  }
  if(length(list_of_y_variables_to_compare) >= 12)
  {stop("Not defined for more than 9 lines:")}
  
  p<-p+assocc_processing.get_title(x_var_name, y_var_name, name_independent_variables_to_display,
                                   df, cumulative)
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
    p <- ggplot(df)
    p<-p +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[1]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))  }
  if(length(list_of_y_variables_to_compare) >= 2)
  {
    p1 <- ggplot(df)
    p1<-p1 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[2]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
  }
  if(length(list_of_y_variables_to_compare) >= 3)
  {
    p2 <- ggplot(df)
    p2<-p2 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[3]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3])))  }
  if(length(list_of_y_variables_to_compare) >= 4)
  {
    p3 <- ggplot(df)
    p3<-p3 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[4]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))  }
  if(length(list_of_y_variables_to_compare) >= 5)
  {
    p4 <- ggplot(df)
    p4<-p4 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[5]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))  }
  if(length(list_of_y_variables_to_compare) >= 6)
  {
    p5 <- ggplot(df)
    p5<-p5 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[6]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))  }
  if(length(list_of_y_variables_to_compare) >= 7)
  {
    p6 <- ggplot(df)
    p6<-p6 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[7]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))  }
  if(length(list_of_y_variables_to_compare) >= 8)
  {
    p7 <- ggplot(df)
    p7<-p7 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[8]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))  }
  if(length(list_of_y_variables_to_compare) >= 9)
  {
    p8 <- ggplot(df)
    p8<-p8 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[9]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9])))  }
  if(length(list_of_y_variables_to_compare) >= 10)
  {
    p9 <- ggplot(df)
    p9<-p9 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[10]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))  }
  if(length(list_of_y_variables_to_compare) >= 11)
  {
    p10 <- ggplot(df)
    p10<-p10 +  geom_smooth(aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[11]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))  }
  if(length(list_of_y_variables_to_compare) >= 12)
  {
    p11 <- ggplot(df)
    p11<-p11 +  geom_smooth(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[12]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[12])))  }
  if(length(list_of_y_variables_to_compare) >= 13)
  {
    p12 <- ggplot(df)
    p12<-p12 +  geom_smooth(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[13]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[13])))  }
  if(length(list_of_y_variables_to_compare) >= 14)
  {
    p13 <- ggplot(df)
    p13<-p13 +  geom_smooth(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[14]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[14])))  }
  if(length(list_of_y_variables_to_compare) >= 15)
  {
    p14 <- ggplot(df)
    p14<-p14 +  geom_smooth(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[15]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[15])))  }
  if(length(list_of_y_variables_to_compare) >= 16)
  {
    p15 <- ggplot(df)
    p15<-p15 +  geom_smooth(aes(x=!!val_x,
                              y=!!sym(list_of_y_variables_to_compare[16]),
                              colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[16])))  }
  if(length(list_of_y_variables_to_compare) >= 17)
  {stop("Not defined for more than 16 lines:")}
  
  p<-p+assocc_processing.get_title2(x_var_name, "young infected by young", c(),
                                   df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p1<-p1+assocc_processing.get_title2(x_var_name, "young infected by workers", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p2<-p2+assocc_processing.get_title2(x_var_name, "young infected by students", c(),
                                   df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p3<-p3+assocc_processing.get_title2(x_var_name, "young infected by retireds", c(),
                                     df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p4<-p4+assocc_processing.get_title2(x_var_name, "workers infected by young", c(),
                                     df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p5<-p5+assocc_processing.get_title2(x_var_name, "workers infected by workers", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p6<-p6+assocc_processing.get_title2(x_var_name, "workers infected by students", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p7<-p7+assocc_processing.get_title2(x_var_name, "workers infected by retireds", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
 
  p8<-p8+assocc_processing.get_title2(x_var_name, "students infected by young", c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p9<-p9+assocc_processing.get_title2(x_var_name, "students infected by workers", c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p10<-p10+assocc_processing.get_title2(x_var_name, "students infected by students", c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p11<-p11+assocc_processing.get_title2(x_var_name, "students infected by retireds", c(),
                                        df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  
   p12<-p12+assocc_processing.get_title2(x_var_name, "retireds infected by young", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p13<-p13+assocc_processing.get_title2(x_var_name, "retireds infected by workers", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p14<-p14+assocc_processing.get_title2(x_var_name, "retireds infected by students", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
  p15<-p15+assocc_processing.get_title2(x_var_name, "retireds infected by retireds", c(),
                                      df)+ theme(plot.title = element_text(size = 8), legend.position = "none") +  ylim(0, 2)
 
  figure <- ggarrange(p, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, ncol = 4, nrow = 4)
  
  
}

#Stacked bar plot#####################################################################
loop.vector <- c(1:9)
generalPurpose <- "Infected by age group -"
anxietyUsersTemplate <- "Ratio anxiety users" 
appUsersTemplate <- "+ Ratio app users"
plot_list = list()
plot_list2 = list()


#i <- 1
for (i in loop.vector){
  run1df <- subset(df, df$X.run.number. == 9)
  young <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.young.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.young.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.young.age.retired.age))
  students <- c(sum (run1df$ratio.age.group.to.age.group..infections.student.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.retired.age))
  workers <- c(sum (run1df$ratio.age.group.to.age.group..infections.worker.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.retired.age))
  retired <- c(sum (run1df$ratio.age.group.to.age.group..infections.retired.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.retired.age))
  rowNames <- c("young", "students", "workers", "retired")
  
  ratioAnxietyUsers <- toString(run1df[1,2])
  ratioAppUsers <- toString(run1df[1,3])
  
  toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
  
  toPlotdf$age <-rowNames
  
  library(reshape2)
  toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
  names(toPlotdfLong)[2] <-paste("age_group") 
  
  p = ggplot(toPlotdfLong, aes( y=proportion, x=age_group, fill = age)) + 
    geom_bar(position="stack", stat="identity") +   labs(
      title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
      subtitle = "Calculation students infected by young: ratio.age.group.to.age.group..infections.student.age.young.age",
      caption = "ASSOCC"
    )
  plot_list[[9]] = p
    #ggtitle("Infected by age group - Ratio anxiety users 1 + Ratio app users 0.6") +
    #theme(plot.title = element_text(hjust = 0.5))
    
  #i = i+1
  #pdf(file='plot.pdf')
}
pdf("plots.pdf")
for (i in loop.vector) {
  print(plot_list[[i]])
}
dev.off()

for (j in loop.vector){
  run1df <- subset(df, X.run.number. == 9)
  young <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.young.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.young.age))
  students <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.student.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.student.age))
  workers <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.worker.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.worker.age))
  retired <- c(sum (run1df$ratio.age.group.to.age.group..infections.young.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.student.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.worker.age.retired.age), sum (run1df$ratio.age.group.to.age.group..infections.retired.age.retired.age))
  rowNames <- c("young", "students", "workers", "retired")
  
  ratioAnxietyUsers <- toString(run1df[1,2])
  ratioAppUsers <- toString(run1df[1,3])
  
  toPlotdf <- data.frame(young, students, workers, retired, row.names = rowNames)
  
  toPlotdf$age <-rowNames
  
  library(reshape2)
  toPlotdfLong <- melt(toPlotdf, id.vars =c("age"), value.name = "proportion")
  names(toPlotdfLong)[2] <-paste("age_group") 
  
  q = ggplot(toPlotdfLong, aes( y=proportion, x=age_group, fill = age)) + 
    geom_bar(position="stack", stat="identity") +   labs(
      title = paste(generalPurpose, anxietyUsersTemplate, ratioAnxietyUsers, appUsersTemplate, ratioAppUsers, sep= " "),
      subtitle = "Calculation students infected by young: ratio.age.group.to.age.group..infections.young.age.student.age",
      caption = "ASSOCC"
    )
  plot_list2[[9]] = q
}

pdf("plotsYoungStudent.pdf")
for (j in loop.vector) {
  print(plot_list2[[j]])
}
dev.off()







#######################################################################################
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

annotate_figure(figure,
                top = text_grob(parametersString, color = "red", face = "bold", size = 14),
                bottom = text_grob("Agent-based Social Simulation of Corona Crisis (ASSOCC)", color = "blue",
                                   hjust = 1, x = 1, face = "italic", size = 10)
)
assocc_processing.get_title <- function(
  x_var_name, y_var_name, name_independent_variables_to_display,
  df, cumulative
  )
{
  ##number of times the experiment was repeated
  number_of_repetitions<-length(table(df$X.run.number.))
 
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
  start <-""
  if(cumulative)start <- "Cumulative "
  
  text <- paste(start, assocc_processing.get_display_name(y_var_name)," over ", 
                assocc_processing.get_display_name(x_var_name), " (",
                parametersString,", ",
                "N=",number_of_repetitions,
                ")"
                , sep ="")
  text
  labs(
  title =  text
    ,
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
       colours = assocc_processing.get_display_name(name),
       colour = "variables",
       x=x_var_name, 
       y=y_var_name
       )
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



assocc_processing.get_display_name <- function(a)
{

  if(strcmp(a,"ratio.of.anxiety.avoidance.tracing.app.users"))
    "Anx.Avoid.App"
  else if(strcmp(a,"app_user_ratio")||strcmp(a,"ratio.of.people.using.the.tracking.app"))
    "ratio app-users"
  else if(strcmp(a,"X.people.infected.in.essential.shops"))
    "#infected ess-shops"
  else if(strcmp(a,"X.people.infected.in.non.essential.shops"))
    "#infected n.ess-shops"
  else if(strcmp(a,"X.people.infected.in.homes"))
    "#infected homes"
  else if(strcmp(a,"X.people.infected.in.public.leisure"))
    "#infected public leisure"
  else if(strcmp(a,"X.people.infected.in.private.leisure"))
    "#infected private leisure"
  else if(strcmp(a,"X.people.infected.in.schools"))
    "#infected schools"
  else if(strcmp(a,"X.people.infected.in.universities"))
    "#infected universities"
  else if(strcmp(a,"people.infected.in.hospitals") ||strcmp(a,"X.people.infected.in.hospitals"))
    "#infected hospitals"
  else if(strcmp(a,"X.contacts.in.essential.shops"))
    "#contacts ess-shops"
  else if(strcmp(a,"X.contacts.in.non.essential.shops"))
    "#contacts n.ess-shops"
  else if(strcmp(a,"X.contacts.in.homes"))
    "#contacts homes"
  else if(strcmp(a,"X.contacts.in.public.leisure"))
    "#contacts public leisure"
  else if(strcmp(a,"X.contacts.in.private.leisure"))
    "#contacts private leisure"
  else if(strcmp(a,"X.contacts.in.pubtrans"))
    "#contacts public transport"
  else if(strcmp(a,"X.contacts.in.shared.cars"))
    "#contacts shared cars"
  else if(strcmp(a,"X.contacts.in.queuing"))
    "#contacts queuing"
  else if(strcmp(a,"X.contacts.in.schools"))
    "#contacts schools"
  else if(strcmp(a,"X.contacts.in.universities"))
    "#contacts universities"
  else if(strcmp(a,"contacts.in.hospitals") ||strcmp(a,"X.contacts.in.hospitals"))
    "#contacts hospitals"
  else if(strcmp(a,"X.young.infected")||strcmp(a,"X.cumulative.youngs.infected") )
      "#young infected"
  else if(strcmp(a,"X.young.infector")||strcmp(a,"X.cumulative.youngs.infector"))
    "#young infector"
  else if(strcmp(a,"X.student.infected")||strcmp(a,"X.cumulative.students.infected") )
    "#student infected"
  else if(strcmp(a,"X.student.infector")||strcmp(a,"X.cumulative.students.infector") )
    "#student infector"
  else if(strcmp(a,"X.retired.infected")||strcmp(a,"X.cumulative.retireds.infected") )
    "#retired infected"
  else if(strcmp(a,"X.retired.infector")||strcmp(a,"X.cumulative.retireds.infector"))
    "#retired infector"
  else if(strcmp(a,"X.worker.infected")||strcmp(a,"X.cumulative.workers.infected") )
    "#worker infected"
  else if(strcmp(a,"X.worker.infector")||strcmp(a,"X.cumulative.workers.infector"))
    "#worker infector" 
  else if(strcmp(a,"infected") || strcmp(a,"X.infected"))
    "#infected" 
  else if(strcmp(a,"ratio.quarantiners.currently.complying.to.quarantine"))
      "ratio compliant quarantiners"
  else if(strcmp(a,"X.hospitalizations.retired.this.tick"))
    "newly hospitalized retired" 
  else if(strcmp(a,"X.hospitalizations.students.this.tick"))
    "newly hospitalized students" 
  else if(strcmp(a,"X.hospitalizations.workers.this.tick"))
    "newly hospitalized workers" 
  else if(strcmp(a,"X.hospitalizations.youngs.this.tick"))
    "newly hospitalized youngs" 
  else if(strcmp(a,"X.step."))
    "ticks"
  else if(strcmp(a,"X.newly.retired.infected"))
    "newly infected retired" 
  else if(strcmp(a,"X.newly.students.infected"))
    "newly infected students" 
  else if(strcmp(a,"X.newly.workers.infected"))
    "newly infected workers" 
  else if(strcmp(a,"X.newly.youngs.infected"))
    "newly infected youngs" 
  else if(strcmp(a,"X.cumulative.retireds.infected"))
    "cumulative infected retireds" 
  else if(strcmp(a,"X.cumulative.students.infected"))
    "cumulative infected students" 
  else if(strcmp(a,"X.cumulative.workers.infected"))
    "cumulative infected workers" 
  else if(strcmp(a,"X.cumulative.youngs.infected"))
    "cumulative infected youngs"
  else if(strcmp(a,"X.cumu.hospitalisations.workers"))
    "cumulative hospitalisations workers" 
  else if(strcmp(a,"X.cumu.hospitalisations.youngs"))
    "cumulative hospitalisations youngs" 
  else if(strcmp(a,"X.cumu.hospitalisations.retired"))
    "cumulative hospitalisations retired" 
  else if(strcmp(a,"X.cumu.hospitalisations.students"))
    "cumulative hospitalisations students" 
  else if(strcmp(a,"ratio.young.contaminated.by.young"))
    "by young" 
  else if(strcmp(a,"ratio.young.contaminated.by.workers"))
    "by workers" 
  else if(strcmp(a,"ratio.young.contaminated.by.students"))
    "by students" 
  else if(strcmp(a,"ratio.young.contaminated.by.retireds"))
    "by retireds" 
  else if(strcmp(a,"X.contacts.last.tick"))
      "contacts per tick"
  else if(strcmp(a,"ratio.workers.contaminated.by.young"))
    "by young" 
  else if(strcmp(a,"ratio.workers.contaminated.by.workers"))
    "by workers" 
  else if(strcmp(a,"ratio.workers.contaminated.by.students"))
    "by students" 
  else if(strcmp(a,"ratio.workers.contaminated.by.retireds"))
    "by retireds" 
  else if(strcmp(a,"ratio.retireds.contaminated.by.young"))
    "by young" 
  else if(strcmp(a,"ratio.retireds.contaminated.by.workers"))
    "by workers" 
  else if(strcmp(a,"ratio.retireds.contaminated.by.students"))
    "by students" 
  else if(strcmp(a,"ratio.retireds.contaminated.by.retireds"))
    "by retireds" 
  else if(strcmp(a,"ratio.students.contaminated.by.young"))
    "by young" 
  else if(strcmp(a,"ratio.students.contaminated.by.workers"))
    "by workers" 
  else if(strcmp(a,"ratio.students.contaminated.by.students"))
    "by students" 
  else if(strcmp(a,"ratio.students.contaminated.by.retireds"))
    "by retireds" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.young.age.young.age"))
    "y -> y" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.student.age.young.age"))
    "s->y" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.worker.age.young.age"))
    "w->y" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.retired.age.young.age"))
    "r->y" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.young.age.student.age"))
    "y->s" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.student.age.student.age"))
    "s->s" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.worker.age.student.age"))
    "w->s" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.retired.age.student.age"))
    "r->s" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.young.age.worker.age"))
    "y->w" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.student.age.worker.age"))
    "s->w" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.worker.age.worker.age"))
    "w->w" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.retired.age.worker.age"))
    "r->w" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.young.age.retired.age"))
    "y->r" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.student.age.retired.age"))
    "s->r" 
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.worker.age.retired.age"))
    "w->r"   
  else if(strcmp(a,"ratio.age.group.to.age.group..infections.retired.age.retired.age"))
    "r->r" 

  
  else if(strcmp(a,"age.group.to.age.group..contacts.young.age.young.age"))
    "y -> y" 
  else if(strcmp(a,"age.group.to.age.group..contacts.student.age.young.age"))
    "s->y" 
  else if(strcmp(a,"age.group.to.age.group..contacts.worker.age.young.age"))
    "w->y" 
  else if(strcmp(a,"age.group.to.age.group..contacts.retired.age.young.age"))
    "r->y" 
  else if(strcmp(a,"age.group.to.age.group..contacts.young.age.student.age"))
    "y->s" 
  else if(strcmp(a,"age.group.to.age.group..contacts.student.age.student.age"))
    "s->s" 
  else if(strcmp(a,"age.group.to.age.group..contacts.worker.age.student.age"))
    "w->s" 
  else if(strcmp(a,"age.group.to.age.group..contacts.retired.age.student.age"))
    "r->s" 
  else if(strcmp(a,"age.group.to.age.group..contacts.young.age.worker.age"))
    "y->w" 
  else if(strcmp(a,"age.group.to.age.group..contacts.student.age.worker.age"))
    "s->w" 
  else if(strcmp(a,"age.group.to.age.group..contacts.worker.age.worker.age"))
    "w->w" 
  else if(strcmp(a,"age.group.to.age.group..contacts.retired.age.worker.age"))
    "r->w" 
  else if(strcmp(a,"age.group.to.age.group..contacts.young.age.retired.age"))
    "y->r" 
  else if(strcmp(a,"age.group.to.age.group..contacts.student.age.retired.age"))
    "s->r" 
  else if(strcmp(a,"age.group.to.age.group..contacts.worker.age.retired.age"))
    "w->r"   
  else if(strcmp(a,"age.group.to.age.group..contacts.retired.age.retired.age"))
    "r->r"   
  else 
    stop(paste("No name defined for:",a))
}

assocc_processing.init_and_prepare_data <- function(path)
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
  
  #then load relevant libraries
  library(ggplot2)
  library(plotly)
  library(tidyr)
  library(foreach)
  library(pracma)
  library(ggpubr)
  library(dplyr)
  getwd()
  
  ### MANUAL INPUT: specify and set working directory ###
  setwd(workdirec)
  # "C://Users//Maarten//Google Drive//Corona-Research//Program//RProgramming"
  functionFileLocation <- paste(workdirec,"behaviorspace_table_output_handling_functions.r", sep="")
  source(functionFileLocation)

  filesPath = workdirec
  #temp = list.files(pattern="*.csv")
  #myfiles = lapply(temp, read.delim)
  filesNames <- c("output.csv");
  
  # READ DATA ---------------------------------------------------------------
  
  df <- loadData(filesPath, filesNames)
  
  
  
  # REMOVE INVALID RUNS ---------------------------------------------------------------
  #runs that have a lower amount of maximum infected are seen as invalid and are therefore removed
  #specify the minimum number of infected people for a run to be considered as valid (5 person by default)
  # the next will fail if the number of infected is not in the data as -> count.people.with..is.infected..
  df <- cleanData(df, 1)
  # REMOVE IRRELEVANT VARIABLES ---------------------------------------------------------------
  
  #Loop through dataframe and identify variables that do NOT vary (i.e. that are FIXED)
  #Unfixed variables are either independent or dependent and therefore relevant to include in the analysis
  #df <- removeVariables(df)
  #it did break some cases where some variable always remain set to 0
  
  # RENAME VARIABLES ---------------------------------------------------------------
  #printColumnNames(df)
  
  ### MANUAL INPUT: specify new (easy-to-work-with) variable names ###
  new_variable_names <- list(
    
  )
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

