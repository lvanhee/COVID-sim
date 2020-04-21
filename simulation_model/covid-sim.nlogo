extensions [profiler]
__includes ["setup.nls" "people_management.nls" "global_metrics.nls" "utils.nls" "environment_dynamics.nls" "animation.nls" "behaviourspace.nls"]
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
]

to go

  reset-timer
  tick
  reset-economy-measurements
  spread-contagion
  update-within-agent-disease-status
  update-people-epistemic-status
  perform-people-activities
  run-economic-cycle
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

to-report epistemic-accuracy if #infected = 0 [report 1] report count people with [is-infected? and is-believing-to-be-infected?] / #infected end

to-report epistemic-false-positive-error-ratio report count people with [is-believing-to-be-infected? and not is-infected?] / count people end

to-report epistemic-error-of-ignored-immunity-ratio report count people with [not is-believing-to-be-immune? and not is-immune?] / count people end
@#$#@#$#@
GRAPHICS-WINDOW
115
73
522
481
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
88
102
123
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
10
126
105
161
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
1497
35
1691
68
propagation-risk
propagation-risk
0
1
0.08
0.01
1
NIL
HORIZONTAL

PLOT
10
522
518
678
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
576
529
726
547
Proxemics model
14
124.0
1

INPUTBOX
848
612
937
672
#schools-gp
3.0
1
0
Number

INPUTBOX
937
612
1030
672
#universities-gp
10.0
1
0
Number

INPUTBOX
1030
613
1123
673
#workplaces-gp
10.0
1
0
Number

TEXTBOX
756
592
1333
621
Number of units per activity type (sharing a unit incurs a transmission risk; due to contact)
11
0.0
1

INPUTBOX
1123
613
1238
673
#public-leisure-gp
1.0
1
0
Number

INPUTBOX
1240
613
1358
673
#private-leisure-gp
10.0
1
0
Number

TEXTBOX
574
558
1543
614
Proxemics is represented as \"meeting spaces\" people can move into and be infected or spread infection.\nAs simplifications: each person relates to a fix set of spaces over time (same school, bus, bar) and gets in contact with everyone sharing this space; no contamination due to left germs.
9
0.0
1

TEXTBOX
654
335
804
353
Age model
9
0.0
1

SLIDER
847
675
939
708
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
937
675
1029
708
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
1029
675
1121
708
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
1127
677
1239
711
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
1243
678
1358
712
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
570
675
745
709
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
1672
770
1917
808
Measures (Interventions) Model
14
105.0
1

CHOOSER
2143
939
2358
985
global-confinement-measures
global-confinement-measures
"none" "total-lockdown" "lockdown-10-5"
0

PLOT
10
680
518
830
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
921
853
1039
898
NIL
day-of-the-week
17
1
11

MONITOR
1040
853
1156
898
NIL
slice-of-the-day
17
1
11

INPUTBOX
1360
613
1479
673
#essential-shops-gp
5.0
1
0
Number

SLIDER
1360
678
1479
712
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
1484
679
1638
713
density-factor-non-essential-shops
density-factor-non-essential-shops
0
1
0.83
0.01
1
NIL
HORIZONTAL

INPUTBOX
1483
613
1635
673
#non-essential-shops-gp
5.0
1
0
Number

INPUTBOX
754
612
850
672
#hospital-gp
1.0
1
0
Number

SLIDER
753
675
848
708
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
910
347
1160
380
probability-hospital-personel
probability-hospital-personel
0
1
0.04
0.01
1
NIL
HORIZONTAL

SLIDER
913
384
1162
417
probability-school-personel
probability-school-personel
0
1
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
912
420
1160
453
probability-university-personel
probability-university-personel
0
1
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
914
459
1159
492
probability-shopkeeper
probability-shopkeeper
0
1
0.04
0.01
1
NIL
HORIZONTAL

SWITCH
1851
1040
2121
1075
closed-workplaces?
closed-workplaces?
1
1
-1000

SWITCH
1609
1160
1831
1195
closed-universities?
closed-universities?
1
1
-1000

SWITCH
547
47
658
80
animate?
animate?
1
1
-1000

MONITOR
552
850
644
895
NIL
#dead-people
17
1
11

MONITOR
655
852
747
897
NIL
#dead-retired
17
1
11

BUTTON
10
168
105
203
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
655
47
758
80
debug?
debug?
1
1
-1000

