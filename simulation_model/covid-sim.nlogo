extensions [profiler table]
__includes ["setup.nls" "people_management.nls" "global_metrics.nls" "environment_dynamics.nls" "animation.nls" "behaviourspace.nls" "utils/all_utils.nls"]
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
  import-scenario-name
]

to go

  reset-timer
  tick
  reset-metrics
  reset-economy-measurements
  spread-contagion
  update-within-agent-disease-status
  update-people-mind

  perform-people-activities
  run-economic-cycle
  update-display
  increment-time
  apply-active-measures
  update-metrics
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
12
88
101
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
0.15
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
"Uninfected" 1.0 0 -11085214 true "" "plot count people with [infection-status = \"healthy\"]"
"Dead" 1.0 0 -10873583 true "" "plot #dead-people"
"Immune" 1.0 0 -11033397 true "" "plot count people with [infection-status = \"immune\"]"
"Infected" 1.0 0 -2674135 true "" "plot count people with [is-infected?]"
"EInfected" 1.0 0 -1604481 true "" "plot count people with [epistemic-infection-status = \"infected\"]"
"EImmune" 1.0 0 -5516827 true "" "plot count people with [is-believing-to-be-immune?]"
"Inf. Retired" 1.0 0 -10141563 true "" "plot count people with [age = \"retired\" and infection-status = \"infected\"]"
"Healthy" 1.0 0 -12087248 true "" "plot count people with [infection-status = \"healthy\" or infection-status = \"immune\"]"

TEXTBOX
573
539
723
557
Proxemics model
14
125.0
1

INPUTBOX
849
640
938
700
#schools-gp
2.0
1
0
Number

INPUTBOX
936
640
1029
700
#universities-gp
1.0
1
0
Number

INPUTBOX
1028
640
1121
700
#workplaces-gp
34.0
1
0
Number

TEXTBOX
759
613
1512
633
Number of units per activity type (sharing a unit incurs a transmission risk: due to contact)
11
125.0
1

INPUTBOX
1120
640
1235
700
#public-leisure-gp
3.0
1
0
Number

INPUTBOX
1234
640
1352
700
#private-leisure-gp
34.0
1
0
Number

TEXTBOX
575
567
1643
609
Proxemics is represented as \"meeting spaces\" people can move into and be infected or spread infection.\nAs simplifications: each person relates to a fix set of spaces over time (same school, bus, bar) and gets in contact with everyone sharing this space; no contamination due to left germs.
10
125.0
1

TEXTBOX
664
343
814
361
Age model
10
53.0
1

SLIDER
848
703
940
736
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
938
703
1030
736
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
1030
703
1122
736
density-factor-workplaces
density-factor-workplaces
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
1124
703
1236
736
density-factor-public-leisure
density-factor-public-leisure
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
1240
704
1355
737
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
572
702
747
735
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
984
global-confinement-measures
global-confinement-measures
"none" "total-lockdown" "lockdown-10-5"
0

PLOT
10
681
518
831
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
1351
640
1470
700
#essential-shops-gp
17.0
1
0
Number

SLIDER
1357
704
1476
737
density-factor-essential-shops
density-factor-essential-shops
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
1482
705
1636
738
density-factor-non-essential-shops
density-factor-non-essential-shops
0
1
0.6
0.01
1
NIL
HORIZONTAL

INPUTBOX
1469
640
1598
700
#non-essential-shops-gp
34.0
1
0
Number

INPUTBOX
755
640
851
700
#hospital-gp
3.0
1
0
Number

SLIDER
754
703
849
736
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
918
362
1168
395
probability-hospital-personel
probability-hospital-personel
0
1
0.026
0.01
1
NIL
HORIZONTAL

SLIDER
922
399
1171
432
probability-school-personel
probability-school-personel
0
1
0.028
0.01
1
NIL
HORIZONTAL

SLIDER
920
434
1168
467
probability-university-personel
probability-university-personel
0
1
0.005
0.01
1
NIL
HORIZONTAL

SLIDER
922
472
1167
505
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
1073
closed-workplaces?
closed-workplaces?
1
1
-1000

SWITCH
1609
1160
1831
1193
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
206
105
241
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
662
48
765
81
debug?
debug?
1
1
-1000

TEXTBOX
1203
30
1482
58
Disease Model
14
15.0
1

TEXTBOX
1198
74
1348
92
Time between transitions
10
15.0
1

INPUTBOX
1199
92
1442
152
infection-to-asymptomatic-contagiousness
8.0
1
0
Number

