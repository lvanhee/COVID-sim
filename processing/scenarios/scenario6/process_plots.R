rm(list=ls())

#args <- commandArgs(trailingOnly=TRUE)
args <- commandArgs(trailingOnly=TRUE)
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
args <- "C:/Users/loisv/Desktop/git/github_0912/COVID-sim/processing/scenarios/scenario6"
#args <- "/Users/christiankammler/Documents/R/COVID-sim/processing/scenarios/scenario6"
#args <-"D:/absoluteNewCVOID/COVID-sim/processing/scenarios/scenario6"
if (length(args)==0) {
  stop("At least one argument must be supplied (working directory).n", call.=FALSE)
}
workdirec <- args



if(substr(workdirec, nchar(workdirec)-1+1, nchar(workdirec)) != '/')
  workdirec <- paste(workdirec,"/", sep="")

source(paste(workdirec,"ASSOCC_processing.r", sep=""))
input_variables <- list("ratio.of.people.using.the.tracking.app","is.tracking.app.testing.recursive.")

non_splitted_df<-assocc_processing.init_and_prepare_data(workdirec)


non_splitted_df$days = non_splitted_df$X.step. / 4
nb_people <- 1000
non_splitted_df$ratio_infected = non_splitted_df$X.infected / nb_people
non_splitted_df$ratio_infected_at_hospitals = non_splitted_df$X.people.infected.in.hospitals / nb_people
non_splitted_df$ratio_infected_at_home = non_splitted_df$X.people.infected.in.homes / nb_people
non_splitted_df$ratio_infected_at_NE_shops = non_splitted_df$X.people.infected.in.non.essential.shops / nb_people
non_splitted_df$ratio_infected_at_E_shops = non_splitted_df$X.people.infected.in.essential.shops / nb_people
non_splitted_df$ratio_infected_at_pub_leisure = non_splitted_df$X.people.infected.in.public.leisure / nb_people
non_splitted_df$ratio_infected_at_priv_leisure = non_splitted_df$X.people.infected.in.private.leisure / nb_people
non_splitted_df$ratio_infected_at_school = non_splitted_df$X.people.infected.in.schools / nb_people
non_splitted_df$ratio_infected_at_university = non_splitted_df$X.people.infected.in.universities / nb_people
non_splitted_df$ratio_infected_at_pub_trans = non_splitted_df$X.people.infected.in.pubtrans / nb_people
non_splitted_df$ratio_infected_at_shared_cars = non_splitted_df$X.people.infected.in.shared.cars / nb_people
non_splitted_df$ratio_infected_at_queues = non_splitted_df$X.people.infected.in.queuing / nb_people
non_splitted_df$ratio_infected_at_work = non_splitted_df$X.people.infected.in.workplaces/ nb_people

splitted_df_merged_by_run_number <- split(non_splitted_df, non_splitted_df$ratio.of.people.using.the.tracking.app,non_splitted_df$is.tracking.app.testing.recursive.)
splitted_df_merged_by_run_number_and_testing_recursive <- split(non_splitted_df, non_splitted_df$ratio.of.people.using.the.tracking.app)
splitted_df_merged_by_run_number_and_ratio_app_user <- split(non_splitted_df, non_splitted_df$is.tracking.app.testing.recursive.)

# PLOTTING -----------------------------------------------------

pdf(file=paste("s6plots",Sys.Date(),".pdf", sep=""), width=9, height=6);

#X11()
foreach(i = list(non_splitted_df)) %do% 
  {
    input_variables_to_display = 
      list ()
    
    x_var_name = "nb.days"
    y_var_name = "ratio_infected"
    lines_var_names = "ratio.of.people.using.the.tracking.app"
    local_df = i
    
    print(assocc_processing.plot(
      x_var_name = x_var_name,
      y_var_name = y_var_name,
      lines_var_names = lines_var_names,
      input_variables_to_display = input_variables_to_display,
      local_df = i,
      title_string = "Infection ratio over time depending on the app usage ratio",
      print_shadows = FALSE
    ))
    Sys.sleep(1)

    print(assocc_processing.plot(
      x_var_name = x_var_name,
      y_var_name = "ratio.quarantiners.currently.complying.to.quarantine",
      lines_var_names = lines_var_names,
      input_variables_to_display = input_variables_to_display,
      title_string = "Quarantiner compliance ratio over time depending on the app usage ratio",
      local_df = i,
      smoothen_curve = TRUE
    ))
    Sys.sleep(1)
    
    print(assocc_processing.plot(
      x_var_name = x_var_name,
      y_var_name = "X.tests.performed",
      lines_var_names = lines_var_names,
      input_variables_to_display = input_variables_to_display,
      title_string = "Number of tests depending on the app usage ratio",
      local_df = i
    ))
    Sys.sleep(1)
  }

###Number of infector per infected per age group

foreach(r = splitted_df_merged_by_run_number) %do%
  {
    local_df <- r
    get_variable_name_crossing_x_y <- function (x_name,y_name)
    {
      paste("ratio.age.group.to.age.group..infections.",x_name,".age.",y_name,".age", sep="")
    }
    
    title_constants <- paste("(ratio tracking app:",r$ratio.of.people.using.the.tracking.app,
                             ", recursivity:", r$is.tracking.app.testing.recursive.,")",sep="")
    
    print(assocc_processing.plot_stacked_bar_chart2(
      df=local_df,
      values = c("young", "student", "worker", "retired"),
      x_output_name="infectee",
      y_output_name="ratio",
      linesVarName= "infector",
      get_variable_name_crossing_x_y= get_variable_name_crossing_x_y,
      title_constants= title_constants
    ))
    Sys.sleep(1)
  }

  ###Number contactor per contacted per age group

foreach(r = splitted_df_merged_by_run_number) %do%
  {
    
    title_constants <- paste("(ratio tracking app:",r$ratio.of.people.using.the.tracking.app,
                             ", recursivity:", r$is.tracking.app.testing.recursive.,")",sep="")
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
        title_constants=title_constants
      ))
    Sys.sleep(1)
  }

#X11()

### Number of people infected per gathering point

list_of_y_variables_to_compare <-
  c("ratio_infected_at_hospitals",
    "ratio_infected_at_home",
    "ratio_infected_at_E_shops",
    "ratio_infected_at_NE_shops",
    "ratio_infected_at_pub_leisure",
    "ratio_infected_at_priv_leisure",
    "ratio_infected_at_school",
    "ratio_infected_at_university",
    "ratio_infected_at_pub_trans",
    "ratio_infected_at_shared_cars",
    "ratio_infected_at_queues",
    "ratio_infected_at_work")

name_independent_variables_to_display = c("ratio.of.people.using.the.tracking.app", "is.tracking.app.testing.recursive.")

foreach(i = splitted_df_merged_by_run_number) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(
      x_var_name="nb.days",
      y_display_var_name="ratio_infected",
      list_of_y_variables_to_compare = list_of_y_variables_to_compare,
      name_independent_variables_to_display = name_independent_variables_to_display,
      title_string = paste("Infection ratio over time depending on where infections occur for an app usage of",i$ratio.of.people.using.the.tracking.app[1]),
      lines_display_string = "Origin",
      local_df = i))
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
name_independent_variables_to_display = c("ratio.of.people.using.the.tracking.app")

foreach(i = splitted_df_merged_by_run_number) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
                                                       y_display_var_name="X.contacts.last.tick",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       lines_display_string = "Origin of contact",
                                                       title_string = paste("Number of contacts over time per type of gathering point for an app usage of",i$ratio.of.people.using.the.tracking.app[1],"(smoothened)"),
                                                       smoothen_curve = TRUE,
                                                       local_df = i))
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

foreach(i = splitted_df_merged_by_run_number) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
                                                       y_display_var_name="X.infected",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       lines_display_string = "Ages",
                                                       title_string = paste("Number of infectors and infectees over per age for an app usage of",i$ratio.of.people.using.the.tracking.app[1]),
                                                       local_df = i))
    Sys.sleep(1)
  }

name_independent_variables_to_display = c("ratio.of.people.using.the.tracking.app")

list_of_y_variables_to_compare <-
  c("X.hospitalizations.retired.this.tick",
    "X.hospitalizations.students.this.tick",
    "X.hospitalizations.workers.this.tick",
    "X.hospitalizations.youngs.this.tick")


#X11()
foreach(i = splitted_df_merged_by_run_number) %do%
  {
    ###For some reason the cumulation is now broken... I do not really get why and I do not want to fiddle with this now
    title_string = 
      paste("Hospital admissions per age over time for an app-usage ratio of",i$ratio.of.people.using.the.tracking.app[1],"(cumulative)",sep = " ")
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="days",
                                                       y_display_var_name="#hospitalizations",
                                                       lines_display_string = "Age group",
                                                       list_of_y_variables_to_compare,
                                                       title_string = title_string,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       local_df = i, cumulative = TRUE))
    Sys.sleep(1)
  }

list_of_y_variables_to_compare <-
  c("X.hospitalizations.retired.this.tick",
    "X.hospitalizations.students.this.tick",
    "X.hospitalizations.workers.this.tick",
    "X.hospitalizations.youngs.this.tick")


foreach(i = splitted_df_merged_by_run_number) %do%
  {
    title_string = 
      paste("Hospital admissions per age over time for an app-usage ratio of",i$ratio.of.people.using.the.tracking.app[1],"(smoothened)",sep = " " )
    print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
                                                       y_display_var_name="#hospitalizations",
                                                       list_of_y_variables_to_compare,
                                                       name_independent_variables_to_display = name_independent_variables_to_display,
                                                       title_string = title_string,
                                                       smoothen_curve = TRUE,
                                                       local_df = i))
    Sys.sleep(1)
  }

##################################TO BE FIXED BY ADDING ACCUMULATED VALUES HERE##################
# list_of_y_variables_to_compare <-
#   c("X.cumu.hospitalisations.students",
#     "X.cumulative.students.infected")
# 
# foreach(i = splitted_by_ratio_anxiety_and_ratio_users_df) %do%
#   {
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
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
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
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
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
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
#     print(assocc_processing.plotCompareAlongDifferentY(x_var_name="nb.days",
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



foreach(i = splitted_df_merged_by_run_number) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY_matrix(x_var_name="nb.days",
                                                              y_var_name="#infections",
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

foreach(i = splitted_df_merged_by_run_number) %do%
  {
    print(assocc_processing.plotCompareAlongDifferentY_matrix(x_var_name="nb.days",
                                                              y_var_name="number of contacts",
                                                              list_of_y_variables_to_compare,
                                                              name_independent_variables_to_display = name_independent_variables_to_display,
                                                              df = i))
    Sys.sleep(1)
  }

  dev.off();

assocc_processing.plot_stacked_bar_chart(non_splitted_df)




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
#     assocc_processing.plot(xData = xData, x_var_name = x_var_name,
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
