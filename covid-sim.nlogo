__includes ["people_management.nls" "global_metrics.nls" "contagion.nls" "gathering_points.nls" "public_measures.nls" "utils.nls"]
breed [people person]

globals [
  slice-of-the-day
  day-of-the-week
  is-lockdown-active?
  current-day
  #dead-people
  #dead-retired
  away-gathering-point
]

to setup
  check-parameters
  clear-all
  set-default-shape people "circle"
  if debug?[  random-seed 47822 ]
  set slice-of-the-day "morning"
  set day-of-the-week "monday"
  set current-day 0
  set #dead-people 0

  setup-activities
  create-all-people

  setup-social-networks

  if with-infected? [infect-one-random-person]

  update-display

  ask links[hide-link]

  set is-lockdown-active? false
  reset-ticks
end

to check-parameters
  if probability-self-recovery-symptoms + probability-recorvery-if-treated + probability-unavoidable-death > 1
  [
    error "probability-self-recovery-symptoms + probability-recorvery-if-treated + probability-unavoidable-death > 1"
  ]

  if probability-self-recovery-symptoms-old + probability-recorvery-if-treated-old + probability-unavoidable-death-old > 1
  [
    error "probability-self-recovery-symptoms-old + probability-recorvery-if-treated-old + probability-unavoidable-death-old > 1"
  ]
end

to infect-one-random-person
    ask n-of 3 people [
    if disease-model = "markovian"[set-infection-status "infected"]
    if disease-model = "advanced" [set-infection-status "infected-asymptomatic"  set duration-current-disease-status infection-to-asymptomatic-contagiousness]
  ]
end

to go

  tick
  spread-contagion
  update-within-agent-disease-status
  update-people-epistemic-status
  perform-people-activities
  perform-trades-between-gathering-points
  perform-government-actions
  update-display
  update-time
end

to update-time
  if slice-of-the-day = "morning"
  [set slice-of-the-day "afternoon" stop]

  if slice-of-the-day = "afternoon"
  [set slice-of-the-day "evening" stop]

  if slice-of-the-day = "evening"
  [set slice-of-the-day "night" stop]

  if slice-of-the-day = "night" [
    set slice-of-the-day "morning"
    set current-day current-day + 1
    ask homes [
      if available-food-rations > 0 [
        set available-food-rations available-food-rations - count gatherers
      ]
    ]
    ask people [
      set days-since-seen-relatives days-since-seen-relatives + 1
      set days-since-seen-colleagues days-since-seen-colleagues + 1
      set days-since-seen-friends days-since-seen-friends + 1
    ]

    if day-of-the-week = "monday"
    [set day-of-the-week "tuesday" stop]
    if day-of-the-week = "tuesday"
    [set day-of-the-week "wednesday" stop]
    if day-of-the-week = "wednesday"
    [set day-of-the-week "thursday" stop]
    if day-of-the-week = "thursday"
    [set day-of-the-week "friday" stop]
    if day-of-the-week = "friday"
    [set day-of-the-week "saturday" stop]
    if day-of-the-week = "saturday"
    [set day-of-the-week "sunday" stop]
    if day-of-the-week = "sunday"
    [set day-of-the-week "monday" stop]
  ]
end
to-report working-day
  report not (day-of-the-week = "saturday" or day-of-the-week = "sunday")
end
to update-display
  ask people [update-people-display]
end

to update-within-agent-disease-status
  ask people [update-within-disease-status]
end

to perform-people-activities
  ask gathering-points [set current-profit 0]
  ask people [set my-current-income 0]

  ask people [
    perform-activity
  ]
  ask people [
    execute-activity-effect
    update-needs-for-playing (list current-activity current-motivation)
  ]
  if animate? [
    let walkers people with [pxcor != [pxcor] of current-activity or pycor != [pycor] of current-activity]
    while [any? walkers] [
      every 0.1 [
        ask walkers [
          face current-activity
          while [not allowed-move?] [
            ifelse subtract-headings towards current-activity heading + 10 < subtract-headings towards current-activity heading - 10
              [ right 10 ]
              [ left 10 ]
          ]
          forward min (list 1 distance current-activity)
        ]
        set walkers people with [pxcor != [pxcor] of current-activity or pycor != [pycor] of current-activity]
      ]
    ]
  ]
