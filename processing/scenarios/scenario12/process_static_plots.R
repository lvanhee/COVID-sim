#Made by Maarten Jensen (Ume? University) & Kurt Kreulen (TU Delft) for ASSOCC

#first empty working memory
rm(list=ls())
#MANUAL INPUT (if not working from a script)
#args <- commandArgs(trailingOnly=TRUE)
args <- commandArgs(trailingOnly=TRUE)
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
#args <- "C:/Users/Fabian/Documents/GitHub/COVID-sim/processing/scenarios/scenario6"
#args <- "C:/Users/loisv/git/COVID-sim/processing/scenarios/scenario6"
#args <- "/Users/christiankammler/Documents/R/COVID-sim/processing/scenarios/scenario6"
#args <-"D:/absoluteNewCVOID/COVID-sim/processing/scenarios/scenario6"
args <- "/Users/renem/Source/ASSOCC-data/scen12/"

if (length(args)==0) {
  stop("At least one argument must be supplied (working directory).n", call.=FALSE)
}
workdirec <- args

if(substr(workdirec, nchar(workdirec)-1+1, nchar(workdirec)) != '/')
  workdirec <- paste(workdirec,"/", sep="")

source(paste(workdirec,"ASSOCC_processing.r", sep=""))

df<-assocc_processing.init_and_prepare_data(workdirec, pattern="2020-06-04_.*Static.csv")
df$experiment_name <- with(df,
                           ifelse(grepl("Leisure", file_name, fixed=TRUE),
                                  "Leisure",
                                  ifelse(grepl("Business", file_name, fixed=TRUE),
                                         "Business",
                                         ifelse(grepl("PublicServices", file_name, fixed=TRUE),
                                                "PublicServices",
                                                paste("Frank",
                                                  ifelse(force.partial.reopening.of.private.leisure.after.phase == "phase-2", "with_leisure", "no_leisure"),
                                                  ifelse(force.release.recommendation.working.from.home.after.phase == "phase-2", "with_working_from_home", "without_working_from_home"),
                                                  sep="_")))))
df <- removeVariables(df)
df$file_name <- NULL

splitted_by_experiment_name_static_seed <- split(df, list(df$experiment_name, df$X.random.seed))
splitted_by_static_seed_experiment_name <- split(df, list(df$X.random.seed, df$experiment_name))

splitted_by_run_number <- split(df, df$X.run.number.)

runs <- max(df$X.run.number.)

length_by_run <- NULL

foreach(run = splitted_by_run_number) %do% {
  no_crisis_line <- match("crisis-not-acknowledged", run$current.governmental.model.phase)
  ongoing_crisis_line <- match("ongoing crisis", run$current.governmental.model.phase)
  phase_1_line <- match("phase-1", run$current.governmental.model.phase)
  phase_2_line <- match("phase-2", run$current.governmental.model.phase)
  no_crisis_lenght <- (run[ongoing_crisis_line,]$X.step.) - run[no_crisis_line,]$X.step.
  if(is.na(phase_1_line)) {
    phase_1_line <- which.max(run$X.step.)
  }
  ongoing_crisis_length <- (run[phase_1_line,]$X.step.) - run[ongoing_crisis_line,]$X.step.
  if(is.na(phase_2_line)) {
    phase_2_line <- which.max(run$X.step.)
  }
  phase_1_length <- run[phase_2_line,]$X.step. - run[phase_1_line,]$X.step.
  phase_2_length <- max(run$X.step.) - run[phase_2_line,]$X.step.
  length_by_run <- rbind(length_by_run, data.frame(run=run[1,]$X.run.number., experiment_name=run[1,]$experiment_name, X.random.seed=run[1,]$X.random.seed,
                                                   acknowledgement.ratio=run[1,]$acknowledgement.ratio, condition.phasing.out=run[1,]$condition.phasing.out,
                                                   minimum.days.between.phases=run[1,]$minimum.days.between.phases,
                                                   no_crisis_start=run[no_crisis_line,]$X.step., ongoing_crisis_start=run[ongoing_crisis_line,]$X.step.,
                                                   phase_1_start=run[phase_1_line,]$X.step., phase_2_start=run[phase_2_line,]$X.step.,
                                                   no_crisis_lenght=no_crisis_lenght, ongoing_crisis_length=ongoing_crisis_length, 
                                                   phase_1_length=phase_1_length, phase_2_length=phase_2_length))
}
phase_length_splitted_by_experiment_name <- split(length_by_run, list(length_by_run$experiment_name, length_by_run$X.random.seed))

# PLOTTING -----------------------------------------------------

export_pdf = TRUE;
if (export_pdf) {
  pdf(file="Static_plots_by_experiment.pdf", width=9, height=6);
}

last_tick <- max(df$X.step.)


list_of_y_variables_to_compare <-
  c("X.cumulative.youngs.infected",
    "X.cumulative.youngs.infector",
    "X.cumulative.students.infected",
    "X.cumulative.students.infector",
    "X.cumulative.workers.infected",
    "X.cumulative.workers.infector",
    "X.cumulative.retireds.infected",
    "X.cumulative.retireds.infector")

