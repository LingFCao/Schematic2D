function internalSaveCapturedSelection( obj, ~, ~ )
% similar to the 'pdf' routine (actually, I would advise you to check out
% the comments there if you wish to know more), this callback outputs the
% image defined by the selection vector to a '.jpg' file. However, the
% quality suffers greatly so only use it in conjunction with the 'import'
% routine, so that it is used as a background only.

string = obj.editableobj.String;
if strcmpi( string, '' ), return; end


% if no such vector exists, we simply set the default to be the 'xlim' and
% 'ylim' values of the canvas' parent ... 
if isempty( obj.internalCapturedSelection )
    xlim = obj.parent.Axs.XLim;
    ylim = obj.parent.Axs.YLim;
    obj.internalCapturedSelection = [xlim(1), ylim(1), xlim(2), ylim(2)];
end
% work with jpeg here. Although other type is possible ... 
extensionType = '.jpg';

filename = [ obj.workImagePath, string, extensionType ];

% briefly disable the axes before we attempt to capture ... 
set( obj.parent.Axs, 'visible', 'off' );

% the captured object is stored as a movie 'frame' - not the most high
% quality capture ever ... 
obj.captureRect( obj.internalCapturedSelection );

% finally, we simply write the captured frame as an image file

obj.writeCapturedFrameAsImageFile( filename );

set( obj.parent.Axs,  'visible', 'on'  );
set( obj.savepanel,   'visible', 'off' );
set( obj.editableobj,  'string',    '' );

obj.internalCapturedSelection = [];