function selectionAddAnchor(obj, AnchorCoord)
% Normally, this is induced by the mouse-click call-back

% first one increments the 'selectionClickCount' property 
obj.selectionClickCount = obj.selectionClickCount + 1;
obj.selectionClickCount = 1 + mod( obj.selectionClickCount - 1, 2 );

% assume that the bline01 - 04 are initialized. If they are, we can do it
% separately

if obj.selectionClickCount == 1
    % this corresponds to the first click ... 
    obj.FirstAnchorPosition = AnchorCoord;
    
    % bring the stack to the front of any guides ... 
    if ~isempty( obj.arrowTextSchematicObj )
        obj.arrowTextSchematicObj.stacktop();
    end
    if ~isempty( obj.guideCircle )
        obj.guideCircle.stacktop();
    end
    
    % deactivate any previously selected objects ...
    notify( obj, 'deselectedObjects' );
else
    obj.FinalAnchorPosition = AnchorCoord;
end