breed[beetles beetle]
breed[pines pine]

beetles-own[age]
pines-own [age-tree Insecticide redness]
patches-own[hit]
globals [all-pines Insecticide-counter]


;================================
to setup
  ca

  setup-patches

  ask patches
  [let tree-1 count pines-here                                           ;find number of pine trees
     if tree-1 = 0
        [sprout-pines 0 + Tree-Density - random 1                                         ;plant number of starting pine trees based off of density slider
          [set shape "pine"
            set size 2.5 - random-float 2.5                                                  ;pine tree size
            set color rgb 0 110 0
            set age-tree random 100
            set Insecticide false
            set redness 0
            setxy pxcor + random-float 0.5 pycor + random-float 0.5        ;sightly randomize pine tree positions
            ]]
         ]
  set all-pines count pines
  set Insecticide-counter 0


  create-beetles 100
  [setup-beetles]

  reset-ticks
end
;================================


to setup-pines-seedling
   set shape "pine"
            set size 0.3
            set age-tree 0
            set color rgb 0 110 0
            set Insecticide false

            setxy pxcor + random-float 0.5 pycor + random-float 0.5 ;slightly randomize the tree position. This makes the forest look more natural but increase the max number of trees in a the simulation as each patch can have more than one trees.
end

to setup-beetles                         ; set up initial beetle features, in which all beetles are at the age of 0
    set color 1
    set shape "bark-beetle"
    set size 0.3
    setxy (random-float 3)(random-float 3)
    set age 0
end

to setup-patches                                           ;set patches to certain drought level
  ask patches [
    set pcolor 36 + random-float (0.5 + (0.5 * Severity-of-Drought))
    ]
end

;=================================


to go
  tick

  tree-age
  tree-death
  infest
  patch-count
  set-tree-color
  beetle-migrate
  temperature-control
  beetle-death
  seedling
  tree-thinning
  perscribed-burn
  apply-insecticide
  remove-insecticide

  if count beetles = 0 [user-message ("There are no bark beetles in this forest.") stop]
  if count pines < 10 [user-message ("There are too few pine trees to regenerate in this forest.") stop]
end


;==================================

to tree-age                                  ; pines have age that is imapacted  until size 2.5
  ask pines
  [if size < 2.5 [set size size + 0.1 set age-tree age-tree + 1]]
end

to tree-death                               ;natural mortality of trees
  ask pines
  [ if random 1000 < 10 [die]
  ]
end

to tree-thinning                               ;thinning of trees based on intensity specified by slider
  ask pines
  [if random 1000 < Thin * 10 [die]
  ]
end

to perscribed-burn
  ask pines
  [if Perform-Perscribed-Burn = true
    [if random 1000 < 500 and size < 1.0 or random 1000 < 500 and size > 2.25 [die]
    ]
  ]
end

to apply-insecticide
  ask pines
  [if random 1000 < Apply-Insecticide-to * 10 [set Insecticide true]
  ]
end

to patch-count                                ;count how many beetles on a patch, use the number of beetles to indicate severity of infestation
  ask patches
  [set hit 0
    let num-bug count beetles-here
    set hit (num-bug * (10 + (Severity-of-Drought * 5)))]
end


to set-tree-color                            ;determine severity of infestation. The number of beetles are associated to the tree color
  ask pines
  [set redness [hit] of patch-here
    ifelse redness > 175 and random 1000 < 450
         [die ask beetles-here [setxy (xcor + random-float 1) (ycor + random-float 1)]]
         [ set color rgb redness 110 0]
  ]
end

to seedling                                  ;seed new green trees at 3 percentage
  ask patches
  [let tree-1 count pines-here
     if tree-1 = 0
     [if random 1000 < 30
     [let tree-ratio count pines / (count pines + 1)
        sprout-pines 0 + Tree-Density - random 2
        [setup-pines-seedling]
  ]]]

end


to infest ;Beetles detect trees avaiable in radius of 3. then migrate to one of the available pines.
  ask beetles
      [let target-tree one-of pines with [size > 0.75 and Insecticide = false and redness <= 175] in-radius 3 ;infest tree larger than 0.5 and without insecticide
  ifelse target-tree != nobody
    [face target-tree
      move-to target-tree
       hatch 2 [set age 0]                  ;If a beetle infests a mature tree, hatches 2 offspring and then dies.
          if random 500 < Temperature-Increase * 2 [hatch 1 [set age 0]] ;If temperature increases, hatch one more beetle at the defined rate.
          die
     ]
         [ set age age + 1]                      ;If a beetle does not infests a mature tree, age increases 1
  ]
end