TEXTBOX
1200
37
1478
77
Disease Model
14
13.0
1

TEXTBOX
1199
74
1349
92
Time between transitions
9
0.0
1

INPUTBOX
1199
92
1442
152
infection-to-asymptomatic-contagiousness
2.0
1
0
Number

INPUTBOX
1447
93
1784
153
asympomatic-contagiousness-to-symptomatic-contagiousness
4.0
1
0
Number

INPUTBOX
1787
92
1974
152
symptomatic-to-critical-or-heal
7.0
1
0
Number

INPUTBOX
1982
93
2094
153
critical-to-terminal
2.0
1
0
Number

INPUTBOX
2104
92
2223
152
terminal-to-death
7.0
1
0
Number

SLIDER
2008
199
2253
232
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
1378
159
1643
192
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
1735
200
2004
233
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
1377
202
1730
235
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
1735
238
2008
271
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
2012
238
2275
271
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
1658
162
1994
218
Probabilities of each line should be <1\nExtra probability counts as \"recovery without symptoms\"
11
0.0
1

TEXTBOX
547
13
779
53
Simulation management
14
0.0
1

TEXTBOX
559
217
709
240
Household Model
14
62.0
1

MONITOR
732
280
901
325
Adults rooming together
count houses-hosting-adults2
17
1
11

MONITOR
995
279
1103
324
Retired couples
count houses-hosting-retired-couple
17
1
11

MONITOR
908
280
988
325
Family
count houses-hosting-family
17
1
11

MONITOR
1112
279
1287
324
Multi-generational living
count houses-hosting-multiple-generations
17
1
11

TEXTBOX
2589
533
2744
573
Migration model
14
124.0
1

SLIDER
2579
568
2853
601
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
2868
612
3165
645
probability-getting-back-when-abroad
probability-getting-back-when-abroad
0
1
0.12
0.01
1
NIL
HORIZONTAL

SWITCH
2732
532
2844
565
migration?
migration?
0
1
-1000

