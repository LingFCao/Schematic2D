classdef(Abstract) AbstractSchematicComponent < handle & matlab.mixin.Heterogeneous
    % an abstract class that forms the super class of all compatible
    % schematic objects. 
    %
    % 
    properties(Abstract)
        name;       % name id
        type;       % type id
        style;      % a style
        parent;     % parent signature (in concrete subclasses, it must be specified as ''Schematic2D''
    end
    methods(Abstract)
        % object must initialize the following methods (else they will
        % remain abstract )
        draw(obj, varargin);
        turn(obj, state);
        
        isObjSelected = Selected( obj, rect );
        translate( obj, transVec );
        
        addSelectionAttribute( obj );
        atomicTranslate(obj, transvec);
        atomicScale(obj, pivot, scale);
        atomicRotate( obj, pivot, angle);
        
        % 
        [stringcell, datafile] = outputstream( obj );
    end
    methods(Static, Hidden)
        keyIsValid = CheckSchematicComponentKey( key );
    end
    methods(Sealed)
        function tf = eq( H1, H2 )
            % override the 'eq' operator in the handle class. This is
            % necessary to match with the Heterogeneous' method dispatching
            % approach.
            tf = eq@handle( H1, H2 );
        end
    end
end