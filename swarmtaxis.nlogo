extensions [pathdir]

breed [slimes slime]
breed [lights light]
breed [snakes snake]
breed [tracers tracer]
globals[rand deepestpoint x y pingduration delta randomness list-of-otherslimes gradient list-of-angles testfreq  lowest_gradient swarmsize highest_gradient wifirange convergence ]
patches-own[pingfreq temp tempxcor tempycor temp1xcor temp1ycor]
slimes-own[mode state popmem pop sensorrange coherencecount randomcount avoidcount forwardcount ping pingcounter]
lights-own[]
snakes-own[pcolorhere]

to setup

  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set wifirange 2.5
  set swarmsize swarmsize_input

  setup-slimes
  setup-lights
  ;trace
  setup-snakes
  set convergence 0

end

to setup-aux [swarmsize_in]
  __clear-all-and-reset-ticks
  set wifirange 2.5
  set swarmsize swarmsize_in

  setup-slimes
  setup-lights
  ;trace
  setup-snakes
  set convergence 0

end


to setup-slimes
  set x min-pxcor + 1
  set y 0

  create-slimes swarmsize
  [
    setxy x y
    set mode "shadow"
    set color red
    ask slimes
    [
      set heading random 360
      fd random-float 0.4
    ]
    set randomcount 0
    set avoidcount 0
    set forwardcount 0
    set coherencecount 0

  ]

end

to setup-lights

  ask patch 6 -7
  [
    sprout-lights 1
    [
      set color yellow
      hide-turtle
    ]
    set pcolor yellow
  ]

  ask patch 6 7
  [
    sprout-lights 1
    [
      set color red
      hide-turtle
    ]
    set pcolor red
  ]

end

to setup-snakes
  create-snakes 1
  [
    set color blue
    set shape "circle"
    set size 1
    set pen-size 3
    set pcolorhere 0
    findpossnake
    ask patch-here [set pcolor green]
    pen-down
  ]
end
;========================ITERATION===================================================

to iterate
  tick

  ask slimes
  [
    ping-behavior
    setlightanddark
    if state = "forwardstate" [forwardstate]
    set pop (count other slimes with [distance myself <= wifirange and ping = 1])
    let check 0
    if detect-neighbours
    [
      set state "avoidstate"
    ]

    ifelse (pop - popmem > 0)
    [
      set state "randomstate"
      set check check + 1
      if check > 1 [show check]
    ]
    [
      if (pop < alpha)
      [
        set state "coherencestate"
        set check check + 1
      ]
    ]

    if state = "coherencestate" [coherencestate]
    if state = "randomstate" [randomstate]
    if state = "avoidstate" [avoidstate]
    set popmem pop
  ]


  findpossnake

  if [pcolorhere] of one-of snakes = 1
  [
    set convergence 1
    ; this is o1
    stop
  ]
  if [pcolorhere] of one-of snakes = 2
  [
    set convergence 2
    ; this is o2
    stop
  ]
end

to forwardstate
  fd 0.1
  set forwardcount forwardcount + 1
end

to coherencestate
  set heading heading + 180
  set state "forwardstate"
  set coherencecount coherencecount + 1
end

to randomstate
  set heading random 360
  set state "forwardstate"
  set randomcount randomcount + 1
end


to avoidstate
  set heading towards one-of other slimes with [distance myself <= [sensorrange] of myself] + 180
  set avoidcount avoidcount + 1
  set state "forwardstate"
end



to setlightanddark
  let myheading heading
  set heading towards one-of lights with [pcolor = yellow]
  let distancetolight distance  one-of lights with [pcolor = yellow]
  let tempcount 0
  while [distancetolight >= 1]
  [
    ask patch-ahead distancetolight
    [
      if any? other slimes-here
      [set tempcount tempcount + 1]
    ]
    set distancetolight distancetolight - 1
  ]
  ifelse tempcount = 0
  [
    set color green
    set mode "light"
    set sensorrange 0.51
  ]
  [
    set color red
    set mode "shadow"
    set sensorrange 0.4
  ]
  set heading myheading
end

to ping-behavior
  set ping 1
  ;      ifelse random 100 <= 100 - pingloss
  ;      [
  ;        set ping 1
  ;      ]
  ;      [
  ;        set ping 0
  ;      ]
end


to-report detect-neighbours
  ifelse any? other slimes with [distance myself <= [sensorrange] of myself][report true][report false]
end

to findpossnake
  let meanposx mean [xcor] of slimes
  let meanposy mean [ycor] of slimes
  ask snakes
  [
    setxy meanposx meanposy
    if [pcolor] of patch-here = yellow [set pcolorhere 1]
    if [pcolor] of patch-here = red [set pcolorhere 2]
  ]
  ; write-snakes
end

