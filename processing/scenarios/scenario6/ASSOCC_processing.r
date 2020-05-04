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
                                                         df) 
{
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
                                   df)
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
}

assocc_processing.get_title <- function(
  x_var_name, y_var_name, name_independent_variables_to_display,
  df
  )
{
  ##number of times the experiment was repeated
  number_of_repetitions<-length(table(df$X.random.seed))
  
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
  
  labs(
  title = 
    paste(y_var_name," over ", x_var_name, " (",
                   parametersString,", ",
                   "N=",number_of_repetitions,
                   ")"
                   , sep =""),
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
  else if(strcmp(a,"app_user_ratio"))
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
  else if(strcmp(a,"X.young.infected") )
      "#young infected"
  else if(strcmp(a,"X.young.infector") )
    "#young infector"
  else if(strcmp(a,"X.student.infected") )
    "#student infected"
  else if(strcmp(a,"X.student.infector") )
    "#student infector"
  else if(strcmp(a,"X.retired.infected") )
    "#retired infected"
  else if(strcmp(a,"X.retired.infector"))
    "#retired infector"
  else if(strcmp(a,"X.worker.infected") )
    "#worker infected"
  else if(strcmp(a,"X.worker.infector"))
    "#worker infector" 
  else if(strcmp(a,"infected"))
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
  else 
    stop(paste("No name defined for:",a))
}


