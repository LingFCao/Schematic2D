function internalMoveData( obj, TranslationVector )
% Translate the raw data while remain within bounds.
% 
% 
xmin = min( obj.xRawData ); 
xmax = max( obj.xRawData );
ymin = min( obj.yRawData );
ymax = max( obj.yRawData );
% By bounding the data with a box, the idea is that one can infer if the
% translation vector would produce out-of-bound effect.

x0 = obj.parent.parent.Axs.XLim(1); 
x1 = obj.parent.parent.Axs.XLim(2); 

y0 = obj.parent.parent.Axs.YLim(1); 
y1 = obj.parent.parent.Axs.YLim(2);

dataStillInRange = ...
    ( x0 <= xmin + TranslationVector(1) && xmax + TranslationVector(1) <= x1 ) && ...
    ( y0 <= ymin + TranslationVector(2) && ymax + TranslationVector(2) <= y1 );
if dataStillInRange
    % only modify the data if such translation would be in-bound
    obj.xRawData = obj.xRawData + TranslationVector(1);
    obj.yRawData = obj.yRawData + TranslationVector(2);
    % apply the same translation to the anchor
    obj.position.setCircleGeometry( obj.position.position + TranslationVector );
    notify(obj, 'RawDataModified');
else
    % else determine the 'largest' translation vector so that the
    % translated data are in bound
    
    % this can be done in a couple of ways. One approach is to check the
    % intersection with the bounding lines of the canvas
    
    % obtain the centroid and the direction of the line characterised by
    % the 'x' and 'v'
%     numberOfElement = numel( obj.xRawData );
%     xcentroid = sum( obj.xRawData ) / numberOfElement;
%     ycentroid = sum( obj.yRawData ) / numberOfElement;
%     x = [xcentroid, ycentroid]; 
%     v = TranslationVector;
%     
%     % first test x = x0, x1
%     [y, u] = getLineParameter( x0, 'x' );
%     [ crossed, lambda ] = getSignedDistance(x, v, y, u);

     % just throw an error! Damn it
     warning( ...
         'SchematicTools:Shape:OutOfBound', ...
         'current translation produces out-of-bound effect' );
     return;

end

% function [y0, t0] = getLineParameter( value, type )
% if strcmpi( type, 'x')
%     % here we have the line x = value
%     y0 = [value, -1E+10];
%     t0 = [0, 1];
% elseif strcmpi( type, 'y' )
%     % here we have the line y = value
%     y0 = [-1E+10, x0];
%     t0 = [1, 0];
% else
%     error('illegal type name');
% end
% 
% function [crossed, lambda] = getSignedDistance( x, v, y, u )
% % check if the line(x, v) crosses with the line(y, u), and determine the
% % signed distance between them if they do.
% ut = u * [0, -1; +1, 0]';
% crossed = abs( dot(v, ut) ) > 0;
% if ~crossed, lambda = 0; return; end
% % the signed distance is given by (xintercept - x) dot v / norm(v)
% lambda = -dot( x - y, ut ) * norm( v ) / dot( v, ut );