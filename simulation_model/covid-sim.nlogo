extensions [profiler]
__includes ["setup.nls" "people_management.nls" "global_metrics.nls" "utils.nls" "environment_dynamics.nls" "animation.nls"]
breed [people person]

globals [
  slice-of-the-day
  day-of-the-week
  is-lockdown-active?
  current-day
  #dead-people
  #dead-retired
  away-gathering-point
  #who-became-sick-while-travelling-locally
  government-reserve-of-capital
  total-amount-of-capital-in-circulation
  goods-production-of-total-system
]

to go

  reset-timer
  tick
  reset-economy-measurements
  spread-contagion
  update-within-agent-disease-status
  update-people-epistemic-status
  perform-people-activities
  perform-trades-between-gathering-points
  perform-government-actions
  update-display
  update-time
  apply-active-measures

end

to go-profile
    profiler:reset
  profiler:start

  repeat 10 [go]
  export-profiling
end

to startup
  setup
end
@#$#@#$#@
GRAPHICS-WINDOW
99
19
506
427
-1
-1
7.824
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
50
0
50
1
1
1
ticks
30.0

BUTTON
13
26
91
60
setup
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
12
58
91
92
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

SLIDER
1214
34
1340
67
propagation-risk
propagation-risk
0
1
0.05
0.01
1
NIL
HORIZONTAL

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
"EImmune" 1.0 0 -5516827 true "" "plot count people with [is-believing-to-be-immune?]"
"Inf. Retired" 1.0 0 -10141563 true "" "plot count people with [age = \"retired\" and infection-status = \"infected\"]"

TEXTBOX
555
543
705
561
Proxemics model
11
0.0
1

INPUTBOX
767
597
856
657
#schools
3.0
1
0
Number

INPUTBOX
855
597
948
657
#universities
10.0
1
0
Number

INPUTBOX
948
598
1041
658
#workplaces
10.0
1
0
Number

TEXTBOX
553
575
1056
603
Number of units per activity type (sharing a unit incurs a transmission risk; due to contact)
11
0.0
1

INPUTBOX
1039
598
1132
658
#public-leisure
1.0
1
0
Number

INPUTBOX
1131
598
1224
658
#private-leisure
10.0
1
0
Number

TEXTBOX
648
532
1129
587
Proxemics is represented as \"meeting spaces\" people can move into and be infected or spread infection.\nAs simplifications: each person relates to a fix set of spaces over time (same school, bus, bar) and gets in contact with everyone sharing this space; no contamination due to left germs.
9
0.0
1

TEXTBOX
559
302
709
320
Age model
9
0.0
1

SLIDER
767
656
859
689
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
857
656
949
689
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
948
656
1040
689
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
1039
657
1131
690
density-factor-public-leisure
density-factor-public-leisure
0
1
0.51
0.01
1
NIL
HORIZONTAL

SLIDER
1131
658
1223
691
density-factor-private-leisure
density-factor-private-leisure
0
1
0.19
0.01
1
NIL
HORIZONTAL

SLIDER
1407
657
1499
690
density-factor-homes
density-factor-homes
0
1
0.96
0.01
1
NIL
HORIZONTAL

TEXTBOX
1134
726
1284
744
Measures:
13
93.0
1

CHOOSER
1536
969
1688
1014
global-confinment-measures
global-confinment-measures
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
"kids@home" 1.0 0 -10899396 true "" "plot count children with [is-at-home?] / count children"

MONITOR
801
804
919
849
NIL
day-of-the-week
17
1
11

MONITOR
922
804
1038
849
NIL
slice-of-the-day
17
1
11

INPUTBOX
1223
598
1319
658
#essential-shops
5.0
1
0
Number

SLIDER
1224
658
1316
691
density-factor-essential-shops
density-factor-essential-shops
0
1
0.19
0.01
1
NIL
HORIZONTAL

SLIDER
1316
657
1408
690
density-factor-non-essential-shops
density-factor-non-essential-shops
0
1
0.79
0.01
1
NIL
HORIZONTAL

INPUTBOX
1317
598
1408
658
#non-essential-shops
10.0
1
0
Number

INPUTBOX
672
597
768
657
#hospital
1.0
1
0
Number