linePlot <- function (yDataName, local_df) {
  experiment_name <- unique(local_df$experiment_name)
  title_string <- paste(assocc_processing.get_display_name(yDataName), " in experiment ", experiment_name, " (seed = ", local_df$X.random.seed[1], ")", sep="")
  phase_length <- length_by_run[length_by_run$experiment_name == experiment_name & length_by_run$X.random.seed == local_df$X.random.seed[1],]
  ggplot(data=local_df, aes(x=X.step., y=!!sym(yDataName), colour=factor(acknowledgement.ratio))) +
    geom_line() +
    xlab("ticks") +
    ylab(assocc_processing.get_display_name(yDataName)) + 
    facet_grid(cols=vars(condition.phasing.out), rows=vars(minimum.days.between.phases), labeller=labeller(.cols=label_wrap_gen(), .rows=label_both)) +
    geom_vline(aes(xintercept=ongoing_crisis_start, colour=factor(acknowledgement.ratio)), phase_length) + 
    geom_vline(aes(xintercept=phase_1_start, colour=factor(acknowledgement.ratio)), phase_length) +
    geom_vline(aes(xintercept=phase_2_start, colour=factor(acknowledgement.ratio)), phase_length) +
    labs(title=title_string,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         colours = assocc_processing.get_display_name("acknowledgement.ratio"))
}

linePlots <- function (yLab, yDataNames, df) {
  title_string <- paste(assocc_processing.get_display_name(yDataName), " in experiment ", experiment_name, " (seed = ", df$X.random.seed[1], ", acknowledgement-ratio = ", df$acknowledgement.ratio[1], ")", sep="")
  Reduce(`+`, Map(function(name) geom_line(aes(y=!!sym(name), colour=name)), yDataNames), init=ggplot(data=df, aes(x=X.step.))) +
    xlab("ticks") +
    ylab(assocc_processing.get_display_name(yLab)) + 
    facet_grid(cols=vars(condition.phasing.out), rows=vars(minimum.days.between.phases), labeller=labeller(.cols=label_wrap_gen(), .rows=label_both)) +
    labs(title=title_string,
         caption="Agent-based Social Simulation of Corona Crisis (ASSOCC)",
         colours = assocc_processing.get_display_name("acknowledgement.ratio"))
}

input_variables_to_display = list ("experiment_name", "X.random.seed")
foreach(i = splitted_by_experiment_name_static_seed) %do% {
    print(linePlot("X.infected", i))
    print(linePlot("X.dead.people", i))
    print(linePlot("X.taken.hospital.beds", i))
    print(linePlot("X.newly.infected.this.tick", i))
    
    split_by_acknowledgement_ratio <- split(i, i$acknowledgement.ratio)
    
    print(linePlots("X.infected", list_of_y_variables_to_compare, split_by_acknowledgement_ratio[[1]]))
    print(linePlots("X.infected", list_of_y_variables_to_compare, split_by_acknowledgement_ratio[[2]]))
    Sys.sleep(1)
  }

if (export_pdf) {
  dev.off();
}

if(export_pdf) {
  pdf(file="Static plots by experiment_grouped by plot.pdf")
}
foreach(i = splitted_by_experiment_name_static_seed) %do% {
  linePlot("X.infected", i)
}

foreach(i = splitted_by_experiment_name_static_seed) %do% {
  linePlot("X.dead.people", i)
}

foreach(i = splitted_by_experiment_name_static_seed) %do% {
  linePlot("X.taken.hospital.beds", i)
}

foreach(i = splitted_by_experiment_name_static_seed) %do% {
  linePlot("X.newly.infected.this.tick", i)
}

foreach(i = splitted_by_experiment_name_static_seed) %do% {
  
  split_by_acknowledgement_ratio <- split(i, i$acknowledgement.ratio)
  
  print(linePlots("X.infected", list_of_y_variables_to_compare, split_by_acknowledgement_ratio[[1]]))
  print(linePlots("X.infected", list_of_y_variables_to_compare, split_by_acknowledgement_ratio[[2]]))
  Sys.sleep(1)
}
if(export_pdf) {
  dev.off();
}


if(export_pdf) {
  pdf(file="Static plots by seed_grouped_by_plot.pdf")
}
foreach(i = splitted_by_static_seed_experiment_name) %do% {
  linePlot("X.infected", i)
}

foreach(i = splitted_by_static_seed_experiment_name) %do% {
  linePlot("X.dead.people", i)
}

foreach(i = splitted_by_static_seed_experiment_name) %do% {
  linePlot("X.taken.hospital.beds", i)
}

foreach(i = splitted_by_static_seed_experiment_name) %do% {
  linePlot("X.newly.infected.this.tick", i)
}

foreach(i = splitted_by_static_seed_experiment_name) %do% {
  
  split_by_acknowledgement_ratio <- split(i, i$acknowledgement.ratio)
  
  print(linePlots("X.infected", list_of_y_variables_to_compare, split_by_acknowledgement_ratio[[1]]))
  print(linePlots("X.infected", list_of_y_variables_to_compare, split_by_acknowledgement_ratio[[2]]))
  Sys.sleep(1)
}
if(export_pdf) {
  dev.off();
}