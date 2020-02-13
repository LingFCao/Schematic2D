function internalSetStraightTextBox( obj, startPosition, endPosition )
% A simple straight line with an annotation object attached at the
% ''startPosition'' end of the line. 
% 
defaultAnnotation    = obj.textBox;
defaultLineContainer = obj.rightLine; 

% we assumed that the underlying 'Figure' canvas uses 'normalized' as
% the distance metric. And we assume that ''startPosition'' and
% ''endPosition'' are within bounds of the axes' limit

GrandAxes = obj.parent.parent.Axs;
GrandFigu = obj.parent.parent.Fig;

x0 = GrandAxes.XLim(1);
x1 = GrandAxes.XLim(2); 

y0 = GrandAxes.YLim(1); 
y1 = GrandAxes.YLim(2);

x  = startPosition(1); 
y  = startPosition(2); 

% 
currentAxesPos = GrandAxes.Position;
% currentFiguPos = GrandFigu.Position;


BoxDim = zeros(1, 4);
BoxDim(1) = currentAxesPos(1) + (x - x0) * currentAxesPos(3) / (x1 - x0);
BoxDim(2) = currentAxesPos(2) + (y - y0) * currentAxesPos(4) / (y1 - y0);
BoxDim(3) =  obj.defaultTextBoxWidth * currentAxesPos(3)  / (x1 - x0);
BoxDim(4) = obj.defaultTextBoxHeight * currentAxesPos(4)  / (y1 - y0);


% check if we have an current text-box
if isempty( defaultAnnotation )
    % move the computation box to the middle
    BoxDim(1:2) = BoxDim(1:2) - .5 * BoxDim(3:4);
    defaultAnnotation = annotation( GrandFigu, ...
        'textbox', BoxDim, ...
        'visible',  'off', ...
        'pickableparts', 'none', ...
        'HorizontalAlignment', 'center', ...
        'verticalalignment', 'middle', ...
        obj.currentTextboxPropertyCell{:});
    obj.textBox = defaultAnnotation;
else
    % modify the width and the height of 'BoxDim'
    %currentBoxPos = obj.textBox.Position;
    BoxDim(3) = obj.defaultTextBoxWidth  * currentAxesPos(3)  / (x1 - x0);
    BoxDim(4) = obj.defaultTextBoxHeight * currentAxesPos(4)  / (y1 - y0);
    BoxDim(1:2) = BoxDim(1:2) - .5 * BoxDim(3:4);
    set( defaultAnnotation, 'position', BoxDim );
end
xdata = [ startPosition(1), endPosition(1) ];
ydata = [ startPosition(2), endPosition(2) ];
if isempty( defaultLineContainer )
    defaultLineContainer = plot( GrandAxes, ...
        xdata, ...
        ydata, ...
        'visible', 'off', ...
        'pickableparts', 'none', ...
        obj.CurrentPropertyCell{:} );
    obj.rightLine = defaultLineContainer;
else
    set( defaultLineContainer, 'xdata', xdata, 'ydata', ydata);
end

% revert back to the original limit
obj.parent.parent.aaxis( [x0, x1, y0, y1] );

