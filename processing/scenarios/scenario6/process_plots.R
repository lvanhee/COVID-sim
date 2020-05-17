#Made by Maarten Jensen (Ume? University) & Kurt Kreulen (TU Delft) for ASSOCC

#first empty working memory
rm(list=ls())
#MANUAL INPUT (if not working from a script)
#args <- commandArgs(trailingOnly=TRUE)
args <- commandArgs(trailingOnly=TRUE)
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
args <- "C:/Users/loisv/git/COVID-sim/processing/scenarios/scenario6"
#args <- "/Users/christiankammler/Documents/R/COVID-sim/processing/scenarios/scenario6"
#args <-"D:/absoluteNewCVOID/COVID-sim/processing/scenarios/scenario6"
if (length(args)==0) {
  stop("At least one argument must be supplied (working directory).n", call.=FALSE)
}
workdirec <- args

if(substr(workdirec, nchar(workdirec)-1+1, nchar(workdirec)) != '/')
  workdirec <- paste(workdirec,"/", sep="")

source(paste(workdirec,"ASSOCC_processing.r", sep=""))

df<-assocc_processing.init_and_prepare_data(workdirec)
splitted_by_ratio_anxiety_df <- split(df, df$ratio.of.anxiety.avoidance.tracing.app.users)
splitted_by_app_user_ratio_df <- split(df, df$ratio.of.people.using.the.tracking.app)
splitted_by_ratio_anxiety_and_ratio_users_df <- split(df, list(df$ratio.of.anxiety.avoidance.tracing.app.users, df$ratio.of.people.using.the.tracking.app))



# PLOTTING -----------------------------------------------------

assocc_processing.plot_stacked_bar_chart(df)


export_pdf = TRUE;
if (export_pdf) {
  pdf(file="Combined plots.pdf", width=9, height=6);
}

last_tick <- max(df$X.step.)


###Number of infector per infected per age group

foreach(r = splitted_by_app_user_ratio_df) %do%
  {
    local_df <- r
    get_variable_name_crossing_x_y <- function (x_name,y_name)
    {
      paste("ratio.age.group.to.age.group..infections.",x_name,".age.",y_name,".age", sep="")
    }
    
    print(assocc_processing.plot_stacked_bar_chart2(
      df=local_df,
      values = c("young", "student", "worker", "retired"),
      x_output_name="infectee",
      y_output_name="ratio",
      linesVarName= "infector",
      get_variable_name_crossing_x_y= get_variable_name_crossing_x_y,
      title_constants=paste("(ratio tracking app:",r$ratio.of.people.using.the.tracking.app,")",sep="")
    ))
    Sys.sleep(1)
    
  }


###Number contactor per contacted per age group

foreach(r = splitted_by_app_user_ratio_df) %do%
  {
    local_df <- r
    get_variable_name_crossing_x_y <- function (x_name,y_name)
    {
      paste("age.group.to.age.group..contacts.",x_name,".age.",y_name,".age", sep="")
    }
    
    print(
      assocc_processing.plot_stacked_bar_chart2(
        df=local_df,
        values = c("young", "student", "worker", "retired"),
        x_output_name="contacted",
        y_output_name="#contacts",
        linesVarName= "contactors",
        get_variable_name_crossing_x_y= get_variable_name_crossing_x_y,
        title_constants=paste("(ratio tracking app:",r$ratio.of.people.using.the.tracking.app,")",sep="")
      ))
    Sys.sleep(1)
  }

foreach(i = splitted_by_ratio_anxiety_df) %do% 
  {
    
    input_variables_to_display = 
      list ("ratio.of.anxiety.avoidance.tracing.app.users")
    
    xDataName = "X.step."
    yDataName = "X.infected"
    linesVarName = "ratio.of.people.using.the.tracking.app"
    local_df = i
    
    print(assocc_processing.plot(
      xDataName = xDataName,
      yDataName = yDataName,
      linesVarName = linesVarName,
      input_variables_to_display = input_variables_to_display,
      local_df = i
    ))
    Sys.sleep(1)
    
    print(assocc_processing.plot(
      xDataName = xDataName,
      yDataName = "ratio.quarantiners.currently.complying.to.quarantine",
      linesVarName = linesVarName,
      input_variables_to_display = input_variables_to_display,
      local_df = i
    ))
    Sys.sleep(1)
  }



