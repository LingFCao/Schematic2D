function saveGuidePointsToFiles( obj, filename )

if obj.ClickCounter < 1, return; end % nothing to save here

p = obj.ClickedPointContainer.getAll();
v = cat(1, p.position );
% we do not check the filename, best leave it to the back-end 'dlmwrite'.
dlmwrite( filename, v );
