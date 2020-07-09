assocc_processing.get_display_name <- function(a)
{
  if(is.vector(a) &&!is.string(a))
  {
    res <- ""
    foreach(i=a)%do%
      {
        translation <- assocc_processing.get_display_name(i)
        if(res =="") res <- translation
        else  res <- paste(res, translation,sep=", ")
      }
    res
  }
  else   if(strcmp(a,"")) {""} else 
    if(startsWith(a,"ratio_infected_at_")) gsub('_'," ",substring(a,19))
  else if(strcmp(a,"ratio_infected"))
    "Infection ratio"
  else if(strcmp(a,"days"))
    "Days"
  else if(strcmp(a,"nb.days")){"#days"}
  else if(strcmp(a,"X.tests.performed"))
    "# tests performed"
  else if(strcmp(a,""))
    ""
  else if(strcmp(a,"count.should.be.isolators"))
    "# theoretical isolators"
  else if(strcmp(a,"count.officially.quarantiners"))
    "#officially quarantiners"
  else if(strcmp(a,"is.tracking.app.testing.recursive."))
    "Recursive App?"
  else if(strcmp(a,"ratio.of.anxiety.avoidance.tracing.app.users"))
    "Anx.Avoid.App"
  else if(strcmp(a,"app_user_ratio")||strcmp(a,"ratio.of.people.using.the.tracking.app")) 
    "App-usage ratio"
  else if(strcmp(a,"X.people.infected.in.essential.shops"))
    "#infected ess-shops"
  else if(strcmp(a,"X.people.infected.in.queuing"))
    "#infected queuing"
  else if(strcmp(a,"X.people.infected.in.shared.cars"))
    "#infected shared cars"
  else if(strcmp(a,"infector"))
    "infector"
  else if(strcmp(a,"#hospitalizations"))
    "#hospitalizations"
  else if(strcmp(a,"infectee"))
    "infectee"
  else if(strcmp(a,"X.people.infected.in.non.essential.shops"))
    "#infected n.ess-shops"
  else if(strcmp(a,"X.people.infected.in.homes"))
    "#infected homes"
  else if(strcmp(a,"X.people.infected.in.public.leisure"))
    "#infected public leisure"
  else if(strcmp(a,"X.people.infected.in.private.leisure"))
    "#infected private leisure"
  else if(strcmp(a,"X.people.infected.in.pubtrans"))
    "#infected public transport"
  else if(strcmp(a,"X.people.infected.in.schools"))
    "#infected schools"
  else if(strcmp(a,"X.people.infected.in.universities"))
    "#infected universities"
  else if(strcmp(a,"people.infected.in.hospitals") ||strcmp(a,"X.people.infected.in.hospitals"))
    "#infected hospitals"
  else if(strcmp(a,"X.contacts.in.essential.shops"))
    "E shops"
  else if(strcmp(a,"X.contacts.in.non.essential.shops"))
    "NE shops"
  else if(strcmp(a,"X.contacts.in.homes"))
    "homes"
  else if(strcmp(a,"X.contacts.in.workplaces"))
    "workplaces"
  else if(strcmp(a,"X.contacts.in.public.leisure"))
    "pub leisure"
  else if(strcmp(a,"X.contacts.in.private.leisure"))
    "private leisure"
  else if(strcmp(a,"X.contacts.in.pubtrans"))
    "pub trans"
  else if(strcmp(a,"X.contacts.in.shared.cars"))
    "shared cars"
  else if(strcmp(a,"X.contacts.in.queuing"))
    "queues"
  else if(strcmp(a,"X.contacts.in.schools"))
    "schools"
  else if(strcmp(a,"X.contacts.in.universities"))
    "universities"
  else if(strcmp(a,"contacts.in.hospitals") ||strcmp(a,"X.contacts.in.hospitals"))
    "hospitals"
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
    "retired" 
  else if(strcmp(a,"X.hospitalizations.students.this.tick"))
    "students" 
  else if(strcmp(a,"X.hospitalizations.workers.this.tick"))
    "workers" 
  else if(strcmp(a,"X.hospitalizations.youngs.this.tick"))
    "youngs" 
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
    "Contacts per tick"
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