end

to perform-trades-between-gathering-points
  let transfer-amount-from-shops-to-workplaces 0

  ask gathering-points with [gathering-type = "essential-shop"]
  [
    if current-profit > 0
    [
      let amount-charged current-profit * ratio-amount-spent-by-essential-shops-on-supplies
      set transfer-amount-from-shops-to-workplaces transfer-amount-from-shops-to-workplaces + amount-charged
      set amount-of-resources amount-of-resources - amount-charged
      set current-profit current-profit - amount-charged
    ]
  ]

  ask gathering-points with [gathering-type = "non-essential-shop"]
  [
    if current-profit > 0
    [
      let amount-charged current-profit * ratio-amount-spent-by-non-essential-shops-on-supplies
      set transfer-amount-from-shops-to-workplaces transfer-amount-from-shops-to-workplaces + amount-charged
      set amount-of-resources amount-of-resources - amount-charged
      set current-profit current-profit - amount-charged
    ]
  ]

  let n-of-workplaces count gathering-points with [gathering-type = "workplace"]
  ask gathering-points with [gathering-type = "workplace"]
  [
    set amount-of-resources amount-of-resources + transfer-amount-from-shops-to-workplaces / n-of-workplaces
    set current-profit current-profit + transfer-amount-from-shops-to-workplaces / n-of-workplaces
  ]
end

to perform-government-actions
  ;collect taxes
  let taxes-collected 0

  ask gathering-points with [gathering-type = "essential-shop"]
  [
    if current-profit > 0
    [
      let tax-amount current-profit * ratio-tax-on-essential-shops
      set taxes-collected taxes-collected + tax-amount
      set amount-of-resources amount-of-resources - tax-amount
      set current-profit current-profit - tax-amount
    ]
  ]

  ask gathering-points with [gathering-type = "non-essential-shop"]
  [
    if current-profit > 0
    [
      let tax-amount current-profit * ratio-tax-on-non-essential-shops
      set taxes-collected taxes-collected + tax-amount
      set amount-of-resources amount-of-resources - tax-amount
      set current-profit current-profit - tax-amount
    ]
  ]

  ask gathering-points with [gathering-type = "workplace"]
  [
    if current-profit > 0
    [
      let tax-amount current-profit * ratio-tax-on-workplaces
      set taxes-collected taxes-collected + tax-amount
      set amount-of-resources amount-of-resources - tax-amount
      set current-profit current-profit - tax-amount
    ]
  ]

  ask people with [age = "worker"]
  [
    if my-current-income > 0
    [
      let tax-amount my-current-income * ratio-tax-on-workers
      set taxes-collected taxes-collected + tax-amount
      set my-amount-of-resources my-amount-of-resources - tax-amount
      set my-current-income my-current-income - tax-amount
    ]
  ]

  ;redistribution
  let hospital-subsidy taxes-collected * ratio-hospital-subsidy
  let university-subsidy taxes-collected * ratio-university-subsidy
  let retirees-subsidy taxes-collected * ratio-retirees-subsidy
  let students-subsidy taxes-collected * ratio-students-subsidy
  let young-subsidy taxes-collected * ratio-young-subsidy

  let n-of-hospitals count gathering-points with [gathering-type = "hospital"]
  ask gathering-points with [gathering-type = "hospital"]
  [
    set amount-of-resources amount-of-resources + hospital-subsidy / n-of-hospitals
    set current-profit current-profit + hospital-subsidy / n-of-hospitals
  ]

  let n-of-universities count gathering-points with [gathering-type = "university"]
  ask gathering-points with [gathering-type = "university"]
  [
    set amount-of-resources amount-of-resources + university-subsidy / n-of-universities
    set current-profit current-profit + university-subsidy / n-of-universities
  ]

  let n-of-retirees count people with [age = "retired"]
  ask people with [age = "retired"]
  [
    set my-amount-of-resources my-amount-of-resources + retirees-subsidy / n-of-retirees
    set my-current-income my-current-income + retirees-subsidy / n-of-retirees
  ]

  let n-of-students count people with [age = "student"]
  ask people with [age = "student"]
  [
    set my-amount-of-resources my-amount-of-resources + students-subsidy / n-of-students
    set my-current-income my-current-income + students-subsidy / n-of-students
  ]

  let n-of-young count people with [age = "young"]
  ask people with [age = "young"]
  [
    set my-amount-of-resources my-amount-of-resources + young-subsidy / n-of-young
    set my-current-income my-current-income + young-subsidy / n-of-young
  ]