to beetle-death
  ask beetles with [age >= 1] [die]           ;If beetles with age of 2 or older die.
end



to temperature-control                             ;Percentages of beetles die every year, related to the temperature increase.
  ask beetles
  [if random 100 > ((Temperature-Increase * 2) + 50)
    [die]]
end


to beetle-migrate
  ask beetles
  [
    setxy (xcor + random-float random 2) (ycor + random-float random 2)
    ]
end

to remove-insecticide
  ask pines
    [if Apply-Insecticide-to >= 1 [set Insecticide-counter Insecticide-counter + 1]
    ]
  ask pines
    [if Insecticide-counter >= 1 [set Insecticide false set Insecticide-counter 0]
    ]
end

; developed by Lin Xiang at Weber State University

;lxiang75@gmail.com ; linxiang@weber.edu
@#$#@#$#@
GRAPHICS-WINDOW
466
23
923
481
-1
-1
21.428571428571427
1
10
1
1
1
0
1
1
1
-10
10
-10
10
0
0
1
Years
5.0

BUTTON
343
228
441
277
Run Forever
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1154
490
1261
535
# of Beetles
count beetles
0
1
11

PLOT
950
62
1482
480
Mountain Pine Beetles (MPB) and Pine Tree Population Dynamics over Time
Years
# of BB and Trees
0.0
50.0
0.0
3500.0
true
true
"" ""
PENS
"MPB" 1.0 0 -10146808 true "plot count beetles" "plot count beetles"
"Pines" 1.0 0 -14439633 true "plot count pines" "plot count pines"

MONITOR
1267
490
1374
535
# of Pine trees
count pines
0
1
11

SLIDER
252
133
441
166
Temperature-Increase
Temperature-Increase
0
2
0.0
0.5
1
C
HORIZONTAL

TEXTBOX
12
10
280
28
Step 1: Adjust forest and climate dynamics
11
15.0
1

TEXTBOX
13
178
335
207
-------------------------------------------\nStep 2: Choose how long to run the simulation.
11
15.0
1

TEXTBOX
952
18
1465
67
---------------------------------------------\nStep 4: Observe the changes in the numbers of bark beetles and pine trees over time.
11
15.0
1

BUTTON
280
219
335
252
 + 1000
go\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
218
219
273
252
+ 500
go\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
92
219
147
252
+ 50
go\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
156
218
211
251
+ 100
go\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\ngo\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
155
259
210
292
To 500
go\nif ticks >= 500 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
92
259
147
292
To 250
go\nif ticks >= 250 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
29
231
84
276
+ 1 year
go\n\n
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
1041
489
1148
534
Years
ticks
17
1
11

BUTTON
30
92
218
167
Set/Reset Forest
resize-world (-1 * Forest-size) Forest-size (-1 * Forest-size) Forest-size\nset-patch-size 450 / (2 * Forest-size + 1)\n\nsetup
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
218
259
273
292
To 750
go\nif ticks >= 750 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
280
259
335
292
To 1000
go\nif ticks >= 1000 [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
251
36
440
69
Tree-Density
Tree-Density
1
3
1.0
1
1
tree(s) per patch
HORIZONTAL

SLIDER
248
446
436
479
Thin
Thin
0
100
0.0
1
1
% of trees
HORIZONTAL

SWITCH
248
350
436
383
Perform-Perscribed-Burn
Perform-Perscribed-Burn
1
1
-1000

SLIDER
248
398
437
431
Apply-Insecticide-to
Apply-Insecticide-to
0
75
0.0
1
1
% of trees
HORIZONTAL

TEXTBOX
18
306
355
342
---------------------------------------------\nStep 3: Select which management actions you would like to take
11
15.0
1

BUTTON
30
350
217
479
Stop All Management
set Apply-Insecticide-To 0\nset Thin 0\nset Perform-Perscribed-Burn false
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
29
38
218
83
Forest-Size
Forest-Size
5 6 7 8 9 10 11 12 13 14 15
5

CHOOSER
251
78
441
123
Severity-of-Drought
Severity-of-Drought
0 1 2 3
0

@#$#@#$#@
## Purpose
The purpose of this model is to simulate some of the basic, key relationships between Mountain Pine Beetle (MPB)s, pine forests, and active management and mitigation practices. Shifting forest and climate dynamics in turn alters MPB and pine populations. Likewise, performing management or mitigation actions impacts MPB and pine populations in the same or the following year. Population shifts in both species are represented over time in the graph displayed at the bottom of the model. Moreover, these shifts are depicted visually through agents, which randomly perform actions within the parameters they are given. 
## General
1.	**Pine trees:** Pine trees have age, size, and color qualities. As trees get older their size and age increases. As their age increase they are more prone to dying of natural causes. As their size increases,they are more prone to MPB infestations. The color of trees indicates the number of beetles infesting the tree. The redder a tree becomes, the more likely it is to die due to infestation. Once a tree dies it will disappear from the map. The starting number of pine trees is determined by the Forest-Size chooser and Tree-Density slider.
2.	**Host Trees:** Host trees are defined in this model as any tree with a size of over 0.75 and without insecticide on it. 
3.	**MPB Information:** MPBs can move up to 3 patches randomly in the forest every tick. We can consider each patch to be about 20 square meters. MPBs have a lifespan of 1 year (1 tick) and can produce 2 – 3 offspring in that year depending on climate conditions and whether they are able to locate a host tree. The starting number of MPBs is 100, which spawn near the center of the forest.
4.	**Ending the model:** The model will stop when either all the MPBs have died or there are 10 or fewer pine trees remaining in the forest. 
>Pay close attention to the number of pine trees present. Pine tree mortality is the primary indicator of a MPB epidemic (along with color change)!

## Forest and Climate Dynamics Section
1.	**Forest Size:** This chooser controls the number of patches in the forest. If each patch is 20 square meters, a forest with a size of 10 is about 10000 square meters, or around one hectare. Likewise, a forest with a size of 5 is around a quarter of a hectare and a forest with a size of 15 or around 2 hectares. 
2.	**Set/Reset Forest:** This button sets and resets the model, signaling the program to start over and perform startup actions such as spawning the pine trees and beetles. 
3.	**Tree-Density:** This slider determines the number of trees possible to spawn on a patch (or within 20 square meters). The higher the number of trees allowed to spawn, the denser the forest becomes, and the more likely MPBs are able to find a host tree. 
4.	**Severity-of-Drought:** This chooser simulates an increase in drought on a scale of 0 – 3. Patches become lighted in shade if a drought takes place—indicating dry ground. As drought severity increases, it takes fewer beetles to kill a host tree.  
5.	**Temperature-Increase:** This slider simulates a temperature increase of up to 2.0 *C. When temperature is increased, the MPBs have a chance to spawn more offspring. Likewise, fewer bark beetles die in winter (at the end of a tick) simulating how longer warm seasons and warmer winters might have a positive impact on MPB population and fecundity.  
  
>NOTE: No relationship is represented in the model between temperature and drought, though it is likely that there is a strong relationship in reality.

## Management Section 	
1.	**Stop-All-Management:** This button stops all management actions that take place after the current tick (year).
2.	**Perform-Prescribed-Burn:** This switch determines whether a simulated prescribed burn will take place in a given year. When the switch is on, trees smaller than 1.0 and greater than 2.25 have a 50% chance of being burned and dying. These trees are impacted because they would be the younger and oldest trees in the stand, and the most likely pines to die during a fire. 
3.	**Apply-Insecticide-to:** this slider controls what percentage of trees are sprayed with insecticide in any given year. Being sprayed with insecticide means a tree cannot be infested by MPB in that year. Insecticide wears off at the end of the year. 
4.	**Thin:** This slider indicates what percentage of pine trees are thinned in any given year. This type of thinning is known as selective thinning, whereby only certain trees with, typically, desirable qualities are removed from the system. In this model which trees are thinned is random, but normally thinning would be performed following a treatment plan with specific individuals or regions begin targeted. Thinning 100% of the forest, such as to simulate a clear cut, will end the simulation given that no pine trees remain. 


## Credits: 
Code and documentation adapted from Xiang, L. (2017). Bark Beetle Epidemic. Zoology Department, Weber State University, Ogden, UT.

[Bark Beetle Epidemic](https://www.modelingcommons.org/browse/one_model/5012#model_tabs_browse_info)

![NetLogo](http://ccl.northwestern.edu/netlogo/images/netlogo-title-new.jpg)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

3forest
false
0
Rectangle -6459832 true false 262 62 277 107
Polygon -7500403 true true 105 15 75 45 90 45 60 60 75 60 45 90 60 90 30 120 45 120 15 165 30 165 0 210 75 195 135 195 210 210 180 165 195 165 165 120 180 120 150 90 165 90 135 60 150 60 120 45 135 45
Polygon -14835848 false false 105 15 75 45 90 45 60 60 75 60 45 90 60 90 30 120 45 120 15 165 30 165 0 210 75 195 135 195 210 210 180 165 195 165 165 120 180 120 150 90 165 90 135 60 150 60 120 45 135 45
Polygon -7500403 true true 150 0 120 30 135 30 105 45 120 45 90 75 105 75 75 105 90 105 60 150 75 150 45 195 120 180 180 180 255 195 225 150 240 150 210 105 225 105 195 75 210 75 180 45 195 45 165 30 180 30
Polygon -14835848 false false 150 0 120 30 135 30 105 45 120 45 90 75 105 75 75 105 90 105 60 150 75 150 45 195 120 180 180 180 255 195 225 150 240 150 210 105 225 105 195 75 210 75 180 45 195 45 165 30 180 30
Polygon -6459832 true false 135 180 135 270 105 285 150 284 165 300 165 285 195 285 166 265 165 180
Polygon -6459832 true false 90 195 90 270 75 285 105 285 120 300 120 285 135 285 120 270 120 195
Polygon -7500403 true true 270 0 255 15 270 15 240 45 255 45 240 75 300 75 285 45 300 45 270 15 285 15
Polygon -14835848 false false 270 0 255 15 270 15 240 45 255 45 240 75 300 75 285 45 300 45 270 15 285 15

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bark-beetle
true
0
Polygon -7500403 true true 152 17 135 17 122 27 115 38 110 54 102 63 95 80 90 105 116 114 132 111 152 111
Polygon -7500403 true true 148 17 165 17 178 27 185 38 190 54 198 63 205 80 210 105 182 114 168 111 148 111
Polygon -7500403 true true 151 109 124 109 106 117 97 119 91 126 92 167 90 203 90 243 100 262 117 280 133 290 148 292 152 292
Polygon -7500403 true true 149 109 176 109 194 117 203 119 209 126 208 167 210 203 210 243 200 262 183 280 167 290 152 292 148 292
Polygon -7500403 true true 128 27 114 21 111 23 109 26 108 30 99 30 93 23 87 20 85 29 93 37 109 33 115 27
Polygon -7500403 true true 172 27 186 21 189 23 191 26 192 30 201 30 207 23 213 20 215 29 207 37 191 33 185 27
Polygon -7500403 true true 95 92 84 85 80 85 77 81 68 65 63 63 55 51 46 49 45 50 51 52 48 60 51 56 54 58 63 69 62 71 78 89 78 93 93 103
Polygon -7500403 true true 205 92 216 85 220 85 223 81 232 65 237 63 245 51 254 49 255 50 249 52 252 60 249 56 246 58 237 69 238 71 222 89 222 93 207 103
Polygon -7500403 true true 94 127 84 122 44 141 39 139 41 142 35 142 42 145 24 166 14 172 18 181 17 173 25 168 27 171 29 164 43 148 46 149 77 130 93 148
Polygon -7500403 true true 206 127 216 122 256 141 261 139 259 142 265 142 258 145 276 166 286 172 282 181 283 173 275 168 273 171 271 164 257 148 254 149 223 130 207 148
Polygon -7500403 true true 94 183 76 194 62 224 58 227 65 223 62 239 55 252 59 249 63 254 62 243 67 247 69 224 76 205 95 200
Polygon -7500403 true true 206 183 224 194 238 224 242 227 235 223 238 239 245 252 241 249 237 254 238 243 233 247 231 224 224 205 205 200

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

pine
false
0
Polygon -7500403 true true 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 210 180 210 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30 150 0
Rectangle -6459832 true false 135 210 165 300
Polygon -14835848 false false 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 210 180 210 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30

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

spruce1
false
0
Polygon -7500403 true true 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 270 195 270 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30 150 0
Polygon -14835848 false false 150 0 135 30 105 60 120 60 105 90 75 120 90 120 75 150 45 180 60 180 45 210 15 240 105 270 195 270 285 240 255 210 240 180 255 180 225 150 210 120 225 120 195 90 180 60 195 60 165 30

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

tree2
false
0
Polygon -7500403 true true 59 170 74 169 88 173 115 168 136 176 156 176 188 173 222 157 261 151 287 138 286 111 266 94 248 83 246 73 225 60 205 56 186 50 175 42 155 42 134 41 119 37 92 46 70 60 53 83 35 98 24 115 11 142 21 160 34 166 46 167
Polygon -6459832 true false 99 157 110 165 102 152 106 151 117 170 127 179 122 162 114 147 118 145 128 166 127 150 131 150 134 172 134 188 139 206 140 175 138 151 131 136 135 130 144 156 142 140 146 132 151 132 148 150 148 172 145 190 157 166 157 153 162 150 162 162 170 148 174 149 161 171 155 183 169 173 181 155 185 151 178 168 189 160 197 159 180 173 156 192 150 221 153 249 158 267 159 287 161 298 128 298 133 272 137 247 135 224 128 206 124 193 114 176 97 160

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
NetLogo 6.4.0
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
