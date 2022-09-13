# Schematic2D

[![View Schematic2D on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/74258-schematic2d)

This is a MATLAB implementation of a drawing canvas which provides the tools needed to create professional-looking diagrams.
The motivation for creating such a tool arose from the frustration of finding a suitable software that a) is simple to use (in the 
sense of containing no frills, just the absolute essential) and b) has the ability to have absolute control over the image output. 

For this purpose, I have proposed a hybrid workflow in which creation-efforts can be shared by a combination of user-interaction 
with the canvas ( meaning, user creates the diagram interactively) and code-based editing work (users are able to manuipulate the underlying
objects and modify their properties). Schematically, this hybrid workflow is shown below:

                          
                                  step 1) interactive work (based on user interaction with the canvas)
                                                             |
                                                             |
                                                            \ /
                                  step 2) output file to an editable script (in MATLAB, the tool produces the function m-script) 
                                                             |
                                                             |
                                                            \ /
                                  step 3) user modifies the auto-generated code with various properties adjusted to suit their needs
                                                             |
                                                             |
                                                            \ /
                                  step 4) compile the code to reflect those changes on the canvas 
                                                             |
                                                             |
                                                            \ /
                                  step 5) repeat step 1).

The implementation uses MATLAB's OOP and can be called from the command window by creating the Schematic2D object. Note if no input arguement is passed to the constructor, the canvas will create a master folder on MATLAB's userpath to store the data. Moreover, three associated folders will also be created. These are used to store the auto-generated MATLAB function scripts, script-generated data and image output.

The main mode of interaction is with a series of keyboard presses, which serve to activate the various commands on the canvas. To see what these commands are, user can bring forth the 'key' pushbutton located at the top of the canvas. In addition of checking the various assigned keys, one can also remap those keys to meet their needs. However, care should be exercised to avoid duplicating keys for the same command. 