INPUTBOX
1447
93
1784
153
asympomatic-contagiousness-to-symptomatic-contagiousness
16.0
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
0.1
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
10
15.0
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
569
225
719
248
Household Model
14
53.0
1

MONITOR
742
288
911
333
Adults rooming together
count houses-hosting-adults2
17
1
11

MONITOR
1004
288
1112
333
Retired couples
count houses-hosting-retired-couple
17
1
11

MONITOR
918
288
998
333
Family
count houses-hosting-family
17
1
11

MONITOR
1120
288
1295
333
Multi-generational living
count houses-hosting-multiple-generations
17
1
11

TEXTBOX
2663
592
2818
632
Migration model
14
35.0
1

SLIDER
2933
587
3190
620
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
2933
628
3191
661
probability-getting-back-when-abroad
probability-getting-back-when-abroad
0
1
0.13
0.01
1
NIL
HORIZONTAL

SWITCH
2802
587
2914
620
migration?
migration?
1
1
-1000

SLIDER
3640
623
3888
656
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
518
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
1127
NIL
closed-schools?
17
1
11

SWITCH
1612
1042
1834
1075
is-closing-school-when-any-reported-case-measure?
is-closing-school-when-any-reported-case-measure?
1
1
-1000

SLIDER
658
398
906
431
ratio-family-homes
ratio-family-homes
0
1
0.344
0.01
1
NIL
HORIZONTAL

SLIDER
1612
938
1840
971
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
105.0
1

TEXTBOX
1524
970
1633
1023
(fired when any condition is met)
9
105.0
1

SLIDER
1852
938
2120
971
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
1853
977
2122
1038
#days-trigger-non-essential-business-closing-measure
10000.0
1
0
Number

MONITOR
1851
1079
2124
1124
NIL
closed-non-essential?
17
1
11

SLIDER
658
362
910
395
ratio-adults-homes
ratio-adults-homes
0
1
0.309
0.01
1
NIL
HORIZONTAL

SLIDER
658
432
906
465
ratio-retired-couple-homes
ratio-retired-couple-homes
0
1
0.298
0.01
1
NIL
HORIZONTAL

SLIDER
657
470
909
503
ratio-multi-generational-homes
ratio-multi-generational-homes
0
1
0.049
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
0.41
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
23.0
1

TEXTBOX
789
1308
1013
1337
Distribution of government subsidy
11
23.0
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
0.21
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
0.34
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
0.34
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
564
253
724
298
household-profiles
household-profiles
"custom" "Belgium" "Canada" "Germany" "France" "Italy" "Korea South" "Netherlands" "Norway" "Spain" "Singapore" "Sweden" "United Kingdom" "U.S.A."
5

SLIDER
1928
604
2215
637
ratio-population-randomly-tested-daily
ratio-population-randomly-tested-daily
0
1
0.05
0.01
1
NIL
HORIZONTAL

SWITCH
1928
678
2218
711
test-workplace-of-confirmed-people?
test-workplace-of-confirmed-people?
1
1
-1000

SWITCH
1928
641
2217
674
test-home-of-confirmed-people?
test-home-of-confirmed-people?
1
1
-1000

TEXTBOX
1930
580
2080
598
Testing
11
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
1.7
0.1
1
NIL
HORIZONTAL

SWITCH
768
48
897
81
static-seed?
static-seed?
1
1
-1000

CHOOSER
548
89
790
134
preset-scenario
preset-scenario
"default-scenario" "scenario-1-zero-action-scandinavia" "scenario-1-closing-schools-and-uni" "scenario-1-work-at-home-only" "scenario-1-closing-all" "scenario-3-random-test-20" "scenario-3-app-test-60" "scenario-3-app-test-80" "scenario-3-app-test-100" "economic-scenario-1-baseline" "economic-scenario-2-infections" "economic-scenario-3-lockdown" "economic-scenario-4-wages" "app-test-scenario-5-1K" "scenario-6-default" "no-action-scandinavia-2.5K" "one-family" "scenario-9-smart-testing"
17

MONITOR
743
243
831
288
#children
count children
17
1
11

MONITOR
839
242
910
287
#students
count students
17
1
11

MONITOR
909
242
975
287
#workers
count workers
17
1
11

MONITOR
974
242
1033
287
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
Closing schools\n
11
105.0
1

TEXTBOX
1932
913
2082
931
Closing workplaces
11
105.0
1

TEXTBOX
1679
1136
1829
1154
Universities
11
105.0
1

TEXTBOX
922
342
1072
360
Worker distribution
10
53.0
1

TEXTBOX
1233
167
1368
210
Distribution of disease evolution
10
15.0
1