### Infections per GP
list_of_y_variables_to_compare <-
  c("X.people.infected.in.hospitals",
    "X.people.infected.in.homes",
    "X.people.infected.in.non.essential.shops",
    "X.people.infected.in.public.leisure",
    "X.people.infected.in.private.leisure",
    "X.people.infected.in.schools",
    "X.people.infected.in.universities",
    "X.people.infected.in.essential.shops",
    "X.people.infected.in.pubtrans",
    "X.people.infected.in.queuing",
    "X.people.infected.in.shared.cars")

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "app_user_ratio")

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(
      x_var_name="X.step.",
      y_var_name="X.infected",
      list_of_y_variables_to_compare,
      name_independent_variables_to_display = name_independent_variables_to_display,
      df = i))
    Sys.sleep(1)
  }


list_of_y_variables_to_compare <-
  c("X.contacts.in.hospitals",
    "X.contacts.in.homes",
    "X.contacts.in.workplaces",
    "X.contacts.in.non.essential.shops",
    "X.contacts.in.public.leisure",
    "X.contacts.in.private.leisure",
    "X.contacts.in.schools",
    "X.contacts.in.universities",
    "X.contacts.in.essential.shops",
    "X.contacts.in.pubtrans",
    "X.contacts.in.queuing",
    "X.contacts.in.shared.cars")

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.contacts.last.tick",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i))
    Sys.sleep(1)
  }



list_of_y_variables_to_compare <-
  c("X.cumulative.youngs.infected",
    "X.cumulative.youngs.infector",
    "X.cumulative.students.infected",
    "X.cumulative.students.infector",
    "X.cumulative.workers.infected",
    "X.cumulative.workers.infector",
    "X.cumulative.retireds.infected",
    "X.cumulative.retireds.infector")

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i))
    Sys.sleep(1)
  }

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

list_of_y_variables_to_compare <-
  c("X.hospitalizations.retired.this.tick",
    "X.hospitalizations.students.this.tick",
    "X.hospitalizations.workers.this.tick",
    "X.hospitalizations.youngs.this.tick")



foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    x_var_name="X.step."
    y_var_name="X.infected"
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i, cumulative = TRUE))
    Sys.sleep(1)
  }

list_of_y_variables_to_compare <-
  c("X.hospitalizations.retired.this.tick",
    "X.hospitalizations.students.this.tick",
    "X.hospitalizations.workers.this.tick",
    "X.hospitalizations.youngs.this.tick")


foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i))
    Sys.sleep(1)
  }

##################################TO BE FIXED BY ADDING ACCUMULATED VALUES HERE##################
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.students",
#     "X.cumulative.students.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }
# 
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.workers",
#     "X.cumulative.workers.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }
# 
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.youngs",
#     "X.cumulative.youngs.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }
# 
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.retired",
#     "X.cumulative.retireds.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }




name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

list_of_y_variables_to_compare <-
  c(
    
    "ratio.age.group.to.age.group..infections.young.age.young.age",
    "ratio.age.group.to.age.group..infections.student.age.young.age",
    "ratio.age.group.to.age.group..infections.worker.age.young.age",
    "ratio.age.group.to.age.group..infections.retired.age.young.age",
    "ratio.age.group.to.age.group..infections.young.age.student.age",
    "ratio.age.group.to.age.group..infections.student.age.student.age",
    "ratio.age.group.to.age.group..infections.worker.age.student.age",
    "ratio.age.group.to.age.group..infections.retired.age.student.age",
    "ratio.age.group.to.age.group..infections.young.age.worker.age",
    "ratio.age.group.to.age.group..infections.student.age.worker.age",
    "ratio.age.group.to.age.group..infections.worker.age.worker.age",
    "ratio.age.group.to.age.group..infections.retired.age.worker.age",
    "ratio.age.group.to.age.group..infections.young.age.retired.age",
    "ratio.age.group.to.age.group..infections.student.age.retired.age",
    "ratio.age.group.to.age.group..infections.worker.age.retired.age",
    "ratio.age.group.to.age.group..infections.retired.age.retired.age"
  )



foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY_matrix(x_var_name="X.step.",
                                                              y_var_name="X.infected",
                                                              list_of_y_variables_to_compare,
                                                              name_independent_variables_to_display = name_independent_variables_to_display,
                                                              df = i))
    Sys.sleep(1)
  }

