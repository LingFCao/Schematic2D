function internalSelectionKeyPressed( obj, key )
mapref = obj.keyMap;
switch lower( key )
    case mapref.saveSelectedRegionToImage
        % still brings up the 'save window'
        notify( obj, 'deselectedObjects' );
        obj.internalBringContextureSaveWindow();
        
    case mapref.translateSelectedObjectsRight
        % move selected data to the right ...
        transVector = obj.selectionTranslationStep * [+1, 0];
        obj.move( transVector );
        
    case mapref.translateSelectedObjectsLeft
        % move selected data to the left  ...
        transVector = obj.selectionTranslationStep * [-1, 0];
        obj.move( transVector );
        
    case mapref.translateSelectedObjectsDown
        % move selected data to the bottom
        transVector = obj.selectionTranslationStep * [0, -1];
        obj.move( transVector );
        
    case mapref.translateSelectedObjectsUp 
        % move selected data to the top 
        transVector = obj.selectionTranslationStep * [0, +1];
        obj.move( transVector );
        
    case mapref.toggleSaveAsPDFFlag
        % toggles the save mode ... 
        obj.saveasPDF = ~obj.saveasPDF;
        
end
% correct the stack order now 
% obj.internalCorrectStackOrder();