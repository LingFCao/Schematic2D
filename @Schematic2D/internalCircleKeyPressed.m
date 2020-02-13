function internalCircleKeyPressed( obj, keypressed )

mapref = obj.keyMap;
switch lower( keypressed )
    case mapref.resetTemporaryCircleHolder
        obj.guideCircle.turn( 'off' );
        
    case mapref.bringUpCirclePropertyPanel
        obj.internalPropertyPanelInitialize();
end
