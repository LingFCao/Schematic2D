function initializeCompt( obj )
% update or initialize the ui-components

% obtain the current position
currentFigurePosition = obj.parent.parent.Fig.Position;

% define the xoffset
xoffsetfactor = .3;
yoffsetfactor = .1;

% reduction factors
widthreduction  = 1.2; 
heightreduction = .6;

% define the x, y position of key-assignment panel ... 
xpos  = currentFigurePosition(1) + xoffsetfactor * currentFigurePosition(3); 
ypos  = currentFigurePosition(2) + yoffsetfactor * currentFigurePosition(4);

% define the width
width = widthreduction  * currentFigurePosition(3);
height= heightreduction * currentFigurePosition(4);

if xpos + width > .99
    xpos = .98 - width;
end

if ypos + height > .99
    ypos = .98 - height;
end
if ~isempty( obj.assignmentPanel )
    % assignment panel exists, only need to update the current position ...
    % and display the current name values ... 
    set( obj.assignmentPanel, 'position', [xpos, ypos, width, height], 'visible', 'on' );
    
    % okay update the string as follows: 
    count = 0; namevalue = obj.nameValue;
    for p = obj.dynamicUITextComponents.getAll()
        count = count + 1;
        set(p, 'string', namevalue{ count } );
    end
else
    propwin = figure( ...
        'name', 'keymap', ...
        'units', 'normalized', ...
        'toolbar', 'none', ...
        'color', 'k', ...
        'position', [xpos, ypos, width, height] );
    % set CloseRequestFcn
    set( propwin, 'closerequestfcn', {@Schematic2D.staticModifyCloseRequestFcn, propwin} );
    obj.assignmentPanel = propwin;
    % limit the row number to 12
    LimitedRowNumber     = 13;
    % how many components?
    NumberOfActualCompts = length( obj.namelist );
    % 6-modes
    NumberOfDivisions    = 7;
    totalComptsToDraw    = NumberOfActualCompts + NumberOfDivisions;

    % make a special string
    buildOnlyStaticText  = false(1, totalComptsToDraw);
    buildOnlyStaticText( [1, 14, 22, 29, 32, 35, 40] ) = true;
    speciallist          = { 'general', 'normal', 'selection', 'text', 'circle', 'atomic', 'image' };
    % how many colums do we need? Use Col-majored indexing, ...
    %   N = (col# - 1) #row + row#
    % row# = mod( N, #row), col# = 1 + (N - row#) / #row
    LimitedColNumber = 1 + ( ...
        totalComptsToDraw - 1 - mod( totalComptsToDraw - 1, LimitedRowNumber ) ) / ...
        LimitedRowNumber;
    
    % some control parameters - change those to control the apperance
    xoffset   = .02;
    yoffset   = .02;
    xmarginreadjustmentfactor = 1.5;
    ymarginreadjustmentfactor = 1.5;
    interColumnAdjustment     = 1.5;
    fixedDynamicWidth         = .05;
    
    
    yspacing  = (.9 - ymarginreadjustmentfactor * yoffset - ( LimitedRowNumber + 1 ) * yoffset ) / LimitedRowNumber;
    yposition = ymarginreadjustmentfactor * yspacing + (1 : LimitedRowNumber ) * yoffset + (0: LimitedRowNumber - 1 ) * yspacing;
    yposition = yposition(end: -1 : 1 );
    
    % determine the static width
    staticwidth = (1 -  ( LimitedColNumber - 1 ) * interColumnAdjustment * ...
        xoffset - 2 * xmarginreadjustmentfactor * xoffset ) / LimitedColNumber ...
        - fixedDynamicWidth;
    staticheight = yspacing;
    fixedDynamicHeight = yspacing;
    xposition = (0 : LimitedColNumber - 1) * ( fixedDynamicWidth +  ...
        staticwidth + interColumnAdjustment * xoffset ) + xmarginreadjustmentfactor * xoffset;
    % create the ui now
    regcount = 0; specount = 0;
    for k = 1 : totalComptsToDraw
        [row, col] = convertLinearIndexToTuplet( k, LimitedRowNumber );
        x = xposition( col );
        y = yposition( row );
        if buildOnlyStaticText( k )
            % static field 
            specount = specount + 1;
            % modify the x, y position
            x = x + .25 * ( staticwidth + fixedDynamicWidth );
            p = uicontrol( obj.assignmentPanel, ...
                'style', 'text', ...
                'units', 'normalized', ...
                'position', [x, y, .5 * (fixedDynamicWidth + staticwidth), staticheight], ...
                'backgroundcolor', [.4, .4, .4], ...
                'foregroundcolor', 'y', ...
                'fontsize', 13, ...
                'string', speciallist{ specount } );
             obj.staticUITextComponents.add( p );
        else
            % property field
            regcount = regcount + 1;
            p = uicontrol( obj.assignmentPanel, ...
                'style', 'text', ...
                'units', 'normalized', ...
                'position', [x, y, staticwidth, staticheight], ...
                'backgroundcolor', [.6, .6, .6], ...
                'foregroundcolor', 'g', ...
                'fontsize', 9, ...
                'string'  , [obj.namelist{ regcount }, ':'] );
            obj.staticUITextComponents.add( p );
            % create the editable components
            q = uicontrol( obj.assignmentPanel, ...
                'style', 'edit', ...
                'units', 'normalized', ...
                'position', [x + staticwidth, y, fixedDynamicWidth, fixedDynamicHeight], ...
                'backgroundcolor', [.5, .5, .5], ...
                'foregroundcolor', 'w', ...
                'fontsize', 10, ...
                'string', obj.nameValue{ regcount });
            % now create call back... 
            qlistener = addlistener(q, 'String', 'PostSet', @(src, evt) obj.keyValCallback(src, evt, regcount, q ) );
            
            obj.dynamicUITextComponents.add( q ); 
            obj.dynamicTextListeners.add( qlistener );
            
        end
    end
    % create a push button to update the mapping ... 
    obj.updateKeyUIComponent = uicontrol( ...
        obj.assignmentPanel, ...
        'style', 'pushbutton', ...
        'units', 'normalized', ...
        'backgroundcolor', 'r', ...
        'foregroundcolor', 'w', ...
        'position', [.805, .015, .15, .05], ...
        'string', 'set', ...
        'fontsize', 15, ...
        'callback', @obj.updateMap);
end

function [row, col] = convertLinearIndexToTuplet( LinearIndex, rowNumber )
% uses column majored access pattern ...
LinearIndex = LinearIndex - 1;
row = mod( LinearIndex, rowNumber ); 
col = (LinearIndex - row )/ rowNumber;
% increment row and col by 1 
row = row + 1;
col = col + 1;