TEXTBOX
557
635
756
710
Density factors:\nRelative proximity between individuals within an activity type (impacts contamination risks).
10
125.0
1

TEXTBOX
2669
736
2830
764
Transport Model
14
35.0
1

TEXTBOX
3195
933
3356
961
Risks of becoming sick when travelling locally
11
35.0
1

TEXTBOX
2238
756
2413
787
All people at home are tested if one is confirmed sick.
9
105.0
1

TEXTBOX
2237
794
2419
823
All people at work are tested if one is confirmed sick.
9
105.0
1

TEXTBOX
2204
916
2354
937
Closing global
11
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
808
97
897
130
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
2708
628
2914
661
probability-going-abroad
probability-going-abroad
0
1
0.03
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
898
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
2207
1065
2562
1098
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
2211
1015
2361
1033
Social distancing
10
105.0
1

SLIDER
2207
1032
2561
1065
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
2207
1098
2361
1143
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
10.0
0.5
1
NIL
HORIZONTAL

SLIDER
2364
484
2589
517
mean-social-distance-profile
mean-social-distance-profile
0
1
0.29
0.01
1
NIL
HORIZONTAL

INPUTBOX
564
362
644
425
#households
345.0
1
0
Number

MONITOR
564
305
639
350
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
11.0
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
847
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
2597
484
2855
517
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
2360
1098
2458
1143
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

BUTTON
548
141
614
174
import
ask-user-for-import-file\nload-scenario-from-file
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
619
141
688
174
export
ask-user-for-export-file\nsave-world-state
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
1208
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
1582
535
1739
580
NIL
hospital-effectiveness
17
1
11

SLIDER
1928
862
2222
895
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
2654
847
2908
880
ratio-motorized-transport-to-work
ratio-motorized-transport-to-work
0
1
0.618
0.01
1
NIL
HORIZONTAL

SLIDER
2655
768
2909
801
ratio-motorized-transport-to-school
ratio-motorized-transport-to-school
0
1
0.194
0.01
1
NIL
HORIZONTAL

SLIDER
2964
727
3212
760
ratio-workers-and-retired-owning-cars
ratio-workers-and-retired-owning-cars
0
1
0.478
0.01
1
NIL
HORIZONTAL

SLIDER
2655
807
2908
840
ratio-motorized-transport-to-university
ratio-motorized-transport-to-university
0
1
0.304
0.01
1
NIL
HORIZONTAL

SLIDER
2656
887
2910
920
ratio-motorized-transport-to-hospital
ratio-motorized-transport-to-hospital
0
1
1.0
0.01
1
NIL
HORIZONTAL

INPUTBOX
2632
1235
2788
1295
#max-people-per-bus
20.0
1
0
Number

MONITOR
2890
1186
3055
1231
#people-staying-out-queuing
count people with [stayed-out-queuing-for-bus?]
17
1
11

SLIDER
3186
971
3411
1004
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
3186
1014
3411
1047
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
3187
1054
3411
1087
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
2763
1186
2887
1231
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
10
248
102
283
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
2360
35
2510
80
set_national_culture
set_national_culture
"Custom" "Belgium" "Canada" "Germany" "France" "Italy" "Korea South" "Netherlands" "Norway" "Spain" "Singapore" "Sweden" "United Kingdom" "U.S.A."
5

SLIDER
2364
112
2538
145
uncertainty-avoidance
uncertainty-avoidance
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
2547
110
2736
143
individualism-vs-collectivism
individualism-vs-collectivism
0
100
76.0
1
1
NIL
HORIZONTAL

SLIDER
2365
153
2537
186
power-distance
power-distance
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
2547
157
2736
190
indulgence-vs-restraint
indulgence-vs-restraint
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
2365
202
2539
235
masculinity-vs-femininity
masculinity-vs-femininity
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
2550
202
2736
235
long-vs-short-termism
long-vs-short-termism
0
100
61.0
1
1
NIL
HORIZONTAL

SLIDER
2599
267
2722
300
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
2367
268
2590
301
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
2365
336
2537
369
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
2547
336
2719
369
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
2362
13
2483
37
Cultural Model
14
83.0
1

SLIDER
1862
1293
2170
1326
ratio-of-people-using-the-tracking-app
ratio-of-people-using-the-tracking-app
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
1166
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
0.76
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
2325
1234
2480
1294
#days-recording-tracking
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
10
288
103
323
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
10
328
101
361
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
2365
376
2538
409
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
2364
88
2698
115
Hofstede dimension settings
11
83.0
1

