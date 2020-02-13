function internalSaveAsPDFCallback( obj, ~, ~)

if obj.saveasPDF
    % we modify the listener for the save command ... 
    if ~isempty( obj.panelstringmodlistener )
        obj.panelstringmodlistener.delete();
    end
    if ~isempty( obj.editableobj )
        obj.panelstringmodlistener = addlistener( obj.editableobj, ...
            'String', 'PostSet', @obj.internalSaveCapturedSelectionToPDF );
    end
    set( obj.figExportModeDisp, 'string', 'pdf' );
else
    if ~isempty( obj.panelstringmodlistener )
        obj.panelstringmodlistener.delete();
    end
    if ~isempty( obj.editableobj )
        obj.panelstringmodlistener = addlistener( obj.editableobj, ...
            'String', 'PostSet', @obj.internalSaveCapturedSelection );
    end
    set( obj.figExportModeDisp, 'string', 'jpg' );
end