# Schematic2D

This is a MATLAB implementation of a drawing canvas which provides the tools needed to create professional-looking diagrams.
The motivation of creating such a tool arose from the frustration of finding a suitable software that a) is simple to use (in the 
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
                                  step 3) user modifies the auto-generated code with various properties adjusted to suit their liking
                                                             |
                                                             |
                                                            \ /
                                  step 4) compile the code to reflect those changes on the canvas 
                                                             |
                                                             |
                                                            \ /
                                  step 5) repeat step 1).

The implementation uses MATLAB's OOP and can be called from the command window by creating the Schematic2D object. Note if no input arguement 
is passed to the constructor, the canvas will create a master folder on MATLAB's userpath to store the data. Moreover, three associated folders
will also be created. These are used to store the auto-generated MATLAB function script, script-generated data and image output. 
