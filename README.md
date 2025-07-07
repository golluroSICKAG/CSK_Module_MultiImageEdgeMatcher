# CSK_Module_MultiImageEdgeMatcher

Module to provide 2D Image EdgeMatcher functionality to search for objects within an image and align it accordingly.  

![plot](./docu/media/UI_Screenshot.png)

## How to Run

The app includes an intuitive GUI.  
For further information check out the [documentation](https://raw.githack.com/SICKAppSpaceCodingStarterKit/CSK_Module_MultiImageEdgeMatcher/main/docu/CSK_Module_MultiImageEdgeMatcher.html) in the folder "docu".

## Known issues
- Even if found multiple matches, module will only provide the aligned image / transformation of first match  
- Limited to CPU processing unit (no FPGA support)  

## Information

Tested on  

|Device|Firmware|Module version|
|--|--|--|
|SICK AppEngine|V1.7.0|V2.1.0|
|SIM1012|V2.4.2|V2.0.1|
|SIM2x00|V1.8.0|V2.0.1|
|SIM1012|V2.4.2|V2.0.0|
|SICK AppEngine|V1.7.0|V2.0.0|
|SICK AppEngine|V1.5.0|V1.0.0|

This module is part of the SICK AppSpace Coding Starter Kit developing approach.  
It is programmed in an object oriented way. Some of the modules use kind of "classes" in Lua to make it possible to reuse code / classes in other projects.  
In general it is not neccessary to code this way, but the architecture of this app can serve as a sample to be used especially for bigger projects and to make it easier to share code.  
Please check the [documentation](https://github.com/SICKAppSpaceCodingStarterKit/.github/blob/main/docu/SICKAppSpaceCodingStarterKit_Documentation.md) of CSK for further information.  

## Topics

Coding Starter Kit, CSK, Module, SICK-AppSpace, 2D, Image, Edge, Matcher