TEXTBOX
2367
248
2564
278
Agent value system settings
11
83.0
1

TEXTBOX
2370
313
2560
331
Agent need system settings
11
83.0
1

INPUTBOX
914
38
1027
98
#random-seed
1.0
1
0
Number

CHOOSER
2794
63
2996
108
network-generation-method
network-generation-method
"random" "value-similarity"
1

TEXTBOX
2798
27
2986
65
Social Network Model
14
115.0
1

SLIDER
2794
113
3038
146
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
2794
154
3082
187
percentage-of-agents-with-random-link
percentage-of-agents-with-random-link
0
1
0.14
0.01
1
NIL
HORIZONTAL

SLIDER
1865
1253
2162
1286
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
2797
194
2954
227
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
2183
1353
2423
1398
standard anxiety avoidance of people
mean [importance-weight-safety + \nimportance-weight-risk-avoidance +\nimportance-weight-compliance] of people
4
1
11

MONITOR
2187
1302
2422
1347
anxiety-avoidance of app users
mean [importance-weight-safety + \nimportance-weight-risk-avoidance +\nimportance-weight-compliance] of app-users
3
1
11

BUTTON
659
303
722
336
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
1678
1829
2254
2025
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
2370
425
2642
455
Agent social distancing settings
11
83.0
1

SLIDER
3189
1118
3375
1151
solo-transport-costs
solo-transport-costs
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
3189
1155
3376
1188
public-transport-costs
public-transport-costs
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
3191
1197
3376
1230
car-sharing-costs
car-sharing-costs
0
2
1.0
0.01
1
NIL
HORIZONTAL

PLOT
1486
2032
1944
2182
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
1490
1867
1668
1900
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

SLIDER
1639
702
1802
735
density-factor-public-transport
density-factor-public-transport
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1640
671
1802
704
density-factor-shared-cars
density-factor-shared-cars
0
1
0.5
0.01
1
NIL
HORIZONTAL

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
32
14.0
1

TEXTBOX
1942
1228
2157
1254
Smartphone apps
11
105.0
1

SWITCH
2365
444
2689
477
make-social-distance-profile-value-based?
make-social-distance-profile-value-based?
0
1
-1000

MONITOR
1580
434
1764
479
NIL
#healthy-hospital-personel
17
1
11

MONITOR
1582
488
1745
533
NIL
#sick-hospital-personel
17
1
11

SLIDER
1448
1977
1668
2010
government-sector-subsidy-ratio
government-sector-subsidy-ratio
0
1
0.0
0.01
1
NIL
HORIZONTAL

PLOT
1951
2032
2386
2182
Macro Economic Model - Central Bank
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
"reserve-of-capital" 1.0 0 -16777216 true "" "plot sum [reserve-of-capital] of central-banks"
"total-credit" 1.0 0 -13345367 true "" "plot sum [total-credit] of central-banks"

PLOT
2267
1830
2806
2024
Macro Economic Model - Debt
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
"agriculture-essential" 1.0 0 -16777216 true "" "plot total-debt-agriculture-essential"
"agriculture-luxury" 1.0 0 -13345367 true "" "plot total-debt-agriculture-luxury"
"manufacturing-essential" 1.0 0 -955883 true "" "plot total-debt-manufacturing-essential"
"manufacturing-luxury" 1.0 0 -13840069 true "" "plot total-debt-manufacturing-luxury"
"services-essential" 1.0 0 -2674135 true "" "plot total-debt-services-essential"
"services-luxury" 1.0 0 -8630108 true "" "plot total-debt-services-luxury"
"education-research" 1.0 0 -13791810 true "" "plot total-debt-education-research"
"households-sector" 1.0 0 -6459832 true "" "plot total-debt-households-sector"

PLOT
2395
2032
2807
2182
Macro Economic Model - Government Debt
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
"debt" 1.0 0 -16777216 true "" "plot total-debt-government-sector"

SLIDER
1363
1903
1668
1936
services-luxury-ratio-of-expenditures-when-closed
services-luxury-ratio-of-expenditures-when-closed
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
1367
1940
1668
1973
services-luxury-ratio-of-income-when-closed
services-luxury-ratio-of-income-when-closed
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1861
1387
2048
1420
ratio-young-with-phones
ratio-young-with-phones
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1861
1423
2050
1456
ratio-retired-with-phones
ratio-retired-with-phones
0
1
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
2059
1387
2168
1432
#phone-owners
count people with [has-mobile-phone?]
17
1
11

MONITOR
2059
1431
2168
1476
ratio-phone-owners
count people with [has-mobile-phone?] / count people
17
1
11

