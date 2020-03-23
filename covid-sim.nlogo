__includes ["people_management.nls" "global_metrics.nls" "contagion.nls" "gathering_points.nls" "public_measures.nls"]
breed [people person]

globals [
  slice-of-the-day
  day-of-the-week
  is-lockdown-active?
  current-day
  #dead-people
  #dead-retired
]

to setup
  clear-all
  reset-ticks
  random-seed 47822
  set slice-of-the-day "morning"
  set day-of-the-week "monday"
  set current-day 0
  set #dead-people 0

  file-close-all

  file-open "debug.log"

  setup-activities
  create-all-people

  ask one-of people [set-infection-status "infected"]
  update-display

  ask links[hide-link]

  set is-lockdown-active? false
end

to go
  tick
  spread-contagion
  update-within-agent-disease-status
  update-people-epistemic-status
  perform-people-activities
  update-display
  update-time
end
to debug-show [object]
  if debug [
    file-show object
  ]
end
to debug-print [object]
  if debug [
    print object
  ]

end

to update-time
  if slice-of-the-day = "morning"
  [set slice-of-the-day "afternoon" stop]

  if slice-of-the-day = "afternoon"
  [set slice-of-the-day "evening" stop]

  if slice-of-the-day = "evening"
  [
    set slice-of-the-day "morning"
    set current-day current-day + 1
    ask gathering-points [
      if available-food > 0 [
        set available-food available-food - 1
      ]
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
  ask people [
    perform-activity
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

to-report allowed-move?
  report can-move? 1 and (not any? gathering-points-on patch-ahead 1 or member? current-activity gathering-points-on patch-ahead 1)
end

to dump-to-file
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
0
0
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
go\nif not any? people with [infection-status = \"infected\"]\n[stop]
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
1267
255
1482
300
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
0.33
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
533
222
726
255
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
532
260
718
293
mortality-rate-old
mortality-rate-old
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
725
222
901
255
recovery-rate-young
recovery-rate-young
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
725
260
900
293
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
908
222
1095
255
propagation-risk-yom
propagation-risk-yom
0
1
1.0
0.01
1
NIL
HORIZONTAL

CHOOSER
1378
11
1516
56
disease-model
disease-model
"markovian"
0

SWITCH
645
13
916
46
propagation-by-coordinates-proximity?
propagation-by-coordinates-proximity?
1
1
-1000

INPUTBOX
921
14
1076
74
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
"Infected" 1.0 0 -2674135 true "" "plot count people with [infection-status = \"infected\"]"
"EInfected" 1.0 0 -1604481 true "" "plot count people with [epistemic-infection-status = \"infected\"]"
"EImmune" 1.0 0 -5516827 true "" "plot count people with [epistemic-infection-status = \"immune\"]"
"Inf. Retired" 1.0 0 -10141563 true "" "plot count people with [age = \"retired\" and infection-status = \"infected\"]"

TEXTBOX
536
25
930
67
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
1251
235
1401
253
Age model
11
0.0
1

INPUTBOX
1267
314
1320
374
#young
100.0
1
0
Number

INPUTBOX
1324
314
1390
374
#students
100.0
1
0
Number

INPUTBOX
1396
314
1451
374
#workers
100.0
1
0
Number

INPUTBOX
1455
314
1509
374
#retired
100.0
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
1228
324
1378
342
Quotas
9
0.0
1

SWITCH
644
63
855
96
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
1198
450
1348
468
Measures:
11
0.0
1

CHOOSER
1208
472
1351
517
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
false
"" ""
PENS
"lockdown" 1.0 0 -2674135 true "" "plot ifelse-value is-lockdown-active? [1] [0]"
"infringement" 1.0 0 -7500403 true "" "plot count people with [not ([gathering-type] of current-activity = \"home\")] / count people"

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
0.71
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
0.0
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
0.0
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
1.0
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
0.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
861
78
1046
96
Turtle means working from home\n
11
0.0
1

BUTTON
1409
143
1507
176
dump-to-file
dump-to-file
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
1357
505
1519
538
closed-workplaces?
closed-workplaces?
1
1
-1000

SWITCH
1357
538
1518
571
closed-schools?
closed-schools?
1
1
-1000

SWITCH
1357
472
1520
505
closed-universities?
closed-universities?
1
1
-1000

SLIDER
1546
259
1724
292
ratio-safety-belonging
ratio-safety-belonging
0
1
0.8
0.01
1
NIL
HORIZONTAL

TEXTBOX
1528
235
1678
253
Needs model
11
0.0
1

SWITCH
1088
19
1199
52
animate?
animate?
0
1
-1000

CHOOSER
972
159
1126
204
household-composition
household-composition
"segregated-elderly" "balanced-mix"
1

MONITOR
10
768
102
813
NIL
#dead-people
17
1
11

MONITOR
106
768
198
813
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
1093
69
1196
102
debug
debug
1
1
-1000

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
true
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
