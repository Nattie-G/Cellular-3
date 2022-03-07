# Cellular-3
my 2nd foray into cellular automata  
![demo-gif](./demo.gif)  
gravity demo

this was my attempt at writing a universal cellular automata capable of running any 'atomic' ruleset given a constrained number of states.
after quickly discovering the performance limitations of a naive approach to CA implementation I, decided to write the engine to split work across 4 threads.
I have since learned that the 'real' solution to the problem would be to write a shader that can leverage the parallel comupting power of the gpu.
Nevertheless this provided a substantial speed-up to processing large grid areas and was an educational process for me to learn about writing multi-threaded programs.
included are a couple scripts to help create rule definitions. There was once also a web-based visual rule editor that I quickly hacked to
export rule files in a compatible format to run with this. Unfortunately I lost track of this. I may try to recreate that functionality in the future.

## installing & running
this toy was made with LÖVE: https://love2d.org/ you will need to install it to your computer to try it out.
Once you have you may simply `git clone` this repo `cd` into it and run `love .`

## controls
- click and drag with `LMB` to draw
- click and drag with `RMB` to pan the view
- `1`, `2`, `3` & `0` to select the cell type to draw
- scroll with mouse wheel to zoom in and out
- `r` to reset the simulation (sets each cell randomly)
- `p` to pause (useful to draw fun stuff in GoL)