SLIDER
1488
1830
1668
1863
interest-rate-by-tick
interest-rate-by-tick
0
0.01
0.001
0.0001
1
NIL
HORIZONTAL

SLIDER
920
510
1169
543
probability-public-transport-personel
probability-public-transport-personel
0
1
0.02
0.001
1
NIL
HORIZONTAL

SLIDER
1179
509
1455
542
probability-shared-cars-personel
probability-shared-cars-personel
0
1
0.02
0.001
1
NIL
HORIZONTAL

MONITOR
1065
2005
1195
2050
NIL
#public-transport-workers
17
1
11

CHOOSER
2085
342
2223
387
disease-fsm-model
disease-fsm-model
"assocc" "oxford"
1

MONITOR
2085
404
2142
449
NIL
r0
17
1
11

INPUTBOX
2367
850
2458
910
#available-tests
50.0
1
0
Number

SWITCH
1928
715
2219
748
prioritize-testing-health-care?
prioritize-testing-health-care?
0
1
-1000

BUTTON
12
168
104
201
1 Day run
if slice-of-the-day = \"morning\" [go]\nwhile [slice-of-the-day != \"morning\"] [go]
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
1928
784
2220
817
do-not-test-youth?
do-not-test-youth?
0
1
-1000

SWITCH
1928
823
2222
856
only-test-retirees-with-extra-tests?
only-test-retirees-with-extra-tests?
1
1
-1000

MONITOR
1759
1340
1854
1385
non isolators
count should-be-isolators with [current-activity != my-home and current-activity != my-hospital and current-activity != away-gathering-point]
17
1
11

MONITOR
1639
1340
1755
1385
Should be isolating
count should-be-isolators
17
1
11

MONITOR
3057
1187
3175
1232
NIL
#users-in-buses
17
1
11

SWITCH
1607
1293
1854
1326
food-delivered-to-isolators?
food-delivered-to-isolators?
0
1
-1000

PLOT
1088
1180
1576
1330
Self-isolation
time
#people
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"breaking isolation" 1.0 0 -2674135 true "" "plot count people with [is-officially-asked-to-quarantine? and not is-in-quarantine?]"
"of. quarantiners" 1.0 0 -11085214 true "" "plot count people with [is-officially-asked-to-quarantine?]"
"online supplying" 1.0 0 -7171555 true "" "plot  #delivered-supply-proposed-this-tick"
"sick quarantiners" 1.0 0 -13791810 true "" "plot count people with [is-officially-asked-to-quarantine? and is-believing-to-be-infected?]"

TEXTBOX
1678
1227
1828
1245
Self-isolation
11
105.0
1

SLIDER
1607
1422
1785
1455
ratio-self-quarantining-when-a-family-member-is-symptomatic
ratio-self-quarantining-when-a-family-member-is-symptomatic
0
1
1.0
0.01
1
NIL
HORIZONTAL

SWITCH
1609
1253
1854
1286
is-infected-and-their-families-requested-to-stay-at-home?
is-infected-and-their-families-requested-to-stay-at-home?
1
1
-1000

SLIDER
2917
769
3210
802
ratio-motorized-transport-to-my-non-essential-shop
ratio-motorized-transport-to-my-non-essential-shop
0
1
0.464
0.01
1
NIL
HORIZONTAL

SLIDER
2919
848
3211
881
ratio-motorized-transport-to-essential-shops
ratio-motorized-transport-to-essential-shops
0
1
0.464
0.01
1
NIL
HORIZONTAL

SLIDER
2922
886
3212
919
ratio-motorized-transport-to-public-leisure
ratio-motorized-transport-to-public-leisure
0
1
0.49
0.01
1
NIL
HORIZONTAL

SLIDER
2919
809
3211
842
ratio-motorized-transport-to-private-leisure
ratio-motorized-transport-to-private-leisure
0
1
0.49
0.01
1
NIL
HORIZONTAL

SWITCH
1608
1460
1800
1493
all-self-isolate-for-35-days-when-first-hitting-2%-infected?
all-self-isolate-for-35-days-when-first-hitting-2%-infected?
1
1
-1000

MONITOR
1811
1456
1863
1501
NIL
start-tick-of-global-quarantine
17
1
11

PLOT
1577
283
1763
422
hospitals
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
"#taken-beds" 1.0 0 -2674135 true "" "plot #taken-hospital-beds"
"#available-beds" 1.0 0 -10899396 true "" "plot #beds-available-for-admission"

