function flush( obj, identifier )
% identifier must be a char-vector with the values: 'last' or 'all' ...

if isempty( obj.lastAddedSchematic ), return; end

assert( ...
    strcmpi( identifier, 'last' ) || ...
    strcmpi( identifier, 'all' ), ...
    'SchematicTools:Canvas:illegalkeyword', ...
    'identifier must take the following values: ''last'' or ''all''!' );

identifier = lower( identifier );
switch identifier
    case 'last'
        % for the last, we simply delete the last added schematic object! 
        if isempty( obj.lastAddedSchematic ) || ~obj.lastAddedSchematic.isvalid, return; end
        obj.lastAddedSchematic.deleteObj();
        obj.lastAddedSchematic = obj.schematicContainer.getLastRef();
        
    case 'all'
        associate = obj.lastAddedSchematic;
        while ~isempty( associate ) && associate.isvalid
            newassociate = associate.getAssociate();
            associate.deleteObj(); 
            associate = newassociate;
        end
        obj.lastAddedSchematic = [];
end