function internalChangeContextureListener( obj )
% depending on the current mode of the canvas, we destroy and rebuild the
% necessary listeners appropriate for that mode.

if obj.currentModeState == 1 || obj.currentModeState == 7
    % first destroy the current listener.
    if ~isempty( obj.panelstringmodlistener )
        obj.panelstringmodlistener.delete();
    end
    if ~isempty( obj.editableobj )
        % now recreate the appropriate listener
        obj.panelstringmodlistener = addlistener( obj.editableobj, ...
            'String', 'PostSet', @obj.internalEditableStringCallback );
    end
elseif obj.currentModeState == 2
    % this corresponds to the selection mode on the canvas
    if ~isempty( obj.panelstringmodlistener )
        obj.panelstringmodlistener.delete();
    end
    if ~isempty( obj.editableobj )
        if obj.saveasPDF
            obj.panelstringmodlistener = addlistener( obj.editableobj, ...
                'String', 'PostSet', @obj.internalSaveCapturedSelectionToPDF );
        else
            obj.panelstringmodlistener = addlistener( obj.editableobj, ...
                'String', 'PostSet', @obj.internalSaveCapturedSelection );
        end
    end
elseif obj.currentModeState == 3 || obj.currentModeState == 4
    % destroy and rebuild ... 
    if ~isempty( obj.panelstringmodlistener )
        obj.panelstringmodlistener.delete();
    end
    if ~isempty( obj.editableobj )
        obj.panelstringmodlistener = addlistener( obj.editableobj, ...
            'String', 'PostSet', @obj.internalTextStringCallback );
    end
end