SLIDER
672
656
767
689
density-factor-hospital
density-factor-hospital
0
1
0.81
0.01
1
NIL
HORIZONTAL

SLIDER
738
322
946
355
probability-hospital-personel
probability-hospital-personel
0
1
0.17
0.01
1
NIL
HORIZONTAL

SLIDER
738
354
946
387
probability-school-personel
probability-school-personel
0
1
0.12
0.01
1
NIL
HORIZONTAL

SLIDER
738
386
946
419
probability-university-personel
probability-university-personel
0
1
0.11
0.01
1
NIL
HORIZONTAL

SLIDER
737
419
946
452
probability-shopkeeper
probability-shopkeeper
0
1
0.13
0.01
1
NIL
HORIZONTAL

SWITCH
1390
996
1537
1029
closed-workplaces?
closed-workplaces?
1
1
-1000

SWITCH
1537
903
1691
936
closed-universities?
closed-universities?
0
1
-1000

SLIDER
982
354
1159
387
ratio-safety-belonging
ratio-safety-belonging
0
1
0.41
0.01
1
NIL
HORIZONTAL

TEXTBOX
989
315
1139
347
Needs\nmodel
13
34.0
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
11
91
91
125
1 Week Run
go\nwhile [day-of-the-week != \"monday\" or slice-of-the-day != \"morning\"] [go]
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
1007
34
1157
66
Disease\nmodel
13
13.0
1

TEXTBOX
956
95
1106
113
Time between transitions
9
0.0
1

INPUTBOX
1075
66
1230
126
infection-to-asymptomatic-contagiousness
2.0
1
0
Number

INPUTBOX
1230
66
1385
126
asympomatic-contagiousness-to-symptomatic-contagiousness
4.0
1
0
Number

INPUTBOX
1384
66
1539
126
symptomatic-to-critical-or-heal
7.0
1
0
Number

INPUTBOX
1538
66
1641
126
critical-to-terminal
2.0
1
0
Number

INPUTBOX
1641
66
1737
126
terminal-to-death
7.0
1
0
Number

SLIDER
1531
125
1723
158
probability-unavoidable-death
probability-unavoidable-death
0
1
0.02
0.01
1
NIL
HORIZONTAL

SLIDER
1075
125
1321
158
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
1321
125
1532
158
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
1075
157
1321
190
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
1321
157
1532
190
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
1531
157
1723
190
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
1350
199
1686
255
Probabilities of each line should be <1\nExtra probability counts as \"recovery without symptoms\"
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
540
230
690
248
Households distribution
13
62.0
1

MONITOR
715
258
850
303
Adults rooming together
count houses-hosting-adults2
17
1
11

MONITOR
897
258
984
303
Retired couples
count houses-hosting-retired-couple
17
1
11

MONITOR
849
258
899
303
Family
count houses-hosting-family
17
1
11

MONITOR
982
258
1108
303
Multi-generational living
count houses-hosting-multiple-generations
17
1
11

TEXTBOX
1533
340
1622
372
Migration model
13
124.0
1

SLIDER
1641
376
1882
409
probability-infection-when-abroad
probability-infection-when-abroad
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1159
354
1335
387
importance-compliance
importance-compliance
0
1
0.55
0.01
1
NIL
HORIZONTAL

SLIDER
1159
386
1336
419
importance-survival
importance-survival
0
1
0.93
0.01
1
NIL
HORIZONTAL

SLIDER
1157
419
1334
452
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
1716
408
1882
441
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
1334
387
1506
420
importance-risk-avoidance
importance-risk-avoidance
0
1
0.39
0.01
1
NIL
HORIZONTAL

SWITCH
1530
376
1642
409
migration?
migration?
0
1
-1000

SLIDER
1673
462
1866
495
density-travelling-propagation
density-travelling-propagation
0
1
0.05
0.01
1
NIL
HORIZONTAL

MONITOR
528
873
592
918
#@home
count people with [[gathering-type] of current-activity = \"home\"]
17
1
11

MONITOR
587
873
656
918
#@school
count people with [[gathering-type] of current-activity = \"school\"]
17
1
11

MONITOR
652
873
741
918
#@workplace
count people with [[gathering-type] of current-activity = \"workplace\"]
17
1
11

MONITOR
737
873
825
918
#@university
count people with [[gathering-type] of current-activity = \"university\"]
17
1
11

MONITOR
821
873
898
918
#@hospital
count people with [[gathering-type] of current-activity = \"hospital\"]
17
1
11

PLOT
9
768
520
1087
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
"belonging" 1.0 0 -16777216 true "" "plot mean [belonging-satisfaction-level] of people"
"risk avoidance" 1.0 0 -13345367 true "" "plot mean [risk-avoidance-satisfaction-level] of people"
"autonomy" 1.0 0 -955883 true "" "plot mean [autonomy-satisfaction-level] of people"
"luxury" 1.0 0 -8330359 true "" "plot mean [luxury-satisfaction-level] of people"
"health" 1.0 0 -2674135 true "" "plot mean [health-satisfaction-level] of people"
"sleep" 1.0 0 -7500403 true "" "plot mean [sleep-satisfaction-level] of people"
"compliance" 1.0 0 -6459832 true "" "plot mean [compliance-satisfaction-level] of people"
"financial-safety" 1.0 0 -1184463 true "" "plot mean [financial-safety-satisfaction-level] of people"
"food-safety" 1.0 0 -14439633 true "" "plot mean [food-safety-satisfaction-level] of people"
"leisure" 1.0 0 -865067 true "" "plot mean [leisure-satisfaction-level] of people"
"financial-survival" 1.0 0 -7858858 true "" "plot mean [financial-survival-satisfaction-level] of people"

SLIDER
982
387
1159
420
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
964
918
#@leisure
count people with [member? \"leisure\" [gathering-type] of current-activity]
17
1
11

MONITOR
963
873
1065
918
#@essential-shop
count people with [[gathering-type] of current-activity = \"essential-shop\"]
17
1
11

MONITOR
1064
873
1139
918
#@NEshop
count people with [[gathering-type] of current-activity = \"non-essential-shop\"]
17
1
11

SWITCH
1075
34
1214
67
with-infected?
with-infected?
0
1
-1000

MONITOR
1236
1029
1390
1074
NIL
closed-schools?
17
1
11

SWITCH
1236
996
1391
1029
is-closing-school-when-any-reported-case-measure?
is-closing-school-when-any-reported-case-measure?
1
1
-1000

SLIDER
546
354
738
387
ratio-family-homes
ratio-family-homes
0
1
0.23
0.01
1
NIL
HORIZONTAL

SLIDER
1236
903
1391
936
ratio-omniscious-infected-that-trigger-school-closing-measure
ratio-omniscious-infected-that-trigger-school-closing-measure
0
1
1.0
0.01
1
NIL
HORIZONTAL

INPUTBOX
1236
936
1391
996
#days-trigger-school-closing-measure
10000.0
1
0
Number

TEXTBOX
1179
879
1273
897
Triggers:
11
0.0
1

TEXTBOX
1161
894
1240
917
(fired when any condition is met)
9
0.0
1

SLIDER
1390
903
1537
936
ratio-omniscious-infected-that-trigger-non-essential-closing-measure
ratio-omniscious-infected-that-trigger-non-essential-closing-measure
0
1
1.0
0.01
1
NIL
HORIZONTAL

INPUTBOX
1390
936
1537
996
#days-trigger-non-essential-business-closing-measure
10000.0
1
0
Number

MONITOR
1395
1029
1536
1074
NIL
closed-non-essential?
17
1
11

SLIDER
546
323
738
356
ratio-adults-homes
ratio-adults-homes
0
1
0.49
0.01
1
NIL
HORIZONTAL

SLIDER
546
387
738
420
ratio-retired-couple-homes
ratio-retired-couple-homes
0
1
0.27
0.01
1
NIL
HORIZONTAL

SLIDER
1046
318
1218
351
needs-std-dev
needs-std-dev
0
1
0.11
0.01
1
NIL
HORIZONTAL

SLIDER
546
419
738
452
ratio-multi-generational-homes
ratio-multi-generational-homes
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
1335
354
1506
387
importance-financial-safety
importance-financial-safety
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
1075
191
1334
224
factor-reduction-probability-transmission-young
factor-reduction-probability-transmission-young
0
1
0.68
0.01
1
NIL
HORIZONTAL

PLOT
11
1130
523
1280
Average amount of capital per people age
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
"retired" 1.0 0 -16777216 true "" "plot retirees-average-amount-of-capital"
"worker" 1.0 0 -13345367 true "" "plot workers-average-amount-of-capital"
"student" 1.0 0 -955883 true "" "plot students-average-amount-of-capital"
"young" 1.0 0 -13840069 true "" "plot young-average-amount-of-capital"

PLOT
11
1284
523
1434
Amount of capital per gathering point
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
"essential-shop" 1.0 0 -16777216 true "" "plot essential-shop-amount-of-capital"
"non-essential-shop" 1.0 0 -13345367 true "" "plot non-essential-shop-amount-of-capital"
"university" 1.0 0 -955883 true "" "plot university-amount-of-capital"
"hospital" 1.0 0 -13840069 true "" "plot hospital-amount-of-capital"
"workplace" 1.0 0 -2674135 true "" "plot workplace-amount-of-capital"
"school" 1.0 0 -6917194 true "" "plot school-amount-of-capital"

PLOT
1056
1081
1518
1231
Total amount of capital available in the system
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
"total" 1.0 0 -16777216 true "" "plot total-amount-of-resources-available-in-the-system"
"government-reserve" 1.0 0 -13345367 true "" "plot government-reserve-of-capital"

SLIDER
531
1303
742
1336
ratio-tax-on-essential-shops
ratio-tax-on-essential-shops
0
1
0.52
0.01
1
NIL
HORIZONTAL

SLIDER
531
1341
743
1374
ratio-tax-on-non-essential-shops
ratio-tax-on-non-essential-shops
0
1
0.52
0.01
1
NIL
HORIZONTAL

SLIDER
531
1379
743
1412
ratio-tax-on-workplaces
ratio-tax-on-workplaces
0
1
0.55
0.01
1
NIL
HORIZONTAL

SLIDER
531
1417
743
1450
ratio-tax-on-workers
ratio-tax-on-workers
0
1
0.41
0.01
1
NIL
HORIZONTAL

TEXTBOX
533
1285
731
1313
Taxes charged by the government
11
0.0
1

TEXTBOX
767
1232
966
1260
Distribution of government subsidy
11
0.0
1

SLIDER
766
1288
939
1321
ratio-hospital-subsidy
ratio-hospital-subsidy
0
1
0.21
0.01
1
NIL
HORIZONTAL

SLIDER
766
1326
939
1359
ratio-university-subsidy
ratio-university-subsidy
0
1
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
766
1364
939
1397
ratio-retirees-subsidy
ratio-retirees-subsidy
0
1
0.34
0.01
1
NIL
HORIZONTAL

SLIDER
767
1402
939
1435
ratio-students-subsidy
ratio-students-subsidy
0
1
0.34
0.01
1
NIL
HORIZONTAL

SLIDER
766
1250
938
1283
ratio-school-subsidy
ratio-school-subsidy
0
1
0.03
0.01
1
NIL
HORIZONTAL

CHOOSER
555
251
693
296
preset-profiles
preset-profiles
"none" "mediterranea" "scandinavia" "south-asia" "north-america"
2

SLIDER
1274
762
1504
795
ratio-population-randomly-tested-daily
ratio-population-randomly-tested-daily
0
1
0.0
0.01
1
NIL
HORIZONTAL

SWITCH
1274
827
1504
860
test-workplace-of-confirmed-people?
test-workplace-of-confirmed-people?
1
1
-1000

SWITCH
1274
794
1504
827
test-home-of-confirmed-people?
test-home-of-confirmed-people?
1
1
-1000

TEXTBOX
1241
743
1391
761
People testing
11
0.0
1

SLIDER
531
1169
743
1202
price-of-rations-in-essential-shops
price-of-rations-in-essential-shops
0.5
10
2.2
0.1
1
NIL
HORIZONTAL

SLIDER
1334
419
1506
452
importance-luxury
importance-luxury
0
1
0.15
0.01
1
NIL
HORIZONTAL

SLIDER
982
419
1159
452
importance-self-esteem
importance-self-esteem
0
1
0.41
0.01
1
NIL
HORIZONTAL

PLOT
12
1438
523
1588
Accumulated amount of goods in stock per type of business
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
"essential-shop" 1.0 0 -16777216 true "" "plot essential-shop-amount-of-goods-in-stock"
"non-essential-shop" 1.0 0 -13345367 true "" "plot non-essential-shop-amount-of-goods-in-stock"
"workplace" 1.0 0 -2674135 true "" "plot workplace-amount-of-goods-in-stock"

SLIDER
530
1477
739
1510
goods-produced-by-work-performed
goods-produced-by-work-performed
1
50
12.0
1
1
NIL
HORIZONTAL

SLIDER
530
1515
739
1548
unit-price-of-goods
unit-price-of-goods
0.1
5
1.7
0.1
1
NIL
HORIZONTAL

SWITCH
746
23
869
56
static-seed?
static-seed?
0
1
-1000

CHOOSER
538
72
777
117
preset-scenario
preset-scenario
"none" "generic-baseline" "uninfected-scandinavia" "zero-action-scandinavia" "one-family" "scenario-1-closing-schools-and-uni" "scenario-1-work-at-home-only" "scenario-1-closing-all" "economic-scenario-1-baseline" "economic-scenario-2-infections" "economic-scenario-3-lockdown" "economic-scenario-4-wages" "no-action-scandinavia-2.5K"
1

MONITOR
716
213
781
258
#children
count children
17
1
11

MONITOR
781
213
852
258
#students
count students
17
1
11

MONITOR
851
213
917
258
#workers
count workers
17
1
11

MONITOR
916
213
975
258
#retired
count retireds
17
1
11

TEXTBOX
1291
881
1441
899
Schools\n
9
0.0
1

TEXTBOX
1439
882
1589
900
Workplaces
9
0.0
1

TEXTBOX
1591
883
1741
901
Universities
9
0.0
1

TEXTBOX
739
307
889
325
Worker distribution
9
0.0
1

TEXTBOX
929
148
1079
166
Distribution of desease evolution
9
0.0
1

TEXTBOX
528
657
678
701
Density factors \nRelative proximity between individuals within an activity type and impacts contamination risks.
9
0.0
1

TEXTBOX
1530
463
1691
491
Risks of becoming sick when travelling locally
11
0.0
1

TEXTBOX
1138
800
1271
828
All people at home are tested if one is confirmed sick.
9
0.0
1

TEXTBOX
1138
831
1273
859
All people at work are tested if one is confirmed sick.
9
0.0
1

TEXTBOX
1596
950
1746
968
Global
9
0.0
1

TEXTBOX
473
1102
623
1120
Economy model
13
23.0
1

BUTTON
779
79
868
112
NIL
set-values
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
531
1207
727
1240
days-of-rations-bought
days-of-rations-bought
1
28
3.0
1
1
NIL
HORIZONTAL

SLIDER
1530
409
1716
442
probability-going-abroad
probability-going-abroad
0
1
0.02
0.01
1
NIL
HORIZONTAL

MONITOR
1008
920
1065
965
#away
count people with [is-away?]
17
1
11

MONITOR
717
813
781
858
NIL
#who-became-sick-while-travelling-locally
17
1
11

SWITCH
768
1460
968
1493
government-pays-wages?
government-pays-wages?
1
1
-1000

SLIDER
768
1499
1039
1532
ratio-of-wage-paid-by-the-government
ratio-of-wage-paid-by-the-government
0
1
0.8
0.01
1
NIL
HORIZONTAL

INPUTBOX
768
1539
967
1599
government-initial-reserve-of-capital
10000.0
1
0
Number

SLIDER
530
1555
748
1588
max-stock-of-goods-in-a-shop
max-stock-of-goods-in-a-shop
0
1000
500.0
10
1
NIL
HORIZONTAL

SLIDER
766
1122
1036
1155
starting-amount-of-capital-workers
starting-amount-of-capital-workers
0
100
73.0
1
1
NIL
HORIZONTAL

SLIDER
766
1160
1037
1193
starting-amount-of-capital-retired
starting-amount-of-capital-retired
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
766
1198
1050
1231
starting-amount-of-capital-students
starting-amount-of-capital-students
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
1692
936
1829
969
probably-contagion-mitigation-from-social-distancing
probably-contagion-mitigation-from-social-distancing
0
1
0.1
0.01
1
NIL
HORIZONTAL

TEXTBOX
1720
884
1870
902
Social distancing
9
0.0
1

SLIDER
1692
903
1829
936
ratio-omniscious-infected-that-trigger-social-distancing-measure
ratio-omniscious-infected-that-trigger-social-distancing-measure
0
1
0.12
0.01
1
NIL
HORIZONTAL

MONITOR
1692
969
1828
1014
NIL
is-social-distancing-measure-active?
17
1
11

PLOT
1056
1241
1422
1391
Velocity of money in total system
NIL
NIL
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot velocity-of-money-in-total-system"

PLOT
1056
1402
1423
1552
Goods production of total system
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
"default" 1.0 0 -16777216 true "" "plot goods-production-of-total-system"

PLOT
1446
1241
1856
1391
Number of adult people out of capital
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
"total" 1.0 0 -16777216 true "" "plot #adult-people-out-of-capital"
"worker" 1.0 0 -13345367 true "" "plot #workers-out-of-capital"
"retired" 1.0 0 -955883 true "" "plot #retired-out-of-capital"
"student" 1.0 0 -10899396 true "" "plot #students-out-of-capital"

PLOT
1446
1402
1857
1552
Number of gathering points out of capital
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
"essential-shop" 1.0 0 -16777216 true "" "plot #essential-shops-out-of-capital"
"non-essential-shop" 1.0 0 -13345367 true "" "plot #non-essential-shops-out-of-capital"
"university" 1.0 0 -955883 true "" "plot #universities-out-of-capital"
"hospital" 1.0 0 -13840069 true "" "plot #hospitals-out-of-capital"
"workplace" 1.0 0 -2674135 true "" "plot #workplaces-out-of-capital"
"school" 1.0 0 -8630108 true "" "plot #schools-out-of-capital"

PLOT
16
1613
526
1763
Activities
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
"@Work" 1.0 0 -14070903 true "" "plot count people with [is-at-work?]"
"@Pu-Leisure" 1.0 0 -5298144 true "" "plot count people with [is-at-public-leisure-place?]"
"@Pr-Leisure" 1.0 0 -3844592 true "" "plot count people with [is-at-private-leisure-place?]"
"@Home" 1.0 0 -14439633 true "" "plot count people with [is-at-home?]"
"@Univ" 1.0 0 -4079321 true "" "plot count people with [is-at-university?]"
"Treated" 1.0 0 -7500403 true "" "plot count people with [current-motivation = treatment-motive]"

SLIDER
531
1131
703
1164
workers-wages
workers-wages
0
30
10.0
0.5
1
NIL
HORIZONTAL

SLIDER
989
468
1228
501
mean-social-distance-profile
mean-social-distance-profile
0
1
0.25
0.01
1
NIL
HORIZONTAL

INPUTBOX
545
451
624
511
#households
100.0
1
0
Number

MONITOR
636
460
695
505
#people
count people
17
1
11

INPUTBOX
1552
233
1707
293
#beds-in-hospital
100.0
1
0
Number

MONITOR
525
766
618
811
NIL
#people-saved-by-hospitalization
17
1
11

MONITOR
1180
1665
1293
1710
NIL
#hospital-workers
17
1
11

MONITOR
1040
1613
1173
1658
NIL
#essential-shop-workers
17
1
11

MONITOR
1180
1613
1355
1658
NIL
#non-essential-shop-workers
17
1
11

MONITOR
622
765
712
810
NIL
#denied-requests-for-hospital-beds
17
1
11

MONITOR
1041
1665
1173
1710
NIL
#university-workers
17
1
11

MONITOR
1402
239
1519
284
NIL
#taken-hospital-beds
17
1
11

MONITOR
1180
1718
1285
1763
NIL
#school-workers
17
1
11

MONITOR
719
763
781
808
NIL
#people-dying-due-to-lack-of-hospitalization
17
1
11

MONITOR
1042
1718
1173
1763
NIL
#workplace-workers
17
1
11

SLIDER
1230
468
1480
501
std-dev-social-distance-profile
std-dev-social-distance-profile
0
1
0.1
0.01
1
NIL
HORIZONTAL

MONITOR
1692
1014
1828
1059
#social-distancing
count people with [is-I-apply-social-distancing? = true]
17
1
11

PLOT
534
1613
1033
1763
Number of workers actually working at each gathering point
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
"essential-shop" 1.0 0 -16777216 true "" "plot #workers-working-at-essential-shop"
"non-essential-shop" 1.0 0 -13345367 true "" "plot #workers-working-at-non-essential-shop"
"university" 1.0 0 -955883 true "" "plot #workers-working-at-university"
"hospital" 1.0 0 -13840069 true "" "plot #workers-working-at-hospital"
"workplace" 1.0 0 -2674135 true "" "plot #workers-working-at-workplace"
"school" 1.0 0 -8630108 true "" "plot #workers-working-at-school"

SLIDER
531
1246
757
1279
price-of-rations-in-non-essential-shops
price-of-rations-in-non-essential-shops
0.5
10
2.2
0.1
1
NIL
HORIZONTAL

INPUTBOX
539
122
633
182
import-scenario-name
output/done.csv
1
0
String

BUTTON
644
139
707
172
load
load-scenario-from-file
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
716
140
785
173
export
save-world-state
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1507
807
1770
840
productivity-factor-when-not-at-work
productivity-factor-when-not-at-work
0
1
0.79
0.01
1
NIL
HORIZONTAL

MONITOR
1402
282
1519
327
NIL
hospital-effectiveness
17
1
11

MONITOR
1302
264
1402
309
NIL
#beds-available-for-admission
17
1
11

SLIDER
1506
840
1773
873
ratio-population-daily-immunity-testing
ratio-population-daily-immunity-testing
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1346
32
1527
65
daily-risk-believe-experiencing-fake-symptoms
daily-risk-believe-experiencing-fake-symptoms
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1562
582
1715
615
ratio-worker-public-transport
ratio-worker-public-transport
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1712
581
1875
614
ratio-worker-shared-car
ratio-worker-shared-car
0
1
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
1910
520
2027
548
The rest goes on private/safe transport
11
0.0
1

SLIDER
1561
517
1713
550
ratio-children-public-transport
ratio-children-public-transport
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1713
518
1875
551
ratio-children-shared-car
ratio-children-shared-car
0
1
0.93
0.01
1
NIL
HORIZONTAL

SLIDER
1713
550
1875
583
ratio-student-shared-car
ratio-student-shared-car
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1715
614
1875
647
ratio-retired-shared-car
ratio-retired-shared-car
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1561
549
1713
582
ratio-student-public-transport
ratio-student-public-transport
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1562
614
1716
647
ratio-retired-public-transport
ratio-retired-public-transport
0
1
0.0
0.01
1
NIL
HORIZONTAL

INPUTBOX
1560
646
1716
706
#bus-per-timeslot
10.0
1
0
Number

INPUTBOX
1560
703
1716
763
#max-people-per-bus
20.0
1
0
Number

MONITOR
1719
651
1894
696
#people-staying-out-queuing
count people with [stayed-out-queuing-for-bus?]
17
1
11

SLIDER
1718
698
1891
731
density-when-queuing
density-when-queuing
0
1
0.59
0.01
1
NIL
HORIZONTAL

SLIDER
1718
730
1919
763
density-in-public-transport
density-in-public-transport
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
1718
762
1892
795
density-in-shared-cars
density-in-shared-cars
0
1
0.75
0.01
1
NIL
HORIZONTAL

MONITOR
1585
764
1710
809
NIL
#people-denied-bus
17
1
11

MONITOR
1757
65
1934
110
NIL
#people-infected-in-pubtrans
17
1
11

MONITOR
1758
108
1925
153
NIL
#people-infected-in-shared-cars
17
1
11

MONITOR
1758
152
1924
197
NIL
#people-infected-when-queuing
17
1
11

MONITOR
1758
197
1923
242
NIL
#people-infected-in-activities
17
1
11

MONITOR
1759
242
1922
287
NIL
#people-infected-in-general-travel
17
1
11

BUTTON
12
127
92
160
1 Month Run
let starting-day current-day\nlet end-day starting-day + 28\nwhile [current-day <= end-day] [ go ]
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
2024
73
2127
106
culture?
culture?
0
1
-1000

CHOOSER
1955
129
2093
174
national_culture
national_culture
"Netherlands" "United States" "China" "Russia"
0

SLIDER
1952
180
2126
213
uncertainty-avoidance
uncertainty-avoidance
0
100
53.0
1
1
NIL
HORIZONTAL

SLIDER
2135
179
2324
212
individualism-vs-collectivism
individualism-vs-collectivism
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
1953
223
2125
256
power-distance
power-distance
0
100
38.0
1
1
NIL
HORIZONTAL

SLIDER
2135
225
2324
258
indulgence-vs-restraint
indulgence-vs-restraint
0
100
68.0
1
1
NIL
HORIZONTAL

SLIDER
1953
270
2127
303
masculinity-vs-femininity
masculinity-vs-femininity
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
2138
270
2324
303
long-vs-short-termism
long-vs-short-termism
0
100
67.0
1
1
NIL
HORIZONTAL

SLIDER
2100
130
2223
163
value-std-dev
value-std-dev
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
1952
318
2175
351
value-system-calibration-factor
value-system-calibration-factor
0
40
25.0
1
1
NIL
HORIZONTAL

SLIDER
1951
365
2123
398
survival-multiplier
survival-multiplier
0
3
1.5
0.1
1
NIL
HORIZONTAL

SLIDER
2132
366
2304
399
maslow-multiplier
maslow-multiplier
0
1
0.1
0.01
1
NIL
HORIZONTAL

TEXTBOX
1958
74
2018
106
Cultural\nDimension
13
34.0
1

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
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="#hospital">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-of-rations-in-non-essential-shops">
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probably-contagion-mitigation-from-social-distancing">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor-reduction-probability-transmission-young">
      <value value="0.68"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="goods-produced-by-work-performed">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-safety-belonging">
      <value value="0.41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-stock-of-goods-in-a-shop">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="preset-scenario">
      <value value="&quot;generic-baseline&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-private-leisure">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-non-essential-closing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-getting-back-when-abroad">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-to-terminal">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="asympomatic-contagiousness-to-symptomatic-contagiousness">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-school-closing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-workplace-of-confirmed-people?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-survival">
      <value value="0.93"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="with-infected?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-students-subsidy">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-hospital">
      <value value="0.81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#schools">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="static-seed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-risk-avoidance">
      <value value="0.39"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-social-distancing-measure">
      <value value="0.12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-non-essential-shops">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days-of-rations-bought">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-school-subsidy">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-schools">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-adults-homes">
      <value value="0.49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-self-recovery-symptoms">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-unavoidable-death">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-multi-generational-homes">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#households">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-hospital-subsidy">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-shopkeeper">
      <value value="0.13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-luxury">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-essential-shops">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="workers-wages">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-wage-paid-by-the-government">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-school-personel">
      <value value="0.12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-public-leisure">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-workplaces">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-dev-social-distance-profile">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-universities">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-university-subsidy">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-infection-when-abroad">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="needs-std-dev">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-going-abroad">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#beds-in-hospital">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-retired">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#non-essential-shops">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#universities">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-self-recovery-symptoms-old">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-autonomy">
      <value value="0.28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infection-to-asymptomatic-contagiousness">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-family-homes">
      <value value="0.23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-non-essential-shops">
      <value value="0.71"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-hospital-personel">
      <value value="0.17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="migration?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-essential-shops">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#public-leisure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-of-rations-in-essential-shops">
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-financial-safety">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="terminal-to-death">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="unit-price-of-goods">
      <value value="1.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="symptomatic-to-critical-or-heal">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-homes">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-self-esteem">
      <value value="0.41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-closing-school-when-any-reported-case-measure?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-workplaces">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-recorvery-if-treated-old">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="preset-profiles">
      <value value="&quot;scandinavia&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-confinment-measures">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-compliance">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="propagation-risk">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="importance-leisure">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-unavoidable-death-old">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-population-randomly-tested-daily">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-social-distance-profile">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="closed-universities?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-initial-reserve-of-capital">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-students">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-pays-wages?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#essential-shops">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-workers">
      <value value="0.41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#private-leisure">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retirees-subsidy">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#workplaces">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="animate?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-recorvery-if-treated">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-couple-homes">
      <value value="0.27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="closed-workplaces?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#days-trigger-non-essential-business-closing-measure">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-home-of-confirmed-people?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-workers">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-travelling-propagation2">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-university-personel">
      <value value="0.11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#days-trigger-school-closing-measure">
      <value value="10000"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
