function internalTextBringContexturePanel( obj, pos )
% whenever a click is registered on the canvas, we automatically bring out
% the contexture panel (assuming that the staic text is appropriately
% updated ).
% To achieve this, two things need to occur. First, we draw the annotation
% object about where the point is registered (the 'pos' input). 

% next, we bring front the contexture ui-panel, so user can enter text.

% depending on the currentMode 
if strcmpi( obj.currentMode, 'text' )
    % note that 'plainTextSchematicObj' will have already initialized, so
    % one only needs to update its position 
    obj.plainTextSchematicObj.draw( 'start', pos, 'end', pos );
    obj.plainTextSchematicObj.setText('');
elseif strcmpi( obj.currentMode, 'arrowtext' )
    % it is most probable that the input 'pos' is the initial pos 
    obj.arrowTextSchematicObj.draw( 'start', pos, 'end', obj.FinalAnchorPosition, 'arrowscale', .075);
    obj.arrowTextSchematicObj.setText('');
end

%% create or update current save window (it is no longer fitting to call it a savepanel, but whatever )

x0 = obj.parent.Axs.XLim(1); 
x1 = obj.parent.Axs.XLim(2); 

y0 = obj.parent.Axs.YLim(1);
y1 = obj.parent.Axs.YLim(2);

% get currentAxesPosition and currentFiguPosition ... 
currentAxesPosition = obj.parent.Axs.Position;
currentFiguPosition = obj.parent.Fig.Position;

% define the reduction factors and some offsets 
widthreduction  = .45;
heightreduction = .18;

width = widthreduction   * currentFiguPosition( 3 );
height = heightreduction * currentFiguPosition( 4 );

offset  = .2;   % in real unit

% triedxpos = currentAxesPosition(1) + (pos(1) + offset - x0 ) * currentAxesPosition(3) / ( x1 - x0 );
triedxpos = currentFiguPosition(1) + offset * currentFiguPosition(3) + ...
    (pos(1) - x0) * currentAxesPosition(3) * currentFiguPosition(3) / ( x1 - x0 );

onTheRight = triedxpos + width < .99;
if ~onTheRight
%    triedxpos = currentAxesPosition(1) + ...
%        (pos(1) - offset - x0) * currentAxesPosition(3) / (x1 - x0);
%    triedxpos = currentFiguPosition(1) + currentAxesPosition(1) + ...
%        (pos(1) - offset - x0 ) * currentAxesPosition(3) * currentFiguPosition(3) / (x1 - x0);
   triedxpos = triedxpos - width - .8 * offset * currentFiguPosition(3);
%    triedxpos = triedxpos - width;
end

% triedypos = currentAxesPosition(2) + (pos(2) - y0) * currentAxesPosition(4) / (y1 - y0);
% offset = heightreduction;
triedypos = currentFiguPosition(2) + ...
    (pos(2) - y0 ) * currentAxesPosition(4) * currentFiguPosition(4) / ( y1 - y0 );
triedypos = triedypos - .5 * height;
if triedypos + height > .99
    triedypos = .98 - height;
end
% check if the ui-components are in place. 
if ~isempty( obj.savepanel )
    set( obj.savepanel, ...
        'position', [triedxpos, triedypos, width, height], 'visible', 'on' );
    if ~strcmpi( obj.textuiele.String, 'text as:' )
        % rebuild the listener ... 
        set( obj.textuiele, 'string', 'text as:', 'foregroundcolor', 'y' );
        obj.internalChangeContextureListener();
    end
else
    saveWindow = figure( ...
        'units', 'normalized', ...
        'toolbar', 'none', ...
        'color', [.7, .7, .7], ...
        'position', [triedxpos, triedypos, width, height]);
    set( saveWindow, 'CloseRequestFcn', {@Schematic2D.staticModifyCloseRequestFcn, saveWindow} );
    % 
    % one now adds uicontrol elements to the saveWindow: 
    obj.textuiele = uicontrol( saveWindow, ...
        'style', 'text', ...
        'units', 'normalized', ...
        'position', [.05, .5, .2, .177], ...
        'backgroundcolor', [.5, .5, .5], ...
        'foregroundcolor', 'y', ...
        'fontWeight', 'bold', ...
        'fontsize', 15, ...
        'string', 'text as:');
    obj.savepanel = saveWindow;
end
% check if the editable object is already created ...  
if isempty( obj.editableobj )
    % next create the editable area 
    guideEditableArea = uicontrol( saveWindow, ...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [.25, .495, .7, .187], ...
        'backgroundcolor', [.6, .6, .6], ...
        'fontWeight', 'normal', ...
        'fontsize', 15);
    % save the ui-element to the canvas
    obj.editableobj = guideEditableArea;
    
    % one last thing to do in this script, is to update the call-back ... 
    obj.internalChangeContextureListener();
end