;to write-tracers
;  file-open (word "ping-loss-data_swarmtaxis/myfile-test-pingloss_" pingloss ".csv")
;  file-type [xcor] of one-of tracers
;  file-type " "
;  file-type [ycor] of one-of tracers
;  file-type " "
;  file-close
;end

;to write-snakes
;  file-open (word "ping-loss-data_swarmtaxis/myfile-test-pingloss_" pingloss ".csv")
;  file-type [xcor] of one-of snakes
;  file-type " "
;  file-type [ycor] of one-of snakes
;  file-type " "
;  let sum_be sumalldistances
;  file-type sum_be
;  file-type " "
;  file-close
;end

to-report sumalldistances
  let sumall 0
  ask snakes [ask slimes[set sumall sumall + distance myself ]]
  report sumall
end


to test
  let i swarm-lower-limit
  while [i <= swarm-upper-limit]
  [
    set swarmsize i
    ;if (file-exists? (word "security-data_swarmtaxis/experiment_results_" swarmsize ".csv"))[file-delete (word "security-data_swarmtaxis/experiment_results_" swarmsize ".csv")]
    if (file-exists? (word "security-data_swarmtaxis/ticks_" swarmsize ".csv"))[file-delete (word "security-data_swarmtaxis/ticks_" swarmsize ".csv")]
    set alpha (swarmsize - 1)
    file-open (word "security-data_swarmtaxis/ticks_" swarmsize ".csv")
    file-type "swarmsize"
    file-type ","
    file-type "objective"
    file-type ","
    file-print "ticks"
    file-close

    repeat num-reps
    [
      setup-aux swarmsize
      while[convergence = 0 and ticks <= 100000][iterate]

      file-open (word "security-data_swarmtaxis/ticks_" swarmsize ".csv")
      file-type count slimes
      file-type ","
      file-type convergence
      file-type ","
      file-print ticks
      file-close
    ]
    set i i + swarm-size-increment
  ]
end






to analyse
  ; this procedure will generate the necessary folder structure
  ; for aleatory uncertainty analysis
  let samples (list 200)  ; 150 200 250 300 ]

  while [length(samples) > 0]
  [
    let n first(samples)
    set num-reps n

    let subsets n-values 20 [i -> i]
    while [length(subsets) > 0]
    [

      let s first(subsets) + 1
      let this-sample n-values n [i -> i]

      while [length(this-sample) > 0]
      [

        let this-n first(this-sample) + 1
        let dir-name (word "security-data_swarmtaxis/" n "/" s "/" this-n "")
        let file-name (word dir-name "/ticks.csv")

        if (file-exists? file-name)[file-delete file-name]
        pathdir:create dir-name
        file-open file-name
        file-print "swarmsize,objective,ticks"
        file-close

        set swarmsize 17
        set alpha (swarmsize - 1)
;
;        repeat num-reps
;        [
        setup-aux swarmsize
        while[convergence = 0 and ticks <= 100000][iterate]

        file-open file-name
        file-type count slimes
        file-type ","
        file-type convergence
        file-type ","
        file-print ticks
        file-close
;        ]

        set this-sample but-first(this-sample)

      ]
      set subsets but-first(subsets)

    ]
    set samples but-first(samples)

  ]

end









;to trace
; let meanposx mean [xcor] of slimes
; let meanposy mean [ycor] of slimes
;create-tracers 1[
;  set color green
;  setxy meanposx meanposy]
;;  write-tracers
;  ask tracers
;  [set heading towards one-of patches with [pcolor = yellow]
;    pen-down
;    while [distance one-of patches with [pcolor = yellow] >= 1]
;    [fd 1]
;;   write-tracers
;  file-open (word "ping-loss-data_swarmtaxis/myfile-test-pingloss_" pingloss ".csv")
;  file-print " "
;  file-close
;  pen-up
;  ]
;end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
830
631
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
74
74
141
107
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
75
121
138
154
go
iterate
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
80
227
137
272
ticks
ticks
17
1
11

BUTTON
78
172
141
205
step
iterate
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
24
288
197
321
swarmsize_input
swarmsize_input
0
120
17.0
1
1
NIL
HORIZONTAL

SLIDER
28
377
200
410
swarm-lower-limit
swarm-lower-limit
0
100
7.0
1
1
NIL
HORIZONTAL

SLIDER
28
427
200
460
swarm-upper-limit
swarm-upper-limit
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
30
480
202
513
num-reps
num-reps
0
1000
175.0
1
1
NIL
HORIZONTAL

SLIDER
31
543
203
576
swarm-size-increment
swarm-size-increment
0
10
1.0
1
1
NIL
HORIZONTAL

BUTTON
8
221
71
254
NIL
test
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
30
338
202
371
alpha
alpha
0
100
16.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
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