end

to-report allowed-move?
  report can-move? 1 and (not any? gathering-points-on patch-ahead 1 or member? current-activity gathering-points-on patch-ahead 1)
end

to dump-system-state-to-file
  let global_filename (word "description.txt")
  if file-exists? global_filename[ file-delete global_filename]
  file-open global_filename

  file-print "{"

  file-print "\"activities\":["
  ask gathering-points [
    file-print (word "{\"id_gathering_point\":\"" who "\", \"gathering_type\":\"" gathering-type "\"},")
    ]
  file-print "]"

  file-print "\"people\":["
  ask people [
    file-print (word "{\"id\":\"" who "\", \"age\":\"" age "\"},")
    ]
  file-print "]"
  file-print "}"
file-close


  let filename (word "snapshot_" ticks ".txt")
  if file-exists? filename[ file-delete filename]
  file-open filename

  file-print "{ ["
  ask people [file-print (word "{\"id\":\"" who "\", \"id_gathering_point\":\"" [who] of current-activity "\", \"infection_status\":\"" infection-status "\"},")
    ]
  file-print "]}"
file-close
end

to-report total-amount-of-resources-available-in-the-system
  report sum [my-amount-of-resources] of people + sum [amount-of-resources] of gathering-points
end
@#$#@#$#@
GRAPHICS-WINDOW
81
12
518
450
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
32
0
32
1
1
1
ticks
30.0