SLIDER
2229
1446
2510
1479
ratio-self-quarantining-when-symptomatic
ratio-self-quarantining-when-symptomatic
0
1
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
2387
949
2537
994
NIL
is-hard-lockdown-active?
17
1
11

CHOOSER
2424
1302
2584
1347
when-is-tracing-app-active?
when-is-tracing-app-active?
"always" "never" "7-days-before-end-of-global-quarantine" "at-end-of-global-quarantine"
1

SWITCH
2229
1413
2511
1446
is-tracking-app-testing-immediately-recursive?
is-tracking-app-testing-immediately-recursive?
0
1
-1000

MONITOR
2434
1360
2567
1405
NIL
is-tracing-app-active?
17
1
11

MONITOR
2486
1248
2586
1293
#people-ever-recorded-as-positive-in-the-app
count people-having-ever-been-recorded-as-positive-in-the-app
17
1
11

CHOOSER
2297
693
2568
738
when-is-daily-testing-applied?
when-is-daily-testing-applied?
"always" "never" "7-days-before-end-of-global-quarantine" "at-end-of-global-quarantine"
1

MONITOR
2242
640
2414
685
NIL
#tests-used-by-daily-testing
17
1
11

MONITOR
1803
533
2011
578
NIL
#infected-by-asymptomatic-people
17
1
11

SWITCH
1927
750
2219
783
prioritize-testing-education?
prioritize-testing-education?
0
1
-1000

PLOT
2634
927
3153
1169
users of transport
NIL
NIL
0.0
100.0
0.0
300.0
true
true
"" ""
PENS
"total bus users" 1.0 0 -11221820 true "" "plot #users-in-buses"
"total shared cars users" 1.0 0 -10899396 true "" "plot #users-in-shared-cars"
"total solo transport users" 1.0 0 -8431303 true "" "plot #users-solo"
"workers bus users" 1.0 0 -2674135 true "" "plot #workers-public-transport"
"workers solo" 1.0 0 -5825686 true "" "plot #workers-solo-transport"

CHOOSER
2788
715
2951
760
Transport-parameters-of
Transport-parameters-of
"custom" "Belgium" "Germany" "France" "Italy" "Korea South" "Netherlands" "Norway" "Spain" "Singapore" "Sweden" "United Kingdom"
3

MONITOR
1207
2006
1308
2051
NIL
#shared-cars-workers
17
1
11

