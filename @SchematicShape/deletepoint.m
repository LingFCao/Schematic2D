function deletepoint( obj, identifier )
% delete the point identified by the 'identifier'. 'identifier' can take
% several data types. 
%   if 'identifier' is char array then it must take the following values:
%            'last'  - deletes the last added point if it exists
%            'all'   - deletes all the points in the container
%   if 'identifier' is a vector of integers, then we delete the points
%   whose names are in the vector
%   if 'identifier' is a 'SchematicCircle' reference, then we delete the
%   point with the same reference
preparedList = []; 
MaxElement   = obj.pointManager.getSize();
if ischar( identifier )
    switch identifier
        case 'last'
            if ~isempty( obj.lastPointAdded )
                preparedList = MaxElement;
            end
        case 'all'
            preparedList = 1:MaxElement;
        otherwise
            error( ...
                'SchematicTools:Shape:illegalkeyword', ...
                'specify as ''last'' or ''all''.');
    end
elseif isnumeric( identifier )
    % prepare the identifier vector
    identifier = identifier(:).';
    identifier = abs( floor( identifier ) );
    identifier = identifier( identifier > 0 & identifier <= MaxElement );
    identifier = unique( identifier );
    preparedList = identifier;
elseif isa( identifier, 'SchematicCircle' )
    % use 
    tried = obj.pointManager.getObjID( identifier );
    if tried < 1
        warning( ...
            'SchematicTools:Shape:emptyData', ...
            'Object does not contain the requested point reference!');
        return;
    end
    preparedList = tried;
else
    warning( ...
        'SchematicTools:Shape:illegalType', ...
        ['The type of identifier is not recognised, make sure it is one of the following: ', ...
        'char array, ', ...
        'numeric, ', ...
        'SchematicCircle'] );
    return;
end
% preparedList contains the element indices to be deleted
PointReferences = obj.pointManager.GetObjRef( preparedList );

% before one invokes the deletion method, we have to delete the references
% in the container
obj.pointManager.DeleteObjReference( preparedList );

for p = PointReferences
    % p is an instance of SchematicCircle
    p.deleteObj();
end
% re-sort the container ... 
obj.resortPointManager();