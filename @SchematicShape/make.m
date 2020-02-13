function make( obj )
% once a collection of points have been found, the 'make' command returns
% the 'xraw' and 'yraw' data set

if obj.pointManager.getSize() > 1
    % the size is given by 
    p = obj.pointManager.getAll(); 
    v = cat(1, p.position);
    xraw = v(:,1);
    yraw = v(:,2);
    obj.internalCheckAndScaleDataRelativeToCentroid( xraw, yraw );
    % delete all points in the container
    obj.deletepoint( 'all' );
end