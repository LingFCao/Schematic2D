function internalSelectionReset( obj )
% reset any previously created properties

% reset the original captured area ... 
obj.internalCapturedSelection = [];

% notify other sources that a 'deselection' event has occured 
notify( obj, 'deselectedObjects' );

% also we interrupt any selection lines still being drawn on the canvas ... 
notify( obj, 'DeactivateSelectionLine');
