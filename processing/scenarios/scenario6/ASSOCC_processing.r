assocc_processing.plot <- function(xDataName,
                                   yDataName,
                                   linesVarName,
                                   input_variables_to_display,
                                   local_df,
                                   with_shadows = FALSE
) 
{
  #local_df <- factor(local_df, xDataName)
  #level_order <- factor(local_df[[xDataName]])
  
  #here it should mention explicitly the kind of factoring, I guess...
  
  
  vars_to_remember <- c(xDataName, yDataName, linesVarName, "X.run.number.")
  a <- local_df[c(xDataName, yDataName,"X.run.number.")]
  number_occurrences <- length(table(local_df$X.run.number.))
#  local_df[[linesVarName]] <- as.factor(local_df[[linesVarName]])
  
  foreach(id = linesVarName)%do%
    {
      a$grp <- paste(a$grp,local_df[,id])
    }
  local_df <- a
  xData = local_df[[xDataName]]
  yData = local_df[[yDataName]]
  
  
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
  linesData <- local_df$grp
  

  title_string <- paste(assocc_processing.get_display_name(yDataName)," depending on  ", assocc_processing.get_display_name(linesVarName), " (",
        parametersString, sep="")
  if(!firstRound) if(! firstRound)paste(title_string,",", sep="")
  title_string <- paste(title_string,"N=",number_occurrences,")", sep ="")

  local_df <- arrange(local_df, nb.days)
  
  p <- 
  ggplot(data=local_df, aes(x=!!sym(xDataName), y=!!sym(yDataName),
                            group = X.run.number., colour=grp))
  if(with_shadows)
  {
    p<- p + geom_line(alpha = 0.2)
  }
  p <- p + 
    stat_summary(size = 1,
                      fun=mean, 
                      geom="line",group=1)+
    xlab(xDataName) +
    ylab(assocc_processing.get_display_name(yDataName)) + 
    labs(title=title_string,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         colours = assocc_processing.get_display_name(linesVarName))
}


assocc_processing.plotCompareAlongDifferentY <- function(x_var_name,
                                                         y_display_var_name,
                                                         list_of_y_variables_to_compare,
                                                         name_independent_variables_to_display,
                                                         local_df,
                                                         cumulative=FALSE,
                                                         with_shadows = FALSE) 
{
  if(cumulative)
  {
    list_of_point_identifier <- c("X.run.number.", "X.step.",  "X.random.seed")
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
          arrange(!!sym("X.step.")) %>% 
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
  val_x <- sym(x_var_name) 
  
  p <- ggplot(local_df, aes(group = X.random.seed))
  
  position <- "identity"
  
  if(length(list_of_y_variables_to_compare) >= 1)
  {
    if(position != "stack" && with_shadows)
      p<-p +  geom_line(
        #position = "stack",
        alpha = 0.2,aes(x=!!val_x, 
                            y=!!sym(list_of_y_variables_to_compare[1]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[1])))  
    
    #for a cleaner alternative way, see: https://drsimonj.svbtle.com/plotting-individual-observations-and-group-means-with-ggplot2
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[1]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[1])),
                     fun=mean, 
                   #position = "stack",
                     geom="line",group=1)
    
    
    } 
  if(length(list_of_y_variables_to_compare) >= 2)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,
      aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[2]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[2])))
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[2]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[2])),
      fun=mean, 
      #position = position,
      geom="line",group=1)
  }
  if(length(list_of_y_variables_to_compare) >= 3)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[3]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3]))) 
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[3]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[3])),
      fun=mean, 
      geom="line",group=1)
    
    }
  if(length(list_of_y_variables_to_compare) >= 4)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[4]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])))
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[4]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[4])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 5)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[5]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])))  
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[5]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[5])),
      fun=mean, 
      geom="line",group=1)
    
    }
  if(length(list_of_y_variables_to_compare) >= 6)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[6]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])))  
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[6]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[6])),
      fun=mean, 
      geom="line",group=1)
    
    }
  if(length(list_of_y_variables_to_compare) >= 7)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[7]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])))
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[7]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[7])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 8)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[8]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])))
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[8]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[8])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 9)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[9]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9]))) 
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[9]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[9])),
      fun=mean, 
      geom="line",group=1)
    
    }
  if(length(list_of_y_variables_to_compare) >= 10)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[10]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])))
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[10]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[10])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 11)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[11]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])))
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[11]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[11])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 12)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[12]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[12])))
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[12]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[12])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 13)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[13]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[13]))) 
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[13]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[13])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 14)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[14]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[14]))) 
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[14]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[14])),
      fun=mean, 
      geom="line",group=1)
    }
  if(length(list_of_y_variables_to_compare) >= 15)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[15]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[15]))) 
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[15]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[15])),
      fun=mean, 
      geom="line",group=1)
    
    }
  if(length(list_of_y_variables_to_compare) >= 16)
  {
    if(position != "stack" && with_shadows)
    p<-p +  geom_line(
      alpha = 0.2,aes(x=!!val_x,
                            y=!!sym(list_of_y_variables_to_compare[16]),
                            colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[16]))) 
    
    p<-p + stat_summary(size = 1,
      aes(x=!!val_x, 
          y=!!sym(list_of_y_variables_to_compare[16]),
          colour=assocc_processing.get_display_name(list_of_y_variables_to_compare[16])),
      fun=mean, 
      geom="line",group=1)
    
    }
   if(length(list_of_y_variables_to_compare) >= 17)
  {stop(paste("Not defined for more than",length(list_of_y_variables_to_compare), "lines"))}
  
  p<-p+assocc_processing.get_title(x_var_name, y_display_var_name, name_independent_variables_to_display,
                                   df = local_df, cumulative)
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
      table_of_occurrences_of_name <- table(unlist(df[[name]]))
      if(size(table_of_occurrences_of_name) > 1)
        table_of_occurrences_of_name <- table(droplevels(unlist(df[[name]])))
      
      number_of_different_occurrences_of_name <- size(table_of_occurrences_of_name)
      if(number_of_different_occurrences_of_name > 1)
        stop(paste("Wrong number of occurrences for",name), names(table_of_occurrences_of_name))
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
  
  colours_name <- assocc_processing.get_display_name(a = name)
  
  labs(
    title =  text
    ,
    caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
    colours = colours_name,
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
  
  tmp_df <- split(df, input_variable)
  
  for (i in length(tmp_df):1) {
    if(NROW(tmp_df[[i]]) == 0)tmp_df <- tmp_df[-i]
  }
  
  ######################################## safety check # of infected at tick 400
  for (i in length(tmp_df):1) {
    current_df <- tmp_df[[i]]
    line <- current_df[current_df$X.step.==400,]
    if(line$X.infected == 0)
    {
      print(paste("removing run", line$ratio.of.people.using.the.tracking.app, line$X.random.seed, "due to no more infected at tick 400"))
      tmp_df <- tmp_df[-i]
    }
  }
  
  tmp_df
  
#  tmp_df <- do.call(rbind.data.frame, tmp_df)
#  df <- tmp_df
#   df
}