list_of_y_variables_to_compare <-
  c(
    "age.group.to.age.group..contacts.young.age.young.age",
    "age.group.to.age.group..contacts.student.age.young.age",
    "age.group.to.age.group..contacts.worker.age.young.age",
    "age.group.to.age.group..contacts.retired.age.young.age",
    "age.group.to.age.group..contacts.young.age.student.age",
    "age.group.to.age.group..contacts.student.age.student.age",
    "age.group.to.age.group..contacts.worker.age.student.age",
    "age.group.to.age.group..contacts.retired.age.student.age",
    "age.group.to.age.group..contacts.young.age.worker.age",
    "age.group.to.age.group..contacts.student.age.worker.age",
    "age.group.to.age.group..contacts.worker.age.worker.age",
    "age.group.to.age.group..contacts.retired.age.worker.age",
    "age.group.to.age.group..contacts.young.age.retired.age",
    "age.group.to.age.group..contacts.student.age.retired.age",
    "age.group.to.age.group..contacts.worker.age.retired.age",
    "age.group.to.age.group..contacts.retired.age.retired.age"
  )

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY_matrix(x_var_name="X.step.",
                                                              y_var_name="number of contacts",
                                                              list_of_y_variables_to_compare,
                                                              name_independent_variables_to_display = name_independent_variables_to_display,
                                                              df = i))
    Sys.sleep(1)
  }

if (export_pdf) {
  dev.off();
}


#line plot
#ggplot(data = df, mapping = aes(x = tick, y = infected, group = run_number)) + 
#  scale_colour_gradient(low = "red", high = "red4") +
#  geom_line(size=1,alpha=1,aes(color=app_user_ratio)) + 
#  xlab("x-label") +
#  ylab("y-label") + 
#  ggtitle("some title") +
#  labs(title="Title",
#       subtitle="Subtitle", 
#       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#  theme_linedraw()


# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do% 
#   {
#     i$app_user_ratio <- as.factor(i$app_user_ratio)
#     
#     xVarName = "ticks"
#     xData = i$tick
#     yvar = i$infected
#     yvarName = "infected"
#     fillVar = i$app_user_ratio
#     fillVarName = "app user ratio"
#     number_of_repetitions <- length(table(i$X.random.seed))
#     
#     assocc_processing.plot(xData = xData, xDataName = xDataName,
#                            yvar, yvarName,
#                            linesData = fillVar,
#                            linesDataName = fillVarName,
#                            input_variables_to_display = list("ratio.of.anxiety.avoidance.tracing.app.users"))
#   }
# 
# 
# 
# df$app_user_ratio <- as.factor(df$app_user_ratio)
# 
# 
# 
# r_str = "(r=PUT NUMBER OF RUNS)"
# p <- ggplot(data=df, aes(x=tick, y=infected, fill=app_user_ratio))
# p + geom_smooth(aes(colour=app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,se=TRUE, fullrange=FALSE, level=0.95,  span = 0.1)
# 
# #) +
# 
# colors <- c("red", "red3", "red4", "gray10")
# p <- ggplot(data=df, aes(x=tick, y=infected, fill=app_user_ratio))
# p + geom_smooth(aes(colour=app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,se=TRUE, fullrange=FALSE, level=0.95,  span = 0.1) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   # xlim(0, 50) + 
#   ylim(0, 1000) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Infected People") + 
#   labs(title=paste("Infection Plot Mean Plots", r_str),
#        subtitle="Infected People & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") #+
# theme_bw()
# 
# #span = 0.1 was causing the plot not to happen
# 
# #geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,
# #           span = 0.1, se=TRUE, fullrange=FALSE, level=0.95)
# 
# #  # default bins
# 
# stop("R-Script Completed!", call.=TRUE)
# 
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=infected, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 50) + 
#   ylim(0, 50) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Infected People") + 
#   labs(title=paste("Infection Plot Mean Plots", r_str),
#        subtitle="Infected People & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# 
# colors <- c("orange", "orange3", "orange4", "gray10")
# #aware_of_infected plot with trendline
# ggplot(df, aes(x=tick, y=aware_of_infected, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 600) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Infected Aware") + 
#   labs(title=paste("Aware of Infection Mean Plots", r_str),
#        subtitle="Aware of Infection & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("pink", "pink3", "pink4", "gray10")
# #hospital_admissions plot with trendline
# ggplot(df, aes(x=tick, y=hospital_admissions, fill=app_user_ratio)) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 15) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of People Hospitalized") + 
#   labs(title=paste("Hospitalization Mean Plots", r_str),
#        subtitle="Hospitalization & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("purple", "purple3", "purple4", "gray10")
# #taken_hospital_beds plot with trendline
# ggplot(df, aes(x=tick, y=taken_hospital_beds, fill=app_user_ratio)) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 200) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Occupied Hospital Beds") + 
#   labs(title=paste("Occupied Hospital Beds Mean Plots", r_str),
#        subtitle="Occupied Hospital Beds & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("gray90", "gray50", "gray25", "gray0")
# #cumulative_deaths plot with trendline
# ggplot(df, aes(x=tick, y=cumulative_deaths, fill=app_user_ratio)) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 45) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Deaths") + 
#   labs(title=paste("Number of Deaths Mean Plots", r_str),
#        subtitle="Number of Deaths & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("cadetblue","cadetblue3", "cadetblue4", "gray10")
# #tests_performed plot with trendline
# ggplot(df, aes(x=tick, y=tests_performed, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   # scale_colour_gradient(low = "red", high = "gray20") +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 23000) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Tests") + 
#   labs(title=paste("Number of Tests Mean Plots", r_str),
#        subtitle="Tests & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("red","red3", "red4", "gray10")
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=r0, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 7.5) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("R0") + 
#   labs(title=paste("R0 Mean Plots", r_str),
#        subtitle="R0 & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("green","green3", "green4", "gray10")
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=Isolators, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 800) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Supposed Isolators") + 
#   labs(title=paste("Supposed Isolators Mean Plots", r_str),
#        subtitle="Supposed Isolators & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("olivedrab","olivedrab3", "olivedrab4", "gray10")
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=Non_isolators, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 175) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Defecting Isolators") + 
#   labs(title=paste("Defecting Isolators Mean Plots", r_str),
#        subtitle="Defecting Isolators & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
=======
  #Made by Maarten Jensen (Ume? University) & Kurt Kreulen (TU Delft) for ASSOCC
  
  #first empty working memory
  rm(list=ls())
