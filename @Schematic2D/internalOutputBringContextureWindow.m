function internalOutputBringContextureWindow(     obj    )
% configurate a 'file output' window

% obtain the current position of the master figure
currentFiguPosition = obj.parent.Fig.Position;

% define the figure properties
xoffsetfactor = .5;
yoffsetfactor = .5;

widthreduction  = .5; 
heightreduction = .2;


xpos = currentFiguPosition(1) + xoffsetfactor * currentFiguPosition(3);
ypos = currentFiguPosition(2) + yoffsetfactor * currentFiguPosition(4);

width  = widthreduction  * currentFiguPosition( 3 );
height = heightreduction * currentFiguPosition( 4 );

if xpos + width > .99
    % offset the xpos such that xpos + width = .98
    xpos = .98 - width;
end

if ypos + height > .99
    ypos = .98 - height;
end

if ~isempty( obj.savepanel )
    saveWindow = obj.savepanel;
    set( saveWindow, 'position', [xpos, ypos, width, height], 'visible', 'on' );
    if ~strcmpi( obj.textuiele.String, 'file as:' )
        set( obj.textuiele, 'string', 'file as:', 'foregroundcolor', 'r' );
        % rebuild the listener ... 
        obj.internalOutputSetListener();
    end
else
    saveWindow = figure( ...
        'units', 'normalized', ...
        'toolbar', 'none', ...
        'color', [.7, .7, .7], ...
        'position', [xpos, ypos, width, height]);
    set( saveWindow, 'CloseRequestFcn', {@Schematic2D.staticModifyCloseRequestFcn, saveWindow} );
    % 
    % one now adds uicontrol elements to the saveWindow: 
    obj.textuiele = uicontrol( saveWindow, ...
        'style', 'text', ...
        'units', 'normalized', ...
        'position', [.05, .5, .2, .177], ...
        'backgroundcolor', [.5, .5, .5], ...
        'foregroundcolor', 'r', ...
        'fontWeight', 'bold', ...
        'fontsize', 15, ...
        'string', 'file as:');
    obj.savepanel = saveWindow;
end

if isempty( obj.editableobj )
    % next create the editable area 
    guideEditableArea = uicontrol( saveWindow, ...
        'style', 'edit', ...
        'units', 'normalized', ...
        'position', [.25, .495, .7, .187], ...
        'backgroundcolor', [.6, .6, .6], ...
        'fontWeight', 'normal', ...
        'fontsize', 20);
    % save the ui-element to the canvas
    obj.editableobj = guideEditableArea;
    
    % add the listener callback-depending
%     obj.panelstringmodlistener = addlistener( guideEditableArea, ...
%         'String', 'PostSet', @obj.internalEditableStringCallback );
    obj.internalOutputSetListener();
end