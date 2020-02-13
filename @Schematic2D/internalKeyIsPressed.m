function internalKeyIsPressed( obj, ~, keydata )
% effects of the key presses ( depending on the current running mode of the
% canvas )

% create the reference to the keyMap property
mapref = obj.keyMap;

% get the exact keypresses on the active figure 
keypressed = keydata.Key;

switch lower( keypressed )
    case mapref.modeSelector
        % we will not allow changing of mode if either the
        % property-selection panel or the 'text-editing' panel are visble
        % ... 
        if ~isempty( obj.savepanel )
            if strcmpi( obj.savepanel.Visible, 'on' )
                warning('The text-edit window is currently active, deactivate it first!' );
                return; 
            end
        end
        if ~isempty( obj.propertypanelwindow )
            if strcmpi( obj.propertypanelwindow.Visible, 'on' )
                warning('The property window is currently active, deactivate it first!' );
                return; 
            end
        end
        
        % reset clickcount ... 
        obj.selectionClickCount = 0;
        
        % this is the special key - it cycles through the modes
        obj.currentModeState = obj.currentModeState + 1;
        obj.currentModeState = 1 + mod( obj.currentModeState - 1, 7 );
        obj.currentMode = obj.ModeSelection{ obj.currentModeState };
        obj.internalChangeContextureListener();

        % change the text on the ui-identifier
        set( obj.ModeIdentifierUi, 'string', obj.currentMode );

        % reset any previously mode propeties

        % 'selection' - reset
        obj.internalSelectionReset();

        % modify/update the ui-components
        obj.internalUpdateContextureUIComponent();

        % for the property-panel ...
        obj.internalPropertySetEditableListener();
        
        % reset the calibration 
        obj.isInCalibration = false;
        
    case mapref.deleteLastObj
        % flush the last added schematic obj 
        obj.flush( 'last' );
        
    case mapref.deleteAllObj
        % flush all of the schematic objects
        obj.flush( 'all' );
        
    case mapref.toggleInprecision
        % toggles the inprecision flag ... 
        obj.useInPrecision = ~obj.useInPrecision;
        % allow the flag to be modified but do not allow the pointer to
        % change style
        if obj.isInCalibration,              return; end
        if obj.imageSettingTerminationPoint, return; end
        if obj.useInPrecision
            % modify the behaviour of the mouse pointer ... 
            set( obj.parent.Fig, 'pointer', 'cross' );
        else
            set( obj.parent.Fig, 'pointer', 'arrow' );
        end
        
    case mapref.togglePrintCoord
        % toggles the print command, so if true display any clicked
        % position to the command window
        obj.PrintGuidePointToCommand = ~obj.PrintGuidePointToCommand;
        
    case mapref.outputContentToMatlabScript
        % toggles 'file content to script' panel ... 
        obj.internalOutputBringContextureWindow();
        
    case mapref.destroyImportedImage
        % destroy the imported image if it exists
        obj.internalImportImageDestory();
        
    case mapref.correctStackOrder
        % we manually correct the stack
        obj.internalCorrectStackOrder();
    case mapref.customZoomIn
        obj.internalZoomIn();
    case mapref.customZoomOut
        obj.internalZoomOut();
    case mapref.customZoomReset
        obj.internalZoomReset();
    case mapref.closeCanvas
        % manually close the canvas down 
        obj.parent.ClearGraphContent();
        obj.delete();
        return;
        
end
if strcmpi( obj.currentMode, 'normal' )
    % manually toggles on the xlock and ylock panel call back
    obj.internalxlockCallback();
    obj.internalylockCallback();
else
    % turn them off
    set( obj.xlockUIDisp, 'visible', 'off' );
    set( obj.ylockUIDisp, 'visible', 'off' );
end
if strcmpi( obj.currentMode, 'image' )
    set( obj.imageSavingModeUI, 'visible', 'on');
else
    set( obj.imageSavingModeUI, 'visible', 'off');
end
% key presses unique to the canvas' mode ... 
if strcmpi( obj.currentMode, 'normal' )
    obj.internalNormalKeyPressed( keypressed );
elseif strcmpi( obj.currentMode, 'selection' )
    obj.internalSelectionKeyPressed( keypressed );
elseif strcmpi( obj.currentMode, 'text' ) || ...
        strcmpi( obj.currentMode, 'arrowtext' )
    obj.internalTextKeyPressed( keypressed );
elseif strcmpi( obj.currentMode, 'circle' )
    obj.internalCircleKeyPressed( keypressed );
elseif strcmpi( obj.currentMode, 'atomicselect')
    obj.internalAtomicSelectKeyPressed( keypressed );
elseif strcmpi( obj.currentMode, 'image' )
    obj.internalImageKeyPressed( keypressed );
end