INPUTBOX
2635
1185
2755
1245
#bus-per-timeslot
0.0
1
0
Number

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
  <experiment name="social-cultural-model-experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count people with [is-infected?]</metric>
    <metric>#dead-people</metric>
    <metric>count people with [is-I-apply-social-distancing?]</metric>
    <metric>count people with [is-at-home?]</metric>
    <metric>count people with [is-working-at-home?]</metric>
    <metric>count workers</metric>
    <metric>count retireds</metric>
    <metric>count students</metric>
    <metric>count children</metric>
    <metric>count people with [[is-school?] of current-activity]</metric>
    <metric>count people with [[is-hospital?] of current-activity]</metric>
    <metric>count people with [[is-university?] of current-activity = "university"]</metric>
    <metric>count people with [is-at-work?]</metric>
    <metric>count people with [[is-public-leisure?] of current-activity]</metric>
    <metric>count people with [[is-private-leisure?] of current-activity = "private-leisure"]</metric>
    <metric>count people with [[is-essential-shop?] of current-activity]</metric>
    <metric>count people with [[is-private-leisure?] of current-activity]</metric>
    <metric>mean [sleep-satisfaction-level] of people</metric>
    <metric>mean [conformity-satisfaction-level] of people</metric>
    <metric>mean [risk-avoidance-satisfaction-level] of people</metric>
    <metric>mean [compliance-satisfaction-level] of people</metric>
    <metric>mean [belonging-satisfaction-level] of people</metric>
    <metric>mean [leisure-satisfaction-level] of people</metric>
    <metric>mean [luxury-satisfaction-level] of people</metric>
    <metric>mean [autonomy-satisfaction-level] of people</metric>
    <metric>mean [quality-of-life-indicator] of people</metric>
    <metric>median [quality-of-life-indicator] of people</metric>
    <metric>max [quality-of-life-indicator] of people</metric>
    <metric>min [quality-of-life-indicator] of people</metric>
    <enumeratedValueSet variable="set_national_culture">
      <value value="&quot;Netherlands&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-of-rations-in-non-essential-shops">
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#max-people-per-bus">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor-reduction-probability-transmission-young">
      <value value="0.69"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="goods-produced-by-work-performed">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="preset-scenario">
      <value value="&quot;default-scenario&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-stock-of-goods-in-a-shop">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-private-leisure">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-getting-back-when-abroad">
      <value value="0.13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-to-terminal">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="with-infected?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="indulgence-vs-restraint">
      <value value="68"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="static-seed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-users-of-the-tracking-app">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-non-essential-shops">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-school-subsidy">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-system-calibration-factor">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-self-recovery-symptoms">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-multi-generational-homes">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#households">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-confinement-measures">
      <value value="&quot;none&quot;"/>
      <value value="&quot;total-lockdown&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-wage-paid-by-the-government">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-public-leisure">
      <value value="0.51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#universities-gp">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-dev-social-distance-profile">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-std-dev">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close-services-luxury?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#workplaces-gp">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="individualism-vs-collectivism">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-student-public-transport">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty-avoidance">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-retired">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infection-to-asymptomatic-contagiousness">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-family-homes">
      <value value="0.23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-hospital-personel">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-survival-needs">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#bus-per-timeslot">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="migration?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="masculinity-vs-femininity">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-of-rations-in-essential-shops">
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="terminal-to-death">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-news-watchers">
      <value value="0.76"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-closing-school-when-any-reported-case-measure?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-workplaces">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="owning-solo-transportation-probability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-children-public-transport">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survival-multiplier">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-unavoidable-death-old">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-population-randomly-tested-daily">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="long-vs-short-termism">
      <value value="67"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-social-distance-profile">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-students">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retirees-subsidy">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-anxiety-avoidance-users">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-workers">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="daily-risk-believe-experiencing-fake-symptoms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="productivity-at-home">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-shared-car">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#essential-shops-gp">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#hospital-gp">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-worker-public-transport">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="make-social-distance-profile-value-based?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probably-contagion-mitigation-from-social-distancing">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-working-from-home-recommended?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-non-essential-closing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-population-daily-immunity-testing">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-school-closing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="asympomatic-contagiousness-to-symptomatic-contagiousness">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-student-shared-car">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-workplace-of-confirmed-people?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-students-subsidy">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-hospital">
      <value value="0.81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-social-distancing-measure">
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maslow-multiplier">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#private-leisure-gp">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days-of-rations-bought">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-schools">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-adults-homes">
      <value value="0.49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-unavoidable-death">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-hospital-subsidy">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-shopkeeper">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="workers-wages">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-essential-shops">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-in-shared-cars">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-school-personel">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-workplaces">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-worker-shared-car">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-universities">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-going-abroad">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-university-subsidy">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-infection-when-abroad">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#beds-in-hospital">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-self-recovery-symptoms-old">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power-distance">
      <value value="38"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-non-essential-shops">
      <value value="0.83"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peer-group-friend-links">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="import-scenario-name">
      <value value="&quot;output/done3.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-essential-shops">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-children-shared-car">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="productivity-factor-when-not-at-work">
      <value value="0.79"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="unit-price-of-goods">
      <value value="1.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-generation-method">
      <value value="&quot;random&quot;"/>
      <value value="&quot;value-similarity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="symptomatic-to-critical-or-heal">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-homes">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#public-leisure-gp">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#days-tracking">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-recorvery-if-treated-old">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#random-seed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="propagation-risk">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="preset-profiles">
      <value value="&quot;scandinavia&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-travelling-propagation">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#schools-gp">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="closed-universities?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-initial-reserve-of-capital">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-pays-wages?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-workers">
      <value value="0.41"/>
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
    <enumeratedValueSet variable="percentage-of-agents-with-random-link">
      <value value="0.1"/>
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
    <enumeratedValueSet variable="#non-essential-shops-gp">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-when-queuing">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-public-transport">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-in-public-transport">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-university-personel">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#days-trigger-school-closing-measure">
      <value value="10000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="smart-testing" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="600"/>
    <metric>count people with [is-infected?]</metric>
    <metric>#dead-people</metric>
    <metric>count people with [is-officially-asked-to-quarantine?]</metric>
    <metric>count people with [is-officially-asked-to-quarantine? and not is-in-quarantine?]</metric>
    <metric>#tests-performed</metric>
    <metric>r0</metric>
    <enumeratedValueSet variable="prioritize-testing-education?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prioritize-testing-health-care?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-infected-and-their-families-requested-to-stay-at-home?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-is-daily-testing-applied?">
      <value value="&quot;always&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-delivered-to-isolators?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-not-test-youth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="only-test-retirees-with-extra-tests?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-population-randomly-tested-daily">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#available-tests">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#days-recording-tracking">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-of-rations-in-non-essential-shops">
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#max-people-per-bus">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor-reduction-probability-transmission-young">
      <value value="0.69"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="goods-produced-by-work-performed">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="preset-scenario">
      <value value="&quot;scenario-9-smart-testing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-stock-of-goods-in-a-shop">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-private-leisure">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-to-terminal">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-getting-back-when-abroad">
      <value value="0.13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="with-infected?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="indulgence-vs-restraint">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="static-seed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set_national_culture">
      <value value="&quot;Italy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-self-isolate-for-35-days-when-first-hitting-2%-infected?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-non-essential-shops">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-school-subsidy">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-system-calibration-factor">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-self-recovery-symptoms">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-multi-generational-homes">
      <value value="0.049"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#households">
      <value value="345"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-confinement-measures">
      <value value="&quot;none&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-wage-paid-by-the-government">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-public-leisure">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#universities-gp">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="std-dev-social-distance-profile">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-std-dev">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="close-services-luxury?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#workplaces-gp">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="individualism-vs-collectivism">
      <value value="76"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-student-public-transport">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty-avoidance">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-retired">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infection-to-asymptomatic-contagiousness">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-family-homes">
      <value value="0.344"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-hospital-personel">
      <value value="0.026"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-sector-subsidy-ratio">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight-survival-needs">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#bus-per-timeslot">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="migration?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="masculinity-vs-femininity">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="services-luxury-ratio-of-income-when-closed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-of-rations-in-essential-shops">
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="terminal-to-death">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-people-using-the-tracking-app">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-news-watchers">
      <value value="0.76"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-closing-school-when-any-reported-case-measure?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-tracking-app-testing-immediately-recursive?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-workplaces">
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="owning-solo-transportation-probability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-children-public-transport">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survival-multiplier">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-unavoidable-death-old">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="long-vs-short-termism">
      <value value="61"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="disease-fsm-model">
      <value value="&quot;oxford&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-social-distance-profile">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-students">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-with-phones">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retirees-subsidy">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-of-anxiety-avoidance-users">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="starting-amount-of-capital-workers">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="daily-risk-believe-experiencing-fake-symptoms">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="productivity-at-home">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-shared-car">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#essential-shops-gp">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#hospital-gp">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-worker-public-transport">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="make-social-distance-profile-value-based?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probably-contagion-mitigation-from-social-distancing">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="is-working-from-home-recommended?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-is-tracing-app-active?">
      <value value="&quot;never&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="services-luxury-ratio-of-expenditures-when-closed">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-profiles">
      <value value="&quot;Italy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-non-essential-closing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interest-rate-by-tick">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-population-daily-immunity-testing">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="asympomatic-contagiousness-to-symptomatic-contagiousness">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-school-closing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-student-shared-car">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-workplace-of-confirmed-people?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-students-subsidy">
      <value value="0.34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-hospital">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-omniscious-infected-that-trigger-social-distancing-measure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maslow-multiplier">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#private-leisure-gp">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="days-of-rations-bought">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-schools">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-adults-homes">
      <value value="0.309"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-unavoidable-death">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-hospital-subsidy">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-self-quarantining-when-symptomatic">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-shopkeeper">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="workers-wages">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-essential-shops">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-in-shared-cars">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-school-personel">
      <value value="0.028"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-workplaces">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-worker-shared-car">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-young-with-phones">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-universities">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-going-abroad">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-infection-when-abroad">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-university-subsidy">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#beds-in-hospital">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-self-recovery-symptoms-old">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="power-distance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-non-essential-shops">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="peer-group-friend-links">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-essential-shops">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-children-shared-car">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="productivity-factor-when-not-at-work">
      <value value="0.79"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="unit-price-of-goods">
      <value value="1.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-generation-method">
      <value value="&quot;value-similarity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="symptomatic-to-critical-or-heal">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-factor-homes">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#public-leisure-gp">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-recorvery-if-treated-old">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="propagation-risk">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#random-seed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-travelling-propagation">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="#schools-gp">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="closed-universities?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-initial-reserve-of-capital">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-pays-wages?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-self-quarantining-when-a-family-member-is-symptomatic">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-tax-on-workers">
      <value value="0.41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="animate?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-recorvery-if-treated">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-couple-homes">
      <value value="0.298"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-of-agents-with-random-link">
      <value value="0.14"/>
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
    <enumeratedValueSet variable="#non-essential-shops-gp">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-retired-public-transport">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-when-queuing">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density-in-public-transport">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-university-personel">
      <value value="0.005"/>
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
