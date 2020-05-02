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
    ylab(yDataName) + 
    labs(title=paste(yDataName," depending on  ", assocc_processing.get_display_name(linesVarName), " (",
                     parametersString,", ",
                     "N=",number_of_repetitions,
                     ")"
                     , sep =""),
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         colours = assocc_processing.get_display_name(linesVarName))
}


assocc_processing.get_display_name <- function(a)
{
  if(strcmp(a,"ratio.of.anxiety.avoidance.tracing.app.users"))
    "Anx.Avoid.App"
  else if(strcmp(a,"app_user_ratio"))
      "ratio app-users"
  else
    stop(paste("No name defined forr:",a))
}


