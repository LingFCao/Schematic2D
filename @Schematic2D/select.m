function select( obj, rect, excludeIdentifiers )
% On the canvas, select schematic objects based on the capture box 'rect'.
% 'rect' is a 4-elements vector of the form: [xlower, ylower, xupper,
% yupper], which forms the two opposite corner points of the box.

% The option 'excludeIdentifiers' includes a cellarray of char-vectors, 
% which denote the names of the objects to be excluded in the selection.

% release any previously selected objects
obj.release();

performExclusionCheck = false;
if nargin > 2
    assert( iscell( excludeIdentifiers ), ...
        'SchematicTools:Canvas:illegaltype', ...
        'The optional exclusion list must be a cell array containing the ''name'' of the schematic objects!' );
    performExclusionCheck = true;
end

if ~obj.schematicContainer.isContainerEmpty()
    for p = obj.schematicContainer.getAll()
        if performExclusionCheck && NameMatchesWithTheExclusionList( p.name, excludeIdentifiers )
            continue;
        end
        if p.Selected( rect )
            obj.SelectedSchematic.add( p );
        end
    end
end

function isNameMatchedWithExclusionList = NameMatchesWithTheExclusionList( Name, List )
% a simple check
numberOfExclusions = length( List );
isNameMatchedWithExclusionList = false;
for k = 1 : numberOfExclusions
    isNameMatchedWithExclusionList = isNameMatchedWithExclusionList || ...
        strcmpi( Name, List{ k } );
    % stop, no-further check is required
    if isNameMatchedWithExclusionList, break; end
end