#MANUAL INPUT (if not working from a script)
#args <- commandArgs(trailingOnly=TRUE)
args <- commandArgs(trailingOnly=TRUE)
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
args <- "C:/Users/loisv/git/COVID-sim/processing/scenarios/scenario6"
#args <-"D:/absoluteNewCVOID/COVID-sim/processing/scenarios/scenario6"
if (length(args)==0) {
  stop("At least one argument must be supplied (working directory).n", call.=FALSE)
}
workdirec <- args

if(substr(workdirec, nchar(workdirec)-1+1, nchar(workdirec)) != '/')
  workdirec <- paste(workdirec,"/", sep="")

source(paste(workdirec,"ASSOCC_processing.r", sep=""))

df<-assocc_processing.init_and_prepare_data(workdirec)
splitted_by_ratio_anxiety_df <- split(df, df$ratio.of.anxiety.avoidance.tracing.app.users)
splitted_by_app_user_ratio_df <- split(df, df$ratio.of.people.using.the.tracking.app)
splitted_by_ratio_anxiety_and_ratio_users_df <- split(df, list(df$ratio.of.anxiety.avoidance.tracing.app.users, df$ratio.of.people.using.the.tracking.app))



# PLOTTING -----------------------------------------------------
export_pdf = TRUE;
if (export_pdf) {
  pdf(file="Combined plots.pdf", width=9, height=6);
}

last_tick <- max(df$X.step.)

#assocc_processing.plot_stacked_bar_chart()

foreach(r = splitted_by_app_user_ratio_df) %do%
  {
    local_df <- r
    get_variable_name_crossing_x_y <- function (x_name,y_name)
    {
      paste("ratio.age.group.to.age.group..infections.",x_name,".age.",y_name,".age", sep="")
    }
    
    print(assocc_processing.plot_stacked_bar_chart2(
      df=local_df,
      values = c("young", "student", "worker", "retired"),
      x_output_name="infectee",
      y_output_name="ratio",
      linesVarName= "infector",
      get_variable_name_crossing_x_y= get_variable_name_crossing_x_y,
      title_constants=paste("(ratio tracking app:",r$ratio.of.people.using.the.tracking.app,")",sep="")
    ))
    Sys.sleep(1)
    
  }

