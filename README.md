# Speciale-code

Repo containing code used in the development of the 2022 thesis "Shielded AI for Hybrid Systems"
The code is broadly organised in two folders, one for each of the two case studies, but I have made no special effort at this point to doccument it. Doccumentation will therefore be sparse and inconsistent, apologies. 

## UPPAAL Files

Files that end in .xml are made in some version of UPPAAL STRATEGO. The best bet is stratego-10 Beta-2, though that might not be the case for older files. 
Forward-compatibility is not guaranteed as per my experience.

Files ending in .strategy.json are exported strategies generated in STRATEGO. 

## Julia and Pluto Notebooks

Files written in julia have the extension .jl.

[Pluto Notebooks](https://github.com/fonsp/Pluto.jl) are a reactive notebook environment for the programming language Julia. Since they can also be run as plain Julia, Pluto files also just end in .jl, but they have some distinctive headers, and comments containing GUIDs over every code block. 

Running a pluto notebook as pure Julia may not produce a very exciting result. They can be opened by installing and running the Pluto notebook for Julia. I had a look at making them available online, but this is not yet supported in any sane way. 

One of the ways Pluto Notebooks ensure their reproducibility, is by not really supporting external libraries other than for packages. I have needed to have some code re-use however, so I do some imports from the "My Library" folder. These imports should just work, as long as you preserve relative file paths. 
Code in that folder is simply copy-pasted from other notebooks, which to no great surprise turned out to be a huge hassle whenever I had to make changes. 

## Jupyter Notebooks

Jupyter notebooks end in .ipynb and are mostly legacy notebooks for the P9 bouncing ball experiments. 

## UppaalExperiments folders

BB and RW both have a UPPAALEXPERIMENT folder. These folders have their own readme, but the gist is that they may be possible to run again, by changing a lot of hard-coded filepaths. The code is not written to be robust, readable or extensible however, so your mileage may vary.