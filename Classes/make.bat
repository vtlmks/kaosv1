@echo off

echo Classes:

echo Assembling button.class ..
nasm -f aout -o buttonclass.aout button\button.s
aoutconv buttonclass.aout button.class > nul:

echo Assembling checkbox.class ..
nasm -f aout -o checkboxclass.aout checkbox\checkbox.s
aoutconv checkboxclass.aout checkbox.class > nul:

echo Assembling group.class ..
nasm -f aout -o groupclass.aout group\group.s
aoutconv groupclass.aout group.class > nul:

echo Assembling spacer.class ..
nasm -f aout -o spacerclass.aout spacer\spacer.s
aoutconv spacerclass.aout spacer.class > nul:

echo Assembling window.class ..
nasm -f aout -o windowclass.aout window\window.s
aoutconv windowclass.aout window.class > nul:

echo Assembling listview.class ..
nasm -f aout -o listviewclass.aout listview\listview.s
aoutconv listviewclass.aout listview.class > nul:

echo Assembling cycle.class ..
nasm -f aout -o cycleclass.aout cycle\cycle.s
aoutconv cycleclass.aout cycle.class > nul:

echo Assembling image.class ..
nasm -f aout -o imageclass.aout image\image.s
aoutconv imageclass.aout image.class > nul:

echo Assembling menu.class ..
nasm -f aout -o menuclass.aout menu\menu.s
aoutconv menuclass.aout menu.class > nul:

echo Assembling mx.class ..
nasm -f aout -o mxclass.aout mx\mx.s
aoutconv mxclass.aout mx.class > nul:

echo Assembling progressbar.class ..
nasm -f aout -o progressbar.aout progressbar\progressbar.s
aoutconv progressbar.aout progressbar.class > nul:

echo Assembling scroller.class ..
nasm -f aout -o scrollerclass.aout scroller\scroller.s
aoutconv scrollerclass.aout scroller.class > nul:

echo Assembling slider.class ..
nasm -f aout -o sliderclass.aout slider\slider.s
aoutconv sliderclass.aout slider.class > nul:

echo Assembling string.class ..
nasm -f aout -o stringclass.aout string\string.s
aoutconv stringclass.aout string.class > nul:

echo Assembling tree.class ..
nasm -f aout -o treeclass.aout tree\tree.s
aoutconv treeclass.aout tree.class > nul:

move *.class ..\	> nul:
del *.aout > nul:
