function internalImportImageCallback( obj, ~, ~ )
% The basic idea is that once the 'push-button' is pressed and the user
% gets to choose what image file (supports '.jpg' atm ) to import. 

[file, path] = uigetfile( ...
    {'*.jpg', '*.JPG'}, 'import as');

if (isnumeric(file) && file == 0) || ...
        (isnumeric(path) && path == 0 ), return; end
% reset imager before reading file ... 
obj.internalImageReset();

% concatenate the two char-vectors to produce the filename ...
filename = [ path, file ];

% read and scale to the current axes 
obj.parent.readAndScaleImage( filename );
% preset the alpha level of the image to .25
obj.parent.setImageProperties( 'alphadata', .75 );
% 
obj.imager.readImageFromFilename( filename );


% stack the imported image to the 'bottom' 
uistack( obj.parent.imageObj, 'bottom');