BUTTON
8
358
71
391
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
8
394
71
427
go
go\nif not any? people with [is-contagious?]\n[stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
550
393
721
438
original-distribution
original-distribution
"one-person-per-patch" "set-by-quotas"
1

CHOOSER
1262
332
1477
377
age-model
age-model
"none" "young-old" "young,student,worker,retired"
2

SLIDER
533
185
720
218
proportion-young-yom
proportion-young-yom
0
1
0.48
0.01
1
NIL
HORIZONTAL

TEXTBOX
533
146
1043
188
Young-old-model (yom) variables\nAssumed a pure markovian four-state disease model (healthy; infected; immuned; dead)
11
0.0
1

SLIDER
1447
29
1594
62
mortality-rate-young
mortality-rate-young
0
1
0.02
0.01
1
NIL
HORIZONTAL

SLIDER
1447
66
1593
99
mortality-rate-old
mortality-rate-old
0
1
0.14
0.01
1
NIL
HORIZONTAL

SLIDER
1592
29
1737
62
recovery-rate-young
recovery-rate-young
0
1
0.09
0.01
1
NIL
HORIZONTAL

SLIDER
1592
66
1736
99
recovery-rate-old
recovery-rate-old
0
1
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
1737
29
1886
62
propagation-risk-yom
propagation-risk-yom
0
1
0.04
0.01
1
NIL
HORIZONTAL

CHOOSER
1300
40
1438
85
disease-model
disease-model
"markovian" "advanced"
1

SWITCH
800
64
1071
97
propagation-by-coordinates-proximity?
propagation-by-coordinates-proximity?
1
1
-1000

INPUTBOX
1076
65
1231
125
propagation-radius
2.0
1
0
Number

PLOT
9
456
517
612
population status
time
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Healthy" 1.0 0 -14439633 true "" "plot count people with [infection-status = \"healthy\"]"
"Dead" 1.0 0 -10873583 true "" "plot #dead-people"
"Immune" 1.0 0 -11033397 true "" "plot count people with [infection-status = \"immune\"]"
"Infected" 1.0 0 -2674135 true "" "plot count people with [is-infected?]"
"EInfected" 1.0 0 -1604481 true "" "plot count people with [epistemic-infection-status = \"infected\"]"
"EImmune" 1.0 0 -5516827 true "" "plot count people with [epistemic-infection-status = \"immune\"]"
"Inf. Retired" 1.0 0 -10141563 true "" "plot count people with [age = \"retired\" and infection-status = \"infected\"]"

TEXTBOX
691
76
1085
118
Propagation model
11
0.0
1

TEXTBOX
536
377
686
395
Setup-distribution
11
0.0
1

TEXTBOX
594
606
744
624
Proxemics model
11
0.0
1

INPUTBOX
695
686
760
746
#schools
3.0
1
0
Number

INPUTBOX
790
686
871
746
#universities
10.0
1
0
Number

INPUTBOX
882
686
959
746
#workplaces
10.0
1
0
Number

TEXTBOX
706
668
1155
696
Number of units per activity type (sharing a unit incurs a transmission risk; due to contact)
11
0.0
1

INPUTBOX
970
687
1056
747
#public-leisure
1.0
1
0
Number

INPUTBOX
1062
688
1146
748
#private-leisure
10.0
1
0
Number

TEXTBOX
734
623
1202
678
Proxemics is represented as \"meeting spaces\" people can move into and be infected or spread infection.\nAs simplifications: each person relates to a fix set of spaces over time (same school, bus, bar) and gets in contact with everyone sharing this space; no contamination due to left germs.\nDensity factors model the relative proximity between individuals within an activity type
9
0.0
1

INPUTBOX
1194
690
1247
750
#homes
101.0
1
0
Number

CHOOSER
555
517
848
562
activity-model
activity-model
"public&private leisure, rest, age-based work"
0

TEXTBOX
1246
312
1396
330
Age model
11
0.0
1

INPUTBOX
1262
391
1315
451
#young
47.0
1
0
Number

INPUTBOX
1319
391
1385
451
#students
65.0
1
0
Number

INPUTBOX
1391
391
1446
451
#workers
105.0
1
0
Number

INPUTBOX
1450
391
1504
451
#retired
83.0
1
0
Number

SWITCH
597
630
728
663
activity-based-proxemics?
activity-based-proxemics?
0
1
-1000

TEXTBOX
1223
401
1373
419
Quotas
9
0.0
1

SWITCH
799
114
1010
147
activity-based-progagation?
activity-based-progagation?
0
1
-1000

SLIDER
674
755
766
788
density-factor-schools
density-factor-schools
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
774
759
866
792
density-factor-universities
density-factor-universities
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
869
758
961
791
density-factor-workplaces
density-factor-workplaces
0
1
0.21
0.01
1
NIL
HORIZONTAL

SLIDER
971
758
1063
791
density-factor-public-leisure
density-factor-public-leisure
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1061
759
1153
792
density-factor-private-leisure
density-factor-private-leisure
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
1201
758
1293
791
density-factor-homes
density-factor-homes
0
1
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
1208
853
1358
871
Measures:
11
0.0
1

CHOOSER
1169
880
1312
925
confinment-measures
confinment-measures
"none" "total-lockdown" "lockdown-10-5"
0

PLOT
10
615
518
765
measures
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"lockdown" 1.0 0 -2674135 true "" "plot ifelse-value is-lockdown-active? [1] [0]"
"@home" 1.0 0 -7500403 true "" "plot count people with [is-at-home?] / count people"
"watched-kids" 1.0 0 -955883 true "" "plot count children with [is-currently-watched-by-an-adult?] / count children"
"workersWorking@work" 1.0 0 -6459832 true "" "plot count workers with [is-working-at-work?] / count workers"
"working@home" 1.0 0 -1184463 true "" "plot count workers with [is-working-at-home?] / count workers"

MONITOR
533
300
651
345
NIL
day-of-the-week
17
1
11

MONITOR
654
300
770
345
NIL
slice-of-the-day
17
1
11

INPUTBOX
1297
689
1393
749
#essential-shops
5.0
1
0
Number

SLIDER
1300
758
1392
791
density-factor-essential-shops
density-factor-essential-shops
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1400
758
1492
791
density-factor-non-essential-shops
density-factor-non-essential-shops
0
1
0.71
0.01
1
NIL
HORIZONTAL

INPUTBOX
1402
690
1491
750
#non-essential-shops
10.0
1
0
Number

INPUTBOX
582
689
669
749
#hospital
1.0
1
0
Number

SLIDER
578
756
670
789
density-factor-hospital
density-factor-hospital
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
831
300
1039
333
probability-hospital-personel
probability-hospital-personel
0
1
0.16
0.01
1
NIL
HORIZONTAL

SLIDER
831
335
1039
368
probability-school-personel
probability-school-personel
0
1
0.35
0.01
1
NIL
HORIZONTAL

SLIDER
831
370
1039
403
probability-university-personel
probability-university-personel
0
1
0.15
0.01
1
NIL
HORIZONTAL

SLIDER
832
407
1041
440
probability-shopkeeper
probability-shopkeeper
0
1
0.18
0.01
1
NIL
HORIZONTAL

SWITCH
1318
913
1480
946
closed-workplaces?
closed-workplaces?
1
1
-1000

SWITCH
1318
880
1481
913
closed-universities?
closed-universities?
1
1
-1000

SLIDER
1532
318
1709
351
ratio-safety-belonging
ratio-safety-belonging
0
1
0.4
0.01
1
NIL
HORIZONTAL

TEXTBOX
1524
297
1674
315
Needs model
11
0.0
1

SWITCH
534
24
645
57
animate?
animate?
1
1
-1000

CHOOSER
972
159
1126
204
household-composition
household-composition
"segregated-elderly" "balanced-mix" "different-kinds"
2

MONITOR
525
813
617
858
NIL
#dead-people
17
1
11

MONITOR
621
813
713
858
NIL
#dead-retired
17
1
11

BUTTON
0
313
77
346
1 Week Run
setup\nrepeat 21 [go]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
643
24
746
57
debug?
debug?
1
1
-1000

TEXTBOX
1287
23
1437
41
Disease model
11
0.0
1

TEXTBOX
1452
13
1602
31
Markovian & advanced parameters
9
0.0
1

TEXTBOX
1449
107
1599
125
Advanced model parameters
9
0.0
1

INPUTBOX
1391
131
1546
191
infection-to-asymptomatic-contagiousness
2.0
1
0
Number

INPUTBOX
1552
131
1707
191
asympomatic-contagiousness-to-symptomatic-contagiousness
4.0
1
0
Number

INPUTBOX
1712
131
1867
191
symptomatic-to-critical-or-heal
7.0
1
0
Number

INPUTBOX
1873
131
1976
191
critical-to-terminal
2.0
1
0
Number

INPUTBOX
1979
131
2075
191
terminal-to-death
7.0
1
0
Number

SLIDER
1928
195
2118
228
probability-unavoidable-death
probability-unavoidable-death
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
1478
196
1724
229
probability-self-recovery-symptoms
probability-self-recovery-symptoms
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
1730
196
1925
229
probability-recorvery-if-treated
probability-recorvery-if-treated
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1478
236
1708
269
probability-self-recovery-symptoms-old
probability-self-recovery-symptoms-old
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1727
236
1922
269
probability-recorvery-if-treated-old
probability-recorvery-if-treated-old
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
1926
236
2118
269
probability-unavoidable-death-old
probability-unavoidable-death-old
0
1
0.2
0.01
1
NIL
HORIZONTAL

TEXTBOX
1314
213
1464
255
Probabilities should be <1\nExtra probability counts as \"recovery without symptoms\"
11
0.0
1

TEXTBOX
538
10
688
28
Simulation management
11
0.0
1

TEXTBOX
1742
311
1892
329
Households distribution
11
0.0
1

MONITOR
1876
445
2023
490
Adults rooming together
count houses-hosting-adults2
17
1
11

MONITOR
2029
445
2122
490
Retired couple
count houses-hosting-retired-couple
17
1
11

MONITOR
1876
497
1973
542
Family
count houses-hosting-family
17
1
11

MONITOR
1980
497
2123
542
Multi-generational living
count houses-hosting-multiple-generations
17
1
11

TEXTBOX
1562
591
1616
609
Migration
11
0.0
1

SLIDER
1625
635
1867
668
probability-infection-when-abroad
probability-infection-when-abroad
0
1
0.22
0.01
1
NIL
HORIZONTAL

SLIDER
1533
353
1709
386
importance-compliance
importance-compliance
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1532
389
1709
422
importance-survival
importance-survival
0
1
0.7
0.01
1
NIL
HORIZONTAL

SLIDER
1626
598
1812
631
probability-going-abroad
probability-going-abroad
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
1532
459
1709
492
importance-leisure
importance-leisure
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
1812
598
1978
631
probability-getting-back-when-abroad
probability-getting-back-when-abroad
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1532
424
1709
457
importance-risk-avoidance
importance-risk-avoidance
0
1
0.44
0.01
1
NIL
HORIZONTAL

SWITCH
1626
566
1738
599
migration?
migration?
1
1
-1000

SWITCH
1511
719
1695
752
travelling-propagation?
travelling-propagation?
1
1
-1000

SLIDER
1509
759
1696
792
density-travelling-propagation
density-travelling-propagation
0
1
0.05
0.01
1
NIL
HORIZONTAL

SWITCH
1742
329
1931
362
households-distribution?
households-distribution?
0
1
-1000

INPUTBOX
1937
302
2030
362
#total-population
300.0
1
0
Number

MONITOR
528
873
585
918
#home
count people with [[gathering-type] of current-activity = \"home\"]
17
1
11

MONITOR
587
873
650
918
#school
count people with [[gathering-type] of current-activity = \"school\"]
17
1
11

MONITOR
652
873
735
918
#workplace
count people with [[gathering-type] of current-activity = \"workplace\"]
17
1
11

MONITOR
737
873
819
918
#university
count people with [[gathering-type] of current-activity = \"university\"]
17
1
11

MONITOR
821
873
892
918
#hospital
count people with [[gathering-type] of current-activity = \"hospital\"]
17
1
11

PLOT
9
768
520
918
Average need satisfaction
time
need satisfaction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"belonging" 1.0 0 -16777216 true "" "plot mean [belonging-need-satisfaction] of people"
"safety" 1.0 0 -13345367 true "" "plot mean [safety-need-satisfaction] of people"
"autonomy" 1.0 0 -955883 true "" "plot mean [autonomy-need-satisfaction] of people"
"relaxing" 1.0 0 -13840069 true "" "plot mean [relaxing-need-satisfaction] of people"
"survival" 1.0 0 -2674135 true "" "plot mean [survival-need-satisfaction] of people"

SLIDER
1532
494
1710
527
importance-autonomy
importance-autonomy
0
1
0.28
0.01
1
NIL
HORIZONTAL

MONITOR
894
873
957
918
#leisure
count people with [member? \"leisure\" [gathering-type] of current-activity]
17
1
11

MONITOR
959
874
1072
919
#essential-shop
count people with [[gathering-type] of current-activity = \"essential-shop\"]
17
1
11

MONITOR
1074
874
1131
919
#shop
count people with [[gathering-type] of current-activity = \"non-essential-shop\"]
17
1
11

PLOT
8
921
520
1071
Average safety needs satisfaction
time
satisfaction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"safety" 1.0 0 -13345367 true "" "plot mean [safety-need-satisfaction] of people"
"compliance" 1.0 0 -13840069 true "" "plot mean [compliance-need-satisfaction] of people"
"risk avoidance" 1.0 0 -2674135 true "" "plot mean [risk-avoidance-need-satisfaction] of people"
"food-safety" 1.0 0 -5325092 true "" "plot mean [food-safety-need-satisfaction] of people"

SWITCH
534
61
678
94
with-infected?
with-infected?
1
1
-1000

MONITOR
526
922
593
967
autonomy
mean [autonomy-need-satisfaction] of people
3
1
11

MONITOR
1834
874
1932
919
NIL
closed-schools?
17
1
11

SWITCH
1226
1009
1531
1042
is-closing-school-when-any-reported-case-measure?
is-closing-school-when-any-reported-case-measure?
1
1
-1000

SLIDER
1742
405
1914
438
ratio-family-homes
ratio-family-homes
0
1
0.25
0.01
1
NIL
HORIZONTAL

TEXTBOX
1233
993
1383
1011
Close schools
11
0.0
1

SLIDER
1508
883
1649
916
ratio-omniscious-infected-that-trigger-school-closing-measure
ratio-omniscious-infected-that-trigger-school-closing-measure
0
1
0.3
0.01
1
NIL
HORIZONTAL

INPUTBOX
1668
868
1823
928
#days-trigger-school-closing-measure
0.0
1
0
Number

TEXTBOX
1211
952
1305
970
Triggers:
11
0.0
1

TEXTBOX
1219
968
1298
991
(fired when any condition is met)
9
0.0
1

TEXTBOX
1172
1046
1322
1064
Non-essential workplaces
11
0.0
1

SLIDER
1505
937
1645
970
ratio-omniscious-infected-that-trigger-non-essential-closing-measure
ratio-omniscious-infected-that-trigger-non-essential-closing-measure
0
1
0.1
0.01
1
NIL
HORIZONTAL

INPUTBOX
1668
928
1823
988
#days-trigger-non-essential-business-closing-measure
0.0
1
0
Number

MONITOR
1834
936
1966
981
NIL
closed-non-essential?
17
1
11

SLIDER
1742
367
1914
400
ratio-adults-homes
ratio-adults-homes
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
1919
367
2121
400
ratio-retired-couple-homes
ratio-retired-couple-homes
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
1920
405
2121
438
ratio-multi-generational-homes
ratio-multi-generational-homes
0
1
0.25
0.01
1
NIL
HORIZONTAL

MONITOR
1742
445
1847
490
Checksum of ratios
ratio-adults-homes + ratio-retired-couple-homes + ratio-family-homes + ratio-multi-generational-homes
17
1
11

SLIDER
1738
66
2106
99
factor-reduction-probability-transmission-young
factor-reduction-probability-transmission-young
0
1
0.57
0.01
1
NIL
HORIZONTAL

PLOT
8
1095
520
1245
Average amount of resources per people age
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"retired" 1.0 0 -16777216 true "" "plot retirees-average-amount-of-resources"
"worker" 1.0 0 -13345367 true "" "plot workers-average-amount-of-resources"
"student" 1.0 0 -955883 true "" "plot students-average-amount-of-resources"
"young" 1.0 0 -13840069 true "" "plot young-average-amount-of-resources"

PLOT
8
1249
520
1399
Amount of resources per gathering point
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"essential-shop" 1.0 0 -16777216 true "" "plot essential-shop-amount-of-resources"
"non-essential-shop" 1.0 0 -13345367 true "" "plot non-essential-shop-amount-of-resources"
"university" 1.0 0 -955883 true "" "plot university-amount-of-resources"
"hospital" 1.0 0 -13840069 true "" "plot hospital-amount-of-resources"
"workplace" 1.0 0 -2674135 true "" "plot workplace-amount-of-resources"

PLOT
976
1215
1394
1365
Total amount of resources available in the system
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-amount-of-resources-available-in-the-system"

SLIDER
526
1114
862
1147
ratio-amount-spent-by-essential-shops-on-supplies
ratio-amount-spent-by-essential-shops-on-supplies
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
526
1151
863
1184
ratio-amount-spent-by-non-essential-shops-on-supplies
ratio-amount-spent-by-non-essential-shops-on-supplies
0
1
0.2
0.01
1
NIL
HORIZONTAL

TEXTBOX
528
1095
712
1123
Shops get supplies from workplaces
11
0.0
1

SLIDER
527
1215
738
1248
ratio-tax-on-essential-shops
ratio-tax-on-essential-shops
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
527
1253
739
1286
ratio-tax-on-non-essential-shops
ratio-tax-on-non-essential-shops
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
527
1291
739
1324
ratio-tax-on-workplaces
ratio-tax-on-workplaces
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
527
1329
739
1362
ratio-tax-on-workers
ratio-tax-on-workers
0
1
0.5
0.01
1
NIL
HORIZONTAL

TEXTBOX
529
1197
706
1225
Taxes charged by the government
11
0.0
1

TEXTBOX
764
1197
941
1225
Distribution of government subsidy
11
0.0
1

SLIDER
763
1215
936
1248
ratio-hospital-subsidy
ratio-hospital-subsidy
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
763
1253
936
1286
ratio-university-subsidy
ratio-university-subsidy
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
763
1291
936
1324
ratio-retirees-subsidy
ratio-retirees-subsidy
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
764
1329
936
1362
ratio-students-subsidy
ratio-students-subsidy
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
764
1367
936
1400
ratio-young-subsidy
ratio-young-subsidy
0
1
0.2
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
