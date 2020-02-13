function setAlphaData( obj, alpha )
% sets the alpha data for the patch objects if they exist ... 
obj.faceAlpha = alpha;
if ~isempty( obj.vectorOfPatches )
    set( obj.vectorOfPatches, 'facealpha', alpha ); 
end