foreach(r = splitted_by_app_user_ratio_df) %do%
  {
    local_df <- r
    get_variable_name_crossing_x_y <- function (x_name,y_name)
    {
      paste("age.group.to.age.group..contacts.",x_name,".age.",y_name,".age", sep="")
    }
    
    print(
      assocc_processing.plot_stacked_bar_chart2(
        df=local_df,
        values = c("young", "student", "worker", "retired"),
        x_output_name="contacted",
        y_output_name="#contacts",
        linesVarName= "contactors",
        get_variable_name_crossing_x_y= get_variable_name_crossing_x_y,
        title_constants=paste("(ratio tracking app:",r$ratio.of.people.using.the.tracking.app,")",sep="")
      ))
    Sys.sleep(1)
  }

foreach(i = splitted_by_ratio_anxiety_df) %do% 
  {
    
    input_variables_to_display = 
      list ("ratio.of.anxiety.avoidance.tracing.app.users")
    
    xDataName = "X.step."
    yDataName = "X.infected"
    linesVarName = "ratio.of.people.using.the.tracking.app"
    local_df = i
    
    print(assocc_processing.plot(
      xDataName = xDataName,
      yDataName = yDataName,
      linesVarName = linesVarName,
      input_variables_to_display = input_variables_to_display,
      local_df = i
    ))
    Sys.sleep(1)
    
    print(assocc_processing.plot(
      xDataName = xDataName,
      yDataName = "ratio.quarantiners.currently.complying.to.quarantine",
      linesVarName = linesVarName,
      input_variables_to_display = input_variables_to_display,
      local_df = i
    ))
    Sys.sleep(1)
  }




### Number of people infected per gathering point

list_of_y_variables_to_compare <-
  c("X.people.infected.in.hospitals",
    "X.people.infected.in.homes",
    "X.people.infected.in.non.essential.shops",
    "X.people.infected.in.public.leisure",
    "X.people.infected.in.private.leisure",
    "X.people.infected.in.schools",
    "X.people.infected.in.universities",
    "X.people.infected.in.essential.shops",
    "X.people.infected.in.pubtrans",
    "X.people.infected.in.shared.cars",
    "X.people.infected.in.queuing")


name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "app_user_ratio")

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(
      x_var_name="X.step.",
      y_var_name="X.infected",
      list_of_y_variables_to_compare,
      name_independent_variables_to_display = name_independent_variables_to_display,
      df = i))
    Sys.sleep(1)
  }

list_of_y_variables_to_compare <-
  c("X.contacts.in.hospitals",
    "X.contacts.in.homes",
    "X.contacts.in.workplaces",
    "X.contacts.in.non.essential.shops",
    "X.contacts.in.public.leisure",
    "X.contacts.in.private.leisure",
    "X.contacts.in.schools",
    "X.contacts.in.universities",
    "X.contacts.in.essential.shops",
    "X.contacts.in.pubtrans",
    "X.contacts.in.queuing",
    "X.contacts.in.shared.cars")

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.contacts.last.tick",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i))
    Sys.sleep(1)
  }



list_of_y_variables_to_compare <-
  c("X.cumulative.youngs.infected",
    "X.cumulative.youngs.infector",
    "X.cumulative.students.infected",
    "X.cumulative.students.infector",
    "X.cumulative.workers.infected",
    "X.cumulative.workers.infector",
    "X.cumulative.retireds.infected",
    "X.cumulative.retireds.infector")

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i))
    Sys.sleep(1)
  }

name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

list_of_y_variables_to_compare <-
  c("X.hospitalizations.retired.this.tick",
    "X.hospitalizations.students.this.tick",
    "X.hospitalizations.workers.this.tick",
    "X.hospitalizations.youngs.this.tick")



foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    x_var_name="X.step."
    y_var_name="X.infected"
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i, cumulative = TRUE))
    Sys.sleep(1)
  }

list_of_y_variables_to_compare <-
  c("X.hospitalizations.retired.this.tick",
    "X.hospitalizations.students.this.tick",
    "X.hospitalizations.workers.this.tick",
    "X.hospitalizations.youngs.this.tick")


foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
                                                       y_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       df = i))
    Sys.sleep(1)
  }

##################################TO BE FIXED BY ADDING ACCUMULATED VALUES HERE##################
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.students",
#     "X.cumulative.students.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }
# 
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.workers",
#     "X.cumulative.workers.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }
# 
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.youngs",
#     "X.cumulative.youngs.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }
# 
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.retired",
#     "X.cumulative.retireds.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="X.step.",
#                                                        y_var_name="X.infected",
#                                                        list_of_y_variables_to_compare,
#                                                        name_independent_variables_to_display = name_independent_variables_to_display,
#                                                        df = i))
#     Sys.sleep(1)
#   }




name_independent_variables_to_display = c("ratio.of.anxiety.avoidance.tracing.app.users",
                                          "ratio.of.people.using.the.tracking.app")

list_of_y_variables_to_compare <-
  c(
    
    "ratio.age.group.to.age.group..infections.young.age.young.age",
    "ratio.age.group.to.age.group..infections.student.age.young.age",
    "ratio.age.group.to.age.group..infections.worker.age.young.age",
    "ratio.age.group.to.age.group..infections.retired.age.young.age",
    "ratio.age.group.to.age.group..infections.young.age.student.age",
    "ratio.age.group.to.age.group..infections.student.age.student.age",
    "ratio.age.group.to.age.group..infections.worker.age.student.age",
    "ratio.age.group.to.age.group..infections.retired.age.student.age",
    "ratio.age.group.to.age.group..infections.young.age.worker.age",
    "ratio.age.group.to.age.group..infections.student.age.worker.age",
    "ratio.age.group.to.age.group..infections.worker.age.worker.age",
    "ratio.age.group.to.age.group..infections.retired.age.worker.age",
    "ratio.age.group.to.age.group..infections.young.age.retired.age",
    "ratio.age.group.to.age.group..infections.student.age.retired.age",
    "ratio.age.group.to.age.group..infections.worker.age.retired.age",
    "ratio.age.group.to.age.group..infections.retired.age.retired.age"
  )



foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY_matrix(x_var_name="X.step.",
                                                              y_var_name="X.infected",
                                                              list_of_y_variables_to_compare,
                                                              name_independent_variables_to_display = name_independent_variables_to_display,
                                                              df = i))
    Sys.sleep(1)
  }

list_of_y_variables_to_compare <-
  c(
    "age.group.to.age.group..contacts.young.age.young.age",
    "age.group.to.age.group..contacts.student.age.young.age",
    "age.group.to.age.group..contacts.worker.age.young.age",
    "age.group.to.age.group..contacts.retired.age.young.age",
    "age.group.to.age.group..contacts.young.age.student.age",
    "age.group.to.age.group..contacts.student.age.student.age",
    "age.group.to.age.group..contacts.worker.age.student.age",
    "age.group.to.age.group..contacts.retired.age.student.age",
    "age.group.to.age.group..contacts.young.age.worker.age",
    "age.group.to.age.group..contacts.student.age.worker.age",
    "age.group.to.age.group..contacts.worker.age.worker.age",
    "age.group.to.age.group..contacts.retired.age.worker.age",
    "age.group.to.age.group..contacts.young.age.retired.age",
    "age.group.to.age.group..contacts.student.age.retired.age",
    "age.group.to.age.group..contacts.worker.age.retired.age",
    "age.group.to.age.group..contacts.retired.age.retired.age"
  )

foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY_matrix(x_var_name="X.step.",
                                                              y_var_name="number of contacts",
                                                              list_of_y_variables_to_compare,
                                                              name_independent_variables_to_display = name_independent_variables_to_display,
                                                              df = i))
    Sys.sleep(1)
  }

if (export_pdf) {
  dev.off();
}


#line plot
#ggplot(data = df, mapping = aes(x = tick, y = infected, group = run_number)) + 
#  scale_colour_gradient(low = "red", high = "red4") +
#  geom_line(size=1,alpha=1,aes(color=app_user_ratio)) + 
#  xlab("x-label") +
#  ylab("y-label") + 
#  ggtitle("some title") +
#  labs(title="Title",
#       subtitle="Subtitle", 
#       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#  theme_linedraw()


# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do% 
#   {
#     i$app_user_ratio <- as.factor(i$app_user_ratio)
#     
#     xVarName = "ticks"
#     xData = i$tick
#     yvar = i$infected
#     yvarName = "infected"
#     fillVar = i$app_user_ratio
#     fillVarName = "app user ratio"
#     number_of_repetitions <- length(table(i$X.random.seed))
#     
#     assocc_processing.plot(xData = xData, xDataName = xDataName,
#                            yvar, yvarName,
#                            linesData = fillVar,
#                            linesDataName = fillVarName,
#                            input_variables_to_display = list("ratio.of.anxiety.avoidance.tracing.app.users"))
#   }
# 
# 
# 
# df$app_user_ratio <- as.factor(df$app_user_ratio)
# 
# 
# 
# r_str = "(r=PUT NUMBER OF RUNS)"
# p <- ggplot(data=df, aes(x=tick, y=infected, fill=app_user_ratio))
# p + geom_smooth(aes(colour=app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,se=TRUE, fullrange=FALSE, level=0.95,  span = 0.1)
# 
# #) +
# 
# colors <- c("red", "red3", "red4", "gray10")
# p <- ggplot(data=df, aes(x=tick, y=infected, fill=app_user_ratio))
# p + geom_smooth(aes(colour=app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,se=TRUE, fullrange=FALSE, level=0.95,  span = 0.1) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   # xlim(0, 50) + 
#   ylim(0, 1000) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Infected People") + 
#   labs(title=paste("Infection Plot Mean Plots", r_str),
#        subtitle="Infected People & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") #+
# theme_bw()
# 
# #span = 0.1 was causing the plot not to happen
# 
# #geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,
# #           span = 0.1, se=TRUE, fullrange=FALSE, level=0.95)
# 
# #  # default bins
# 
# stop("R-Script Completed!", call.=TRUE)
# 
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=infected, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 50) + 
#   ylim(0, 50) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Infected People") + 
#   labs(title=paste("Infection Plot Mean Plots", r_str),
#        subtitle="Infected People & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# 
# colors <- c("orange", "orange3", "orange4", "gray10")
# #aware_of_infected plot with trendline
# ggplot(df, aes(x=tick, y=aware_of_infected, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 600) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Infected Aware") + 
#   labs(title=paste("Aware of Infection Mean Plots", r_str),
#        subtitle="Aware of Infection & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("pink", "pink3", "pink4", "gray10")
# #hospital_admissions plot with trendline
# ggplot(df, aes(x=tick, y=hospital_admissions, fill=app_user_ratio)) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 15) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of People Hospitalized") + 
#   labs(title=paste("Hospitalization Mean Plots", r_str),
#        subtitle="Hospitalization & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("purple", "purple3", "purple4", "gray10")
# #taken_hospital_beds plot with trendline
# ggplot(df, aes(x=tick, y=taken_hospital_beds, fill=app_user_ratio)) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 200) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Occupied Hospital Beds") + 
#   labs(title=paste("Occupied Hospital Beds Mean Plots", r_str),
#        subtitle="Occupied Hospital Beds & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("gray90", "gray50", "gray25", "gray0")
# #cumulative_deaths plot with trendline
# ggplot(df, aes(x=tick, y=cumulative_deaths, fill=app_user_ratio)) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 45) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Deaths") + 
#   labs(title=paste("Number of Deaths Mean Plots", r_str),
#        subtitle="Number of Deaths & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("cadetblue","cadetblue3", "cadetblue4", "gray10")
# #tests_performed plot with trendline
# ggplot(df, aes(x=tick, y=tests_performed, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   # scale_colour_gradient(low = "red", high = "gray20") +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 23000) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Tests") + 
#   labs(title=paste("Number of Tests Mean Plots", r_str),
#        subtitle="Tests & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("red","red3", "red4", "gray10")
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=r0, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 7.5) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("R0") + 
#   labs(title=paste("R0 Mean Plots", r_str),
#        subtitle="R0 & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("green","green3", "green4", "gray10")
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=Isolators, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 800) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Supposed Isolators") + 
#   labs(title=paste("Supposed Isolators Mean Plots", r_str),
#        subtitle="Supposed Isolators & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
# 
# colors <- c("olivedrab","olivedrab3", "olivedrab4", "gray10")
# #infected plot with trendline
# ggplot(df, aes(x=tick, y=Non_isolators, fill=app_user_ratio)) +
#   # geom_point(size = 1, alpha = 0) +
#   #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
#   geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=colors) +
#   xlim(0, 500) + 
#   ylim(0, 175) +
#   #aesthetics for the legend
#   guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
#   xlab("Ticks [4 ticks = 1 day]") +
#   ylab("Number of Defecting Isolators") + 
#   labs(title=paste("Defecting Isolators Mean Plots", r_str),
#        subtitle="Defecting Isolators & Proportion of App Users", 
#        caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#   theme_bw()
