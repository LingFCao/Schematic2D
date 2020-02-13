function atomicTranslate( obj, transVec )
% we do not check out-of-bound access

% update is different depending on the style
if strcmpi( obj.style, 'close' ), obj.translate( transVec ); return; end


if ~isempty( obj.xRawData ) || ~isempty( obj.yRawData )
    obj.xRawData = obj.xRawData + transVec(1);
    obj.yRawData = obj.yRawData + transVec(2);
    
    % update is different depending on the style
    % for the open style, we explicity override the draw command (basically
    % to avoid re-computing the interpolation spline)
    % first we check that the fillShape is disable ...
    oldfillstate = obj.fillShape;
    if oldfillstate, obj.fillShape = false; end
    
    % draw using the 'close' style update ... 
    obj.internalEvaluateClosedShape();
    
    % update the internal pivot ... 
    obj.position.setCircleGeometry( obj.position.position + transVec );
    
    % reset back to the old fill-state
    if oldfillstate, obj.fillShape = oldfillstate; end

end