SLIDER
2582
670
2830
703
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
550
910
614
955
#@home
count people with [[gathering-type] of current-activity = \"home\"]
17
1
11

MONITOR
609
910
678
955
#@school
count people with [[gathering-type] of current-activity = \"school\"]
17
1
11

MONITOR
674
910
763
955
#@workplace
count people with [[gathering-type] of current-activity = \"workplace\"]
17
1
11

MONITOR
759
910
847
955
#@university
count people with [[gathering-type] of current-activity = \"university\"]
17
1
11

MONITOR
843
910
920
955
#@hospital
count people with [[gathering-type] of current-activity = \"hospital\"]
17
1
11

PLOT
10
834
521
1153
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
"conformity" 1.0 0 -12345184 true "" "plot mean [conformity-satisfaction-level] of people"

MONITOR
917
910
987
955
#@leisure
count people with [member? \"leisure\" [gathering-type] of current-activity]
17
1
11

MONITOR
985
910
1087
955
#@essential-shop
count people with [[gathering-type] of current-activity = \"essential-shop\"]
17
1
11

MONITOR
1087
910
1162
955
#@NEshop
count people with [[gathering-type] of current-activity = \"non-essential-shop\"]
17
1
11

SWITCH
1343
37
1482
70
with-infected?
with-infected?
0
1
-1000

MONITOR
1610
1082
1836
1128
NIL
closed-schools?
17
1
11

SWITCH
1612
1042
1834
1077
is-closing-school-when-any-reported-case-measure?
is-closing-school-when-any-reported-case-measure?
1
1
-1000

SLIDER
648
390
896
423
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
1612
938
1840
973
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
1612
976
1838
1037
#days-trigger-school-closing-measure
10000.0
1
0
Number

TEXTBOX
1543
945
1637
963
Triggers:
11
0.0
1

TEXTBOX
1515
975
1624
1028
(fired when any condition is met)
9
0.0
1

SLIDER
1852
938
2120
973
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
1851
978
2120
1039
#days-trigger-non-essential-business-closing-measure
10000.0
1
0
Number

MONITOR
1851
1079
2124
1125
NIL
closed-non-essential?
17
1
11

SLIDER
648
353
900
386
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
648
423
896
456
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
2497
385
2669
418
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
647
462
899
495
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
1377
240
1731
273
factor-reduction-probability-transmission-young
factor-reduction-probability-transmission-young
0
1
0.69
0.01
1
NIL
HORIZONTAL

PLOT
12
1215
524
1365
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
"worker" 1.0 0 -13345367 true "" "plot workers-average-amount-of-capital"
"retired" 1.0 0 -955883 true "" "plot retirees-average-amount-of-capital"
"student" 1.0 0 -13840069 true "" "plot students-average-amount-of-capital"

PLOT
12
1370
524
1520
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
1088
1338
1550
1488
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
"total" 1.0 0 -16777216 true "" "plot total-amount-of-capital-in-the-system"
"government-reserve" 1.0 0 -13345367 true "" "plot government-reserve-of-capital"

SLIDER
549
1373
760
1406
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
549
1410
761
1443
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
549
1449
761
1482
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
549
1487
761
1520
ratio-tax-on-workers
ratio-tax-on-workers
0
1
0.35
0.01
1
NIL
HORIZONTAL

TEXTBOX
552
1354
750
1382
Taxes charged by the government
11
0.0
1

TEXTBOX
789
1308
1013
1337
Distribution of government subsidy
11
0.0
1

SLIDER
784
1368
957
1401
ratio-hospital-subsidy
ratio-hospital-subsidy
0
1
0.09
0.01
1
NIL
HORIZONTAL

SLIDER
784
1405
957
1438
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
784
1444
957
1477
ratio-retirees-subsidy
ratio-retirees-subsidy
0
1
0.41
0.01
1
NIL
HORIZONTAL

SLIDER
785
1482
957
1515
ratio-students-subsidy
ratio-students-subsidy
0
1
0.39
0.01
1
NIL
HORIZONTAL

SLIDER
784
1329
956
1362
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
245
715
290
preset-profiles
preset-profiles
"none" "mediterranea" "scandinavia" "south-asia" "north-america"
2

SLIDER
1931
745
2225
779
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
1928
822
2222
856
test-workplace-of-confirmed-people?
test-workplace-of-confirmed-people?
0
1
-1000

SWITCH
1931
782
2224
816
test-home-of-confirmed-people?
test-home-of-confirmed-people?
0
1
-1000

TEXTBOX
1931
720
2081
738
People testing
10
105.0
1

SLIDER
549
1239
761
1272
price-of-rations-in-essential-shops
price-of-rations-in-essential-shops
0.5
10
2.2
0.1
1
NIL
HORIZONTAL

PLOT
13
1524
524
1674
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
548
1547
757
1580
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
548
1584
757
1617
unit-price-of-goods
unit-price-of-goods
0.1
5
1.6
0.1
1
NIL
HORIZONTAL

SWITCH
758
45
887
78
static-seed?
static-seed?
0
1
-1000

CHOOSER
550
94
792
139
preset-scenario
preset-scenario
"default-scenario" "scenario-1-zero-action-scandinavia" "scenario-1-closing-schools-and-uni" "scenario-1-work-at-home-only" "scenario-1-closing-all" "scenario-3-random-test-20" "scenario-3-app-test-60" "scenario-3-app-test-80" "scenario-3-app-test-100" "economic-scenario-1-baseline" "economic-scenario-2-infections" "economic-scenario-3-lockdown" "economic-scenario-4-wages" "app-test-scenario-5-1K" "no-action-scandinavia-2.5K" "one-family"
9

MONITOR
733
235
821
280
#children
count children
17
1
11

MONITOR
829
233
900
278
#students
count students
17
1
11

MONITOR
899
233
965
278
#workers
count workers
17
1
11

MONITOR
964
233
1023
278
#retired
count retireds
17
1
11

TEXTBOX
1698
915
1848
933
Schools\n
10
105.0
1

TEXTBOX
1932
913
2082
931
Workplaces
10
105.0
1

TEXTBOX
1679
1136
1829
1154
Universities
10
105.0
1

TEXTBOX
913
330
1063
348
Worker distribution
9
0.0
1

TEXTBOX
1207
168
1407
210
Distribution of disease evolution
9
0.0
1

TEXTBOX
575
614
753
688
Density factors \nRelative proximity between individuals within an activity type and impacts contamination risks.
9
0.0
1

TEXTBOX
2849
670
3010
698
Risks of becoming sick when travelling locally
11
0.0
1

TEXTBOX
2238
756
2413
787
All people at home are tested if one is confirmed sick.
9
0.0
1

TEXTBOX
2232
799
2414
828
All people at work are tested if one is confirmed sick.
9
0.0
1

TEXTBOX
2206
913
2356
939
Global
10
105.0
1

TEXTBOX
560
1165
710
1183
Economy model
14
23.0
1

BUTTON
809
102
898
135
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
549
1277
745
1310
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
2582
608
2857
641
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
1030
957
1087
1002
#away
count people with [is-away?]
17
1
11

MONITOR
759
853
902
899
NIL
#who-became-sick-while-travelling-locally
17
1
11

SWITCH
787
1529
987
1562
government-pays-wages?
government-pays-wages?
1
1
-1000

SLIDER
787
1569
1058
1602
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
787
1609
986
1669
government-initial-reserve-of-capital
10000.0
1
0
Number

SLIDER
548
1624
766
1657
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
784
1192
1054
1225
starting-amount-of-capital-workers
starting-amount-of-capital-workers
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
784
1229
1055
1262
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
784
1268
1068
1301
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
2146
1060
2519
1095
probably-contagion-mitigation-from-social-distancing
probably-contagion-mitigation-from-social-distancing
0
1
0.08
0.01
1
NIL
HORIZONTAL

TEXTBOX
2159
995
2309
1013
Social distancing
10
105.0
1

SLIDER
2146
1023
2519
1058
ratio-omniscious-infected-that-trigger-social-distancing-measure
ratio-omniscious-infected-that-trigger-social-distancing-measure
0
1
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
2146
1099
2378
1145
NIL
is-social-distancing-measure-active?
17
1
11

PLOT
1089
1496
1455
1646
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
1089
1659
1456
1809
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
1486
1503
1896
1653
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
1486
1665
1897
1815
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
13
1687
522
1851
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
"@E-Shop" 1.0 0 -8630108 true "" "plot count people-at-essential-shops"
"@NE-Shop" 1.0 0 -5825686 true "" "plot count people-at-non-essential-shops"

SLIDER
549
1200
721
1233
workers-wages
workers-wages
0
30
13.0
0.5
1
NIL
HORIZONTAL

SLIDER
2314
447
2486
480
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
554
353
634
416
#households
100.0
1
0
Number

MONITOR
554
297
629
342
#people
count people
17
1
11

INPUTBOX
1375
288
1570
348
#beds-in-hospital
13.0
1
0
Number

MONITOR
552
805
645
850
NIL
#people-saved-by-hospitalization
17
1
11

MONITOR
1205
1899
1318
1944
NIL
#hospital-workers
17
1
11

MONITOR
1065
1846
1198
1891
NIL
#essential-shop-workers
17
1
11

MONITOR
1205
1846
1380
1891
NIL
#non-essential-shop-workers
17
1
11

MONITOR
655
805
745
850
NIL
#denied-requests-for-hospital-beds
17
1
11

MONITOR
1065
1899
1197
1944
NIL
#university-workers
17
1
11

MONITOR
1580
285
1777
330
NIL
#taken-hospital-beds
17
1
11

MONITOR
1205
1952
1310
1997
NIL
#school-workers
17
1
11

MONITOR
758
802
906
848
NIL
#people-dying-due-to-lack-of-hospitalization
17
1
11

MONITOR
1068
1952
1199
1997
NIL
#workplace-workers
17
1
11

SLIDER
2498
447
2670
480
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
2145
1153
2381
1199
#social-distancing
count people with [is-I-apply-social-distancing? = true]
17
1
11

PLOT
545
1704
1044
1854
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
549
1315
775
1348
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
552
144
695
204
import-scenario-name
output/done3.csv
1
0
String

BUTTON
702
157
768
190
import
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
773
157
842
190
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
1851
1175
2133
1210
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
1579
332
1778
377
NIL
hospital-effectiveness
17
1
11

MONITOR
1579
379
1783
424
NIL
#beds-available-for-admission
17
1
11

SLIDER
1928
862
2222
896
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
1700
37
2050
70
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
2585
786
2839
819
ratio-worker-public-transport
ratio-worker-public-transport
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
2855
788
3073
821
ratio-worker-shared-car
ratio-worker-shared-car
0
1
0.15
0.01
1
NIL
HORIZONTAL

TEXTBOX
2865
552
3117
581
The rest goes on private/safe transport
11
0.0
1

SLIDER
2583
710
2837
743
ratio-children-public-transport
ratio-children-public-transport
0
1
0.75
0.01
1
NIL
HORIZONTAL

SLIDER
2849
708
3067
741
ratio-children-shared-car
ratio-children-shared-car
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
2852
746
3070
779
ratio-student-shared-car
ratio-student-shared-car
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
2855
826
3073
859
ratio-retired-shared-car
ratio-retired-shared-car
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
2583
748
2837
781
ratio-student-public-transport
ratio-student-public-transport
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
2585
828
2838
861
ratio-retired-public-transport
ratio-retired-public-transport
0
1
0.2
0.01
1
NIL
HORIZONTAL

INPUTBOX
2579
878
2735
938
#bus-per-timeslot
10.0
1
0
Number

INPUTBOX
2579
933
2735
993
#max-people-per-bus
20.0
1
0
Number

MONITOR
2739
933
2934
978
#people-staying-out-queuing
count people with [stayed-out-queuing-for-bus?]
17
1
11

SLIDER
2948
876
3173
909
density-when-queuing
density-when-queuing
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
2948
918
3173
951
density-in-public-transport
density-in-public-transport
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
2949
958
3173
991
density-in-shared-cars
density-in-shared-cars
0
1
0.8
0.01
1
NIL
HORIZONTAL

MONITOR
2739
880
2908
925
NIL
#people-denied-bus
17
1
11

MONITOR
1788
285
2012
330
NIL
#people-infected-in-pubtrans
17
1
11

MONITOR
1787
333
2010
378
NIL
#people-infected-in-shared-cars
17
1
11

MONITOR
1787
385
2010
430
NIL
#people-infected-when-queuing
17
1
11

MONITOR
1787
437
2011
482
NIL
#people-infected-in-activities
17
1
11

MONITOR
1787
489
2012
534
NIL
#people-infected-in-general-travel
17
1
11

BUTTON
13
208
105
243
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

CHOOSER
2308
42
2458
87
set_national_culture
set_national_culture
"Custom" "Belgium" "Canada" "Germany" "Great Britain" "France" "Italy" "Korea South" "Netherlands" "Norway" "Spain" "Singapore" "Sweden" "U.S.A."
8

SLIDER
2312
113
2486
146
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
2494
112
2683
145
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
2313
155
2485
188
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
2494
158
2683
191
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
2313
203
2487
236
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
2498
203
2684
236
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
2548
270
2671
303
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
2315
270
2538
303
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
2315
345
2487
378
survival-multiplier
survival-multiplier
0
3
2.5
0.1
1
NIL
HORIZONTAL

SLIDER
2497
345
2669
378
maslow-multiplier
maslow-multiplier
0
1
0.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
2309
20
2430
44
Cultural Model
14
83.0
1

SLIDER
2865
572
3173
605
owning-solo-transportation-probability
owning-solo-transportation-probability
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1862
1293
2170
1327
ratio-of-users-of-the-tracking-app
ratio-of-users-of-the-tracking-app
0
1
0.0
0.01
1
NIL
HORIZONTAL

SWITCH
1851
1133
2129
1168
is-working-from-home-recommended?
is-working-from-home-recommended?
1
1
-1000

SLIDER
1689
862
1915
895
percentage-news-watchers
percentage-news-watchers
0
1
0.74
0.01
1
NIL
HORIZONTAL

MONITOR
1863
1339
2168
1384
#recorded-contacts-in-proximity-app
average-number-of-people-recorded-by-recording-apps
17
1
11

INPUTBOX
2329
1239
2484
1299
#days-tracking
14.0
1
0
Number

MONITOR
2232
849
2360
894
NIL
#tests-performed
17
1
11

BUTTON
13
248
106
283
go once
go
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
13
288
104
321
inspect person
inspect one-of people
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

BUTTON
1690
823
1913
858
NIL
inform-people-of-measures
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
2315
385
2488
418
weight-survival-needs
weight-survival-needs
0
1
0.5
0.01
1
NIL
HORIZONTAL

TEXTBOX
2312
90
2646
117
Hofstede dimension settings
12
83.0
1

TEXTBOX
2315
249
2512
279
Agent value system settings
12
83.0
1

TEXTBOX
2314
318
2504
348
Agent need system settings
12
83.0
1

INPUTBOX
904
34
1017
94
#random-seed
1.0
1
0
Number

CHOOSER
2769
62
2971
107
network-generation-method
network-generation-method
"random" "value-similarity"
0

TEXTBOX
2773
26
2961
64
Social Network Model
14
115.0
1

SLIDER
2769
112
3013
145
peer-group-friend-links
peer-group-friend-links
1
150
7.0
1
1
NIL
HORIZONTAL

SLIDER
784
1150
956
1183
productivity-at-home
productivity-at-home
0
2
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
2769
153
3057
186
percentage-of-agents-with-random-link
percentage-of-agents-with-random-link
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1865
1253
2162
1287
ratio-of-anxiety-avoidance-users
ratio-of-anxiety-avoidance-users
0
1
0.0
0.01
1
NIL
HORIZONTAL

BUTTON
2772
193
2929
226
Write network as dot
write-network-to-file user-new-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
2183
1250
2311
1295
#app-users
count people with [is-user-of-tracking-app?]
17
1
11

MONITOR
2180
1360
2420
1405
standard anxiety avoidance of people
mean [importance-weight-safety + \nimportance-weight-risk-avoidance +\nimportance-weight-compliance] of people
4
1
11

MONITOR
2183
1308
2418
1353
anxiety-avoidance of app users
mean [importance-weight-safety + \nimportance-weight-risk-avoidance +\nimportance-weight-compliance] of app-users
17
1
11

BUTTON
649
294
712
327
set
load-population-profile-based-on-current-preset-profile
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1486
1826
2062
2022
Macro Economic Model - Capital Flow
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
"agriculture-essential" 1.0 0 -16777216 true "" "plot total-capital-agriculture-essential"
"agriculture-luxury" 1.0 0 -13345367 true "" "plot total-capital-agriculture-luxury"
"manufacturing-essential" 1.0 0 -955883 true "" "plot total-capital-manufacturing-essential"
"manufacturing-luxury" 1.0 0 -13840069 true "" "plot total-capital-manufacturing-luxury"
"services-essential" 1.0 0 -2674135 true "" "plot total-capital-services-essential"
"services-luxury" 1.0 0 -8630108 true "" "plot total-capital-services-luxury"
"education-research" 1.0 0 -13791810 true "" "plot total-capital-education-research"
"households-sector" 1.0 0 -6459832 true "" "plot total-capital-households-sector"
"government-sector" 1.0 0 -5825686 true "" "plot total-capital-government-sector"

TEXTBOX
2318
427
2590
457
Agent social distancing settings
12
83.0
1

PLOT
1486
2031
1944
2188
Macro Economic Model - International Sector
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
"international-sector" 1.0 0 -14835848 true "" "plot total-capital-international-sector"

SWITCH
1952
2036
2130
2069
close-services-luxury?
close-services-luxury?
1
1
-1000

PLOT
1901
1503
2241
1653
Number of adult people in poverty
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
"total" 1.0 0 -16777216 true "" "plot count people with [not is-young? and is-in-poverty?]"
"worker" 1.0 0 -13345367 true "" "plot count workers with [is-in-poverty?]"
"retired" 1.0 0 -955883 true "" "plot count retireds with [is-in-poverty?]"
"students" 1.0 0 -13840069 true "" "plot count students with [is-in-poverty?]"

PLOT
1901
1665
2229
1815
Histogram of available capital
my-amount-of-capital
counts
0.0
500.0
0.0
10.0
true
true
"foreach [\"worker\" \"retired\" \"student\"] [ pen ->\n  set-current-plot-pen pen\n  set-plot-pen-mode 1\n]\nset-histogram-num-bars 500" ""
PENS
"worker" 1.0 0 -13345367 true "" "histogram [my-amount-of-capital] of workers"
"retired" 1.0 0 -955883 true "" "histogram [my-amount-of-capital] of retireds"
"student" 1.0 0 -13840069 true "" "histogram [my-amount-of-capital] of students"

PLOT
562
970
1003
1120
Quality of Life Indicator
Time
Quality of Life
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Mean" 1.0 0 -13840069 true "" "plot mean [quality-of-life-indicator] of people"
"Median" 1.0 0 -14454117 true "" "plot median [quality-of-life-indicator] of people"
"Min" 1.0 0 -2674135 true "" "plot min [quality-of-life-indicator] of people"
"Max" 1.0 0 -1184463 true "" "plot max [quality-of-life-indicator] of people"

TEXTBOX
22
13
210
55
ASSOCC
28
14.0
1

TEXTBOX
1949
1226
2164
1252
Smartphone apps
10
105.0
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
    <setup>load-population-profile-based-on-current-preset-profile
setup</setup>
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
