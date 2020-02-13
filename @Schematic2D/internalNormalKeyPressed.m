function internalNormalKeyPressed( obj, key )
% applies if the current running mode of the canvas is 'normal'
mapref = obj.keyMap;
switch lower( key )
    case mapref.saveGuidePointsToFile
        % bring up the 'save window' to make a copy of the data of any
        % guide points on the canvas
        obj.internalBringContextureSaveWindow();
        
    case mapref.deleteLastGuidePoint
        % delete the last point created on the canvas
        obj.flushGuide( 'last' );
        
    case mapref.deleteAllGuidePoints
        % delete all guide points on the canvas
        obj.flushGuide( 'all' );
        
    case mapref.computeGuideCurve
        % create a schematic curve based on the existing guide points
        obj.internalDrawShapeBasedOnGuidePoints();
        
    case mapref.bringUpCurvePropertyPanel
        % bring up the property panel
        obj.internalPropertyPanelInitialize();
        
    case mapref.toggleXLock 
        % controls the xlock
        obj.xlock = ~obj.xlock;
        
    case mapref.toggleYLock
        % controls the ylock
        obj.ylock = ~obj.ylock;
end