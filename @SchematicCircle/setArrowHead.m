function setArrowHead( obj, HeadPosition, HeadOrientation, HeadSize )
% create a triangular arrow head orientated 'HeadOrientation' with size
% 'HeadSize'. Note that 'HeadSize' is the physical size of the arrow
% (relative to the coordinate in the Axes object).
% 
%        height         .   
%                  .  
%              .          .    arrow pointing this way
%               .         
%                .          .
%     width       .     .
%                  . 

% HeadSize = [width, height]

HeadNormal = HeadOrientation * [0, -1; +1, 0]';
Width      = HeadSize(1);
Height     = HeadSize(2);

WestPoint  = HeadPosition + .5 * Width * HeadNormal;
EastPoint  = HeadPosition - .5 * Width * HeadNormal;
NorthPoint = HeadPosition + Height * HeadOrientation;

% we create a patch object and fill the face with a specified color using
% the 'fillColor' property of the class. 
xdata = [ WestPoint(1);NorthPoint(1);EastPoint(1)];
ydata = [ WestPoint(2);NorthPoint(2);EastPoint(2)];

if isempty( obj.arrow )
    obj.arrow = patch( ...
        obj.parent.parent.Axs, ...
        'xdata', xdata, ...
        'ydata', ydata, ...
        'facecolor', obj.fillColor, ...
        'edgecolor', obj.fillColor, ...
        'visible', 'off', ...
        'pickableparts', 'none');
else
    % update the patch's x and y data
    set( obj.arrow, 'xdata', xdata, 'ydata', ydata, 'visible', 'off', 'facecolor', obj.fillColor, 'edgecolor', obj.fillColor);
end


