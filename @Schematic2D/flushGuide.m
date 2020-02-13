function flushGuide( obj, guideIdentifier )
% remove guide points (default is to remove all of the points )
identifier = 'all';

if nargin > 1
    identifier = guideIdentifier;
end
preparedList = [];
MaxElement   = obj.ClickedPointContainer.getSize();
if MaxElement <= 2
    notify(obj, 'DeactivateHolder');
end

if ischar( identifier )
    switch identifier
        case 'last'
            if ~isempty( obj.lastCreatedPoint )
                preparedList = MaxElement;
            end
            % nullify the lastCreatedPoint property
            obj.lastCreatedPoint = [];
            obj.lastCreatedPointText = [];
        case 'all'
            preparedList = 1 : MaxElement;
            obj.lastCreatedPoint = [];
            obj.lastCreatedPointText = [];
            % when try flushing all of the points, we disable the active
            % state of the holder 
            obj.holderIsActive = false;
            notify(obj, 'DeactivateHolder');
        otherwise
            error( ...
                'SchematicTools:Canvas:illegalkeyword', ...
                'specify as ''last'' or ''all''.');
    end
elseif isnumeric( identifier )
    % prepare the identifier vector
    identifier = identifier(:).';
    identifier = abs( floor( identifier ) );
    identifier = identifier( identifier > 0 & identifier <= MaxElement );
    identifier = unique( identifier );
    preparedList = identifier;
else
    warning( ...
        'SchematicTools:Canvas:illegalType', ...
        ['The type of identifier is not recognised, make sure it is one of the following: ', ...
        'char array, ', ...
        'numeric.'] );
    return;
end

PointReferences     = obj.ClickedPointContainer.GetObjRef( preparedList );
PointTextReferences = obj.ClickedPointTextContainer.GetObjRef( preparedList );

obj.ClickedPointContainer.DeleteObjReference( preparedList );
obj.ClickedPointTextContainer.DeleteObjReference( preparedList );
for p = PointReferences
    p.deleteObj();
end
for p = PointTextReferences
    p.deleteObj();
end
% re-sort the container
obj.resortNumericNameOfGuides();

% if holder is active at this point, redraw the parameterized curve
if obj.holderIsActive
    obj.internalDrawShapeBasedOnGuidePoints();
end