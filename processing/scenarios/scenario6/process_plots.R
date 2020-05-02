#Made by Maarten Jensen (Umeå University) & Kurt Kreulen (TU Delft) for ASSOCC

#first empty working memory
rm(list=ls())
#MANUAL INPUT (if not working from a script)
#args <- commandArgs(trailingOnly=TRUE)
#args <- "C:/Users/loisv/git/COVID-sim/processing/scenarios/scenario6"
args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (working directory).n", call.=FALSE)
}
#args[1]

# #then install packages (NOTE: this only needs to be done once for new users of RStudio!)
#install.packages("ggplot2")
#install.packages("plotly")
#install.packages("tidyr")

#then load relevant libraries
library(ggplot2)
library(plotly)
library(tidyr)
getwd()

### MANUAL INPUT: specify and set working directory ###

"allocating to args"

workdirec <- args

if(substr(workdirec, nchar(workdirec)-1+1, nchar(workdirec)) != '/')
  {
  workdirec <- paste(workdirec,"/", sep="")
}

workdirec

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
df <- df %>% 
  rename(
    run_number = X.run.number.,
    app_user_ratio = ratio.of.people.using.the.tracking.app,
    tick = X.step.,
    infected = count.people.with..is.infected..
  # "aware_of_infected", "hospital_admissions","taken_hospital_beds","cumulative_deaths",
  #  "tests_performed","r0","Isolators","Non_isolators"
    
  )



# REMOVE INVALID RUNS ---------------------------------------------------------------
#runs that have a lower amount of maximum infected are seen as invalid and are therefore removed
#specify the minimum number of infected people for a run to be considered as valid (5 person by default)
# the next will fail if the number of infected is not in the data as -> count.people.with..is.infected..
df <- cleanData(df, 1)
# REMOVE IRRELEVANT VARIABLES ---------------------------------------------------------------

#Loop through dataframe and identify variables that do NOT vary (i.e. that are FIXED)
#Unfixed variables are either independent or dependent and therefore relevant to include in the analysis
df <- removeVariables(df)

# RENAME VARIABLES ---------------------------------------------------------------
printColumnNames(df)

### MANUAL INPUT: specify new (easy-to-work-with) variable names ###
new_variable_names <- list(

)
clean_df <- df

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

# PLOTTING -----------------------------------------------------
clean_df$app_user_ratio <- as.factor(clean_df$app_user_ratio)

export_pdf = TRUE;
if (export_pdf) {
  pdf(file=paste(filesNames, " Combined plots.pdf", sep=""), width=9, height=6);
}

r_str = "(r=PUT NUMBER OF RUNS)"


colors <- c("red", "red3", "red4", "gray10")
p <- ggplot(data=clean_df, aes(x=tick, y=infected, fill=app_user_ratio))
p + geom_smooth(aes(colour=app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,se=TRUE, fullrange=FALSE, level=0.95,  span = 0.1,) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
 # xlim(0, 50) + 
  ylim(0, 50) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Infected People") + 
  labs(title=paste("Infection Plot Mean Plots", r_str),
       subtitle="Infected People & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

#span = 0.1 was causing the plot not to happen

#geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5,
 #           span = 0.1, se=TRUE, fullrange=FALSE, level=0.95)
  
#  # default bins

stop("R-Script Completed!", call.=TRUE)

#infected plot with trendline
ggplot(clean_df, aes(x=tick, y=infected, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 50) + 
  ylim(0, 50) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Infected People") + 
  labs(title=paste("Infection Plot Mean Plots", r_str),
       subtitle="Infected People & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()


colors <- c("orange", "orange3", "orange4", "gray10")
#aware_of_infected plot with trendline
ggplot(clean_df, aes(x=tick, y=aware_of_infected, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 600) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Infected Aware") + 
  labs(title=paste("Aware of Infection Mean Plots", r_str),
       subtitle="Aware of Infection & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("pink", "pink3", "pink4", "gray10")
#hospital_admissions plot with trendline
ggplot(clean_df, aes(x=tick, y=hospital_admissions, fill=app_user_ratio)) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 15) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of People Hospitalized") + 
  labs(title=paste("Hospitalization Mean Plots", r_str),
       subtitle="Hospitalization & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("purple", "purple3", "purple4", "gray10")
#taken_hospital_beds plot with trendline
ggplot(clean_df, aes(x=tick, y=taken_hospital_beds, fill=app_user_ratio)) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 200) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Occupied Hospital Beds") + 
  labs(title=paste("Occupied Hospital Beds Mean Plots", r_str),
       subtitle="Occupied Hospital Beds & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("gray90", "gray50", "gray25", "gray0")
#cumulative_deaths plot with trendline
ggplot(clean_df, aes(x=tick, y=cumulative_deaths, fill=app_user_ratio)) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 45) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Deaths") + 
  labs(title=paste("Number of Deaths Mean Plots", r_str),
       subtitle="Number of Deaths & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("cadetblue","cadetblue3", "cadetblue4", "gray10")
#tests_performed plot with trendline
ggplot(clean_df, aes(x=tick, y=tests_performed, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  # scale_colour_gradient(low = "red", high = "gray20") +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 23000) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Tests") + 
  labs(title=paste("Number of Tests Mean Plots", r_str),
       subtitle="Tests & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("red","red3", "red4", "gray10")
#infected plot with trendline
ggplot(clean_df, aes(x=tick, y=r0, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 7.5) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("R0") + 
  labs(title=paste("R0 Mean Plots", r_str),
       subtitle="R0 & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("green","green3", "green4", "gray10")
#infected plot with trendline
ggplot(clean_df, aes(x=tick, y=Isolators, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 800) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Supposed Isolators") + 
  labs(title=paste("Supposed Isolators Mean Plots", r_str),
       subtitle="Supposed Isolators & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()

colors <- c("olivedrab","olivedrab3", "olivedrab4", "gray10")
#infected plot with trendline
ggplot(clean_df, aes(x=tick, y=Non_isolators, fill=app_user_ratio)) +
  # geom_point(size = 1, alpha = 0) +
  #geom_line(size=0.75,alpha=0.35,aes(group=run_number, color=app_user_ratio, linetype=app_user_ratio)) +
  geom_smooth(aes(color = app_user_ratio, linetype=app_user_ratio),method="loess",size=1.5, span = 0.1, se=TRUE, fullrange=FALSE, level=0.95) +
  scale_fill_manual(values=colors) +
  scale_colour_manual(values=colors) +
  xlim(0, 500) + 
  ylim(0, 175) +
  #aesthetics for the legend
  guides(colour = guide_legend(override.aes = list(size=5, alpha=1))) +
  xlab("Ticks [4 ticks = 1 day]") +
  ylab("Number of Defecting Isolators") + 
  labs(title=paste("Defecting Isolators Mean Plots", r_str),
       subtitle="Defecting Isolators & Proportion of App Users", 
       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
  theme_bw()


# Ending of export to pdf
if (export_pdf) {
  dev.off();
}

#line plot
#ggplot(data = clean_df, mapping = aes(x = tick, y = infected, group = run_number)) + 
#  scale_colour_gradient(low = "red", high = "red4") +
#  geom_line(size=1,alpha=1,aes(color=app_user_ratio)) + 
#  xlab("x-label") +
#  ylab("y-label") + 
#  ggtitle("some title") +
#  labs(title="Title",
#       subtitle="Subtitle", 
#       caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)") +
#  theme_linedraw()

