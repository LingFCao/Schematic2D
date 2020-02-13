function internalSetStraight( obj, startPosition, endPosition )
% a simple straight line connecting from the position: 'startPosition' to
% 'endPosition'. Note that the two mandatory inputs must be numeric and are
% two-element vectors.
%
% Code updates the plot on the ''rightLine'' property ...

%
originalXLim = obj.parent.parent.Axs.XLim;
originalYLim = obj.parent.parent.Axs.YLim;

defaultLineContainer = obj.rightLine;
xdata = [ startPosition(1), endPosition(1) ];
ydata = [ startPosition(2), endPosition(2) ];
if isempty( defaultLineContainer )
    % if the container is empty, we create a plot object ...
    defaultLineContainer = plot( ...
        obj.parent.parent.Axs, ...
        xdata, ...
        ydata, ...
        'visible', 'off', ...
        'pickableparts', 'none', ...
        obj.CurrentPropertyCell{:} );
    % save reference to the rightLine property. 
    obj.rightLine = defaultLineContainer;
else
    % set the 'xdata', 'ydata' properties (assume that the initialization
    % is already done with the user-specified property-cell ... 
    set( defaultLineContainer, 'xdata', xdata, 'ydata', ydata );
end

obj.parent.parent.aaxis( [originalXLim, originalYLim] );
