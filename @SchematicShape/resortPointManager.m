function resortPointManager( obj )
% sort the point in the container by modifying the identifier ... 

if obj.pointManager.getSize() > 0
    count = 0;
    for p = obj.pointManager.getAll()
        count = count + 1;
        p.name = count